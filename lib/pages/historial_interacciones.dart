
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistorialInteraccionesScreen extends StatefulWidget {
  const HistorialInteraccionesScreen({super.key});

  @override
  State<HistorialInteraccionesScreen> createState() =>
      _HistorialInteraccionesScreenState();
}

class _HistorialInteraccionesScreenState
    extends State<HistorialInteraccionesScreen> {
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> _likes = [];
  List<Map<String, dynamic>> _dislikes = [];
  List<Map<String, dynamic>> _matchs = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarInteracciones();
  }

  Future<void> _cargarInteracciones() async {
    final likesSnapshot = await FirebaseFirestore.instance
        .collection('likes')
        .where('usuarioId', isEqualTo: _uid)
        .get();

    final matchsSnapshot = await FirebaseFirestore.instance
        .collection('matchs')
        .where('mascota1Id', isEqualTo: _uid)
        .get();

    final dislikes = likesSnapshot.docs
        .where((doc) => doc['accion'] == 'dislike')
        .map((doc) => {
              'mascotaId': doc['mascotaId'],
              'accion': 'dislike',
              'fecha': doc['timestamp']
            })
        .toList();

    final likes = likesSnapshot.docs
        .where((doc) => doc['accion'] == 'like')
        .map((doc) => {
              'mascotaId': doc['mascotaId'],
              'accion': 'like',
              'fecha': doc['timestamp']
            })
        .toList();

    final matchs = matchsSnapshot.docs.map((doc) => {
          'mascotaId': doc['mascota2Id'],
          'accion': 'match',
          'fecha': doc['fechaMatch']
        }).toList();

    setState(() {
      _likes = likes;
      _dislikes = dislikes;
      _matchs = matchs;
      _cargando = false;
    });
  }

  Widget _buildItem(Map<String, dynamic> interaccion) {
    final tipo = interaccion['accion'];
    final id = interaccion['mascotaId'];
    final icono = tipo == 'like'
        ? Icons.favorite
        : tipo == 'dislike'
            ? Icons.clear
            : Icons.pets;
    final color = tipo == 'like'
        ? Colors.green
        : tipo == 'dislike'
            ? Colors.red
            : Colors.blue;

    return ListTile(
      leading: Icon(icono, color: color),
      title: Text('Mascota ID: $id'),
      subtitle: Text('Acción: $tipo'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de interacciones'),
        backgroundColor: const Color(0xFFAAF0D1),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Matchs', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ..._matchs.map(_buildItem),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Likes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ..._likes.map(_buildItem),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Dislikes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ..._dislikes.map(_buildItem),
              ],
            ),
    );
  }
}

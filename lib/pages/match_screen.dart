import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/like_service.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  List<Map<String, dynamic>> _mascotas = [];
  List<Map<String, dynamic>> _misMascotas = [];
  String? _miMascotaSeleccionadaId;
  int _indiceActual = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      LocationPermission permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied || permiso == LocationPermission.deniedForever) {
        setState(() => _cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes habilitar los permisos de ubicación')),
        );
        return;
      }

      final propiasSnapshot = await FirebaseFirestore.instance
          .collection('mascotas')
          .where('duenoId', isEqualTo: uid)
          .get();

      final misMascotas = propiasSnapshot.docs.map((d) => {
        ...d.data(),
        'id': d.id,
      }).toList();

      if (misMascotas.isEmpty) {
        setState(() {
          _misMascotas = [];
          _mascotas = [];
          _cargando = false;
        });
        return;
      }

      _miMascotaSeleccionadaId = misMascotas.first['id'];

      final posicion = await Geolocator.getCurrentPosition();
      final distancia = Distance();

      final snapshot = await FirebaseFirestore.instance.collection('mascotas').get();

      final likes = await FirebaseFirestore.instance
          .collection('likes')
          .where('usuarioId', isEqualTo: _miMascotaSeleccionadaId)
          .get();

      final yaVistas = likes.docs.map((doc) => doc['mascotaId']).toSet();

      final mascotasFiltradas = snapshot.docs.where((doc) {
        final data = doc.data();
        final geo = data['ubicacion'];
        if (geo == null) return false;
        if (data['duenoId'] == uid) return false;
        if (yaVistas.contains(doc.id)) return false;

        final dist = distancia.as(
          LengthUnit.Kilometer,
          LatLng(posicion.latitude, posicion.longitude),
          LatLng(geo.latitude, geo.longitude),
        );
        return dist <= 100;
      }).map((doc) => {...doc.data(), 'id': doc.id}).toList();

      setState(() {
        _misMascotas = misMascotas;
        _mascotas = mascotasFiltradas;
        _cargando = false;
      });
    } catch (e) {
      print('Error en _cargarDatos: $e');
      setState(() {
        _cargando = false;
        _mascotas = [];
      });
    }
  }

  void _interactuar(String accion) async {
    if (_indiceActual >= _mascotas.length || _miMascotaSeleccionadaId == null) return;

    final mascota = _mascotas[_indiceActual];

    await LikeService().registrarAccion(
      desdeMascotaId: _miMascotaSeleccionadaId!,
      haciaMascotaId: mascota['id'],
      accion: accion,
      onMatch: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('¡Match encontrado!'),
            content: Text('Tu mascota y ${mascota['nombre']} hicieron match'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );

    setState(() => _indiceActual++);
  }

  void _verHistorialInteracciones() {
    Navigator.pushNamed(context, '/historial-interacciones');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar mascotas'),
        backgroundColor: const Color(0xFFAAF0D1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Historial de interacciones',
            onPressed: _verHistorialInteracciones,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _misMascotas.isEmpty
              ? const Center(child: Text('No tienes mascotas para hacer match.'))
              : _mascotas.isEmpty || _indiceActual >= _mascotas.length
                  ? const Center(child: Text('No hay mascotas cercanas disponibles.'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _miMascotaSeleccionadaId,
                            items: _misMascotas.map((m) {
                              return DropdownMenuItem<String>(
                                value: m['id'],
                                child: Text(m['nombre']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _miMascotaSeleccionadaId = value);
                            },
                            decoration: const InputDecoration(labelText: 'Selecciona tu mascota'),
                          ),
                          const SizedBox(height: 20),
                          Card(
                            elevation: 4,
                            child: Column(
                              children: [
                                if (_mascotas[_indiceActual]['imagenUrl'] != null)
                                  Image.network(
                                    _mascotas[_indiceActual]['imagenUrl'],
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ListTile(
                                  title: Text(_mascotas[_indiceActual]['nombre'] ?? ''),
                                  subtitle: Text(_mascotas[_indiceActual]['descripcion'] ?? ''),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.clear, color: Colors.red),
                                      onPressed: () => _interactuar('dislike'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.favorite, color: Colors.green),
                                      onPressed: () => _interactuar('like'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}

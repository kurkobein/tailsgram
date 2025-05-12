import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tailsgram/widgets/publicaciones_widget.dart';

class ListaPublicaciones extends StatelessWidget {
  const ListaPublicaciones({super.key});

  Future<String> _obtenerNombreUsuario(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    return doc.exists ? (doc.data()?['nombre'] ?? 'Anónimo') : 'Anónimo';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover,
          height: 35,
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 198, 241, 214),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('publicaciones')
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar publicaciones.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final publicaciones = snapshot.data!.docs;
          if (publicaciones.isEmpty) {
            return const Center(child: Text('No hay publicaciones.'));
          }
          return ListView.builder(
            itemCount: publicaciones.length,
            itemBuilder: (context, index) {
              final doc = publicaciones[index];
              final texto = doc['texto'] ?? '';
              final imagenUrl = doc['imagenUrl'] ?? '';
              final uid = doc['uid'] ?? '';

              return FutureBuilder<String>(
                future: _obtenerNombreUsuario(uid),
                builder: (context, snapshotNombre) {
                  final nombreUsuario = snapshotNombre.data ?? 'Cargando...';

                  return post(
                    imagenUrl: imagenUrl,
                    nombreUsuario: nombreUsuario,
                    texto: texto,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListaPublicaciones extends StatelessWidget {
  const ListaPublicaciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicaciones'),
        centerTitle: true,
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

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imagenUrl.isNotEmpty)
                      Image.network(imagenUrl, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        texto,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

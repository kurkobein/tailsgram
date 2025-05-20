import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tailsgram/widgets/publicaciones_widget.dart';

class ListaPublicaciones extends StatelessWidget {
  const ListaPublicaciones({super.key});

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
            physics: const BouncingScrollPhysics(),
            itemCount: publicaciones.length,
            itemBuilder: (context, index) {
              final doc = publicaciones[index];
              final texto = doc['texto'] ?? '';
              final imagenUrl = doc['imagenUrl'] ?? '';
              final uid = doc['uid'] ?? '';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(uid)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text('Cargando...'));
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const ListTile(title: Text('Usuario no encontrado'));
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  final nombreUsuario = userData['usuario'] ?? 'Usuario';
                  final fotoPerfilUrl = userData['fotoPerfilUrl'] ??
                      'https://qehohrpghlqjkatoyqux.supabase.co/storage/v1/object/public/imagenes/fotos_defecto/default.png';

                  return Post(
                    imagenUrl: imagenUrl,
                    nombreUsuario: nombreUsuario,
                    texto: texto,
                    fotoPerfil: fotoPerfilUrl,
                    postId: doc.id,
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

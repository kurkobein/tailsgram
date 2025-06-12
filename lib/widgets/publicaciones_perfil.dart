import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tailsgram/widgets/publicaciones_widget.dart';

class ListaPublicacionesPerfil extends StatelessWidget {
  final String uidPerfil;

  const ListaPublicacionesPerfil({super.key, required this.uidPerfil});


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('publicaciones')
          .where('uid', isEqualTo: uidPerfil)
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
          return const Center(child: Text('Este usuario no tiene publicaciones.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: publicaciones.length,
          itemBuilder: (context, index) {
            final doc = publicaciones[index];
            final texto = doc['texto'] ?? '';
            final imagenUrl = doc['imagenUrl'] ?? '';
            final uid = doc['uid'] ?? '';

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('usuarios').doc(uid).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(title: Text('Cargando...'));
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const ListTile(title: Text('Usuario no encontrado'));
                }

                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
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
    );
  }
}

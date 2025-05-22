import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tailsgram/widgets/publicaciones_widget.dart';
import 'package:tailsgram/pages/match_screen.dart';

class ListaPublicaciones extends StatelessWidget {
  const ListaPublicaciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 300),
                    pageBuilder: (context, animation, secondaryAnimation) => Match(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(-1.0, 0.0);
                      const end = Offset.zero;
                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
                      return SlideTransition(position: animation.drive(tween), child: child);
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 198, 241, 214),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(8),
                shadowColor: Colors.transparent,
              ), 
              child: Icon(
                Icons.local_fire_department_rounded,
                color: Colors.black,
                size: 35,
                
              ),
            ),
            Image.asset(
              'assets/images/logo.png',
              height: 40,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/lista-chats');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 198, 241, 214),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(8),
                shadowColor: Colors.transparent,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.black,
                size: 35,
              ),
            ),
          ],
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

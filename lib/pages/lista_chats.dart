import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tailsgram/pages/test_mensajeria.dart';

class ListaChatsScreen extends StatelessWidget {
  const ListaChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFAAF0D1),
        title: const Text("Mis chats"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('usuarios', arrayContains: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(child: Text('No tienes chats aún.'));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final List usuarios = chat['usuarios'];
              final String otherUserId = usuarios.firstWhere((u) => u != uid);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('usuarios').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(title: Text("Cargando usuario..."));
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final nombre = userData['usuario'] ?? 'Usuario';

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chat.id)
                        .collection('mensajes')
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, msgSnapshot) {
                      String ultimoMensaje = 'Sin mensajes aún';

                      if (msgSnapshot.hasData && msgSnapshot.data!.docs.isNotEmpty) {
                        final mensaje = msgSnapshot.data!.docs.first;
                        ultimoMensaje = mensaje['texto'] ?? '';
                      }

                      return ListTile(
                        title: Text(nombre),
                        subtitle: Text(
                          ultimoMensaje,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(otherUserId: otherUserId),
                            ),
                          );
                        },
                      );
                    },
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

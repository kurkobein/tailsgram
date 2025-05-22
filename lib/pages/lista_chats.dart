import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tailsgram/pages/test_mensajeria.dart';
import 'package:tailsgram/pages/test_mensajeria.dart';

class ListaChatsScreen extends StatelessWidget {
  const ListaChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis chats')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('usuarios', arrayContains: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

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

              return ListTile(
                title: Text('Chat con $otherUserId'),
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
      ),
    );
  }
}

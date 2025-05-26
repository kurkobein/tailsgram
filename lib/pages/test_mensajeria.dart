import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;

  const ChatScreen({Key? key, required this.otherUserId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  String? chatId;

  @override
  void initState() {
    super.initState();
    _obtenerOCrearChat();
  }

  Future<void> _obtenerOCrearChat() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final chats = FirebaseFirestore.instance.collection('chats');

    final query = await chats.where('usuarios', arrayContains: uid).get();

    for (final doc in query.docs) {
      final data = doc.data();
      if ((data['usuarios'] as List).contains(widget.otherUserId)) {
        setState(() {
          chatId = doc.id;
        });
        return;
      }
    }

    final nuevoChat = await chats.add({
      'usuarios': [uid, widget.otherUserId],
      'creado': Timestamp.now(),
    });

    setState(() {
      chatId = nuevoChat.id;
    });
  }

  void _enviarMensaje() async {
    if (_controller.text.trim().isEmpty || chatId == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('mensajes')
        .add({
      'texto': _controller.text.trim(),
      'autor': uid,
      'timestamp': Timestamp.now(),
      'leido': false,
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        backgroundColor: const Color(0xFFAAF0D1),
      ),body: chatId == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chatId)
                        .collection('mensajes')
                        .orderBy('timestamp')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final uid = FirebaseAuth.instance.currentUser!.uid;
                      final mensajes = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: mensajes.length,
                        itemBuilder: (context, index) {
                          final mensaje = mensajes[index];
                          final esMio = mensaje['autor'] == uid;
                          return Align(
                            alignment:
                                esMio ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: esMio ? Colors.blue[100] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(mensaje['texto']),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Escribe un mensaje...'
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _enviarMensaje,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

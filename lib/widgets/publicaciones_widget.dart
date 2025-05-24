import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Post extends StatefulWidget {
  final String imagenUrl;
  final String nombreUsuario;
  final String texto;
  final String fotoPerfil;
  final String postId;
  
  const Post({
    super.key, 
    required this.imagenUrl, 
    required this.nombreUsuario, 
    required this.texto,
    required this.fotoPerfil,
    required this.postId,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _getLikeCount();
  }

  Future<void> _getLikeCount() async {
    final likes = await _firestore
        .collection('publicaciones')
        .doc(widget.postId)
        .collection('likes')
        .get();

    if (mounted) {
      setState(() {
        _likeCount = likes.size;
      });
    }
  }

  Future<void> _checkIfLiked() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final likeDoc = await _firestore
        .collection('publicaciones')
        .doc(widget.postId)
        .collection('likes')
        .doc(userId)
        .get();

    if (mounted) {
      setState(() {
        _isLiked = likeDoc.exists;
      });
    }
  }

  Future<void> _toggleLike() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    setState(() {
    });

    final likeRef = _firestore
        .collection('publicaciones')
        .doc(widget.postId)
        .collection('likes')
        .doc(userId);

    if (_isLiked) {
      await likeRef.delete();
    } else {
      await likeRef.set({
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    await _checkIfLiked();
    await _getLikeCount();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.fotoPerfil),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.nombreUsuario,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 14, 15),
            child: Text(
              widget.texto,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (widget.imagenUrl.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 350,
              ),
              child: Image.network(
                widget.imagenUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : null,
                      ),
                onPressed: _toggleLike,
              ),
              Text(_likeCount.toString()),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.comment),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
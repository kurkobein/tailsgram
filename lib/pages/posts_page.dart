import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tailsgram/services/storage/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaginaSubir extends StatefulWidget {
  const PaginaSubir({super.key});

  @override
  State<PaginaSubir> createState() => _PaginaSubirState();
}

class _PaginaSubirState extends State<PaginaSubir> {
  final TextEditingController _textoController = TextEditingController();
  File? _selectedImage;
  String? _imageFileName;
  bool _isLoading = false;

  // Selecciona imagen con StorageService, pero no la sube aún
  Future<void> _seleccionarImagen() async {
    final result = await StorageService().seleccionarImagen();
    if (result != null) {
      setState(() {
        _selectedImage = result.file;
        _imageFileName = result.fileName;
      });
    }
  }

  Future<void> _subirPublicacion() async {
    final texto = _textoController.text.trim();
    if (texto.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes ingresar texto y seleccionar una imagen.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageUrl = await StorageService().subirImagenDesdeFile(_selectedImage!, _imageFileName!);

      if (imageUrl == null) {
        throw Exception('No se pudo subir la imagen');
      }

      final user = FirebaseAuth.instance.currentUser;
      final nombreUsuario = user?.displayName ?? 'Error nombre';

      await FirebaseFirestore.instance.collection('publicaciones').add({
        'texto': texto,
        'imagenUrl': imageUrl,
        'uid': user?.uid,
        'nombreUsuario': nombreUsuario,
        'fecha': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicación creada correctamente')),
      );

      setState(() {
        _textoController.clear();
        _selectedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subir Publicación'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textoController,
              decoration: const InputDecoration(labelText: 'Escribe algo...'),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _seleccionarImagen,
              child: const Text('Seleccionar Imagen'),
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 10),
              Image.file(_selectedImage!, height: 200),
            ],
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _subirPublicacion,
                    child: const Text('Publicar'),
                  ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tailsgram/services/storage/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tailsgram/widgets/boton_estandar.dart';

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
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Usuario';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Publicación'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 198, 241, 214),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Text(userName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                      ),
                      SizedBox(width: 10),
                      Text('$userName dice...', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _textoController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: '¡Cuentale al mundo tu dia!',
                    ),
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 10),
                    Image.file(_selectedImage!, width: double.infinity, fit: BoxFit.cover),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _seleccionarImagen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: const CircleBorder(),
                    elevation: 0,
                  ),
                  child: const Icon(Icons.photo_outlined, size: 40, color: Color.fromRGBO(255, 107, 129, 1)),
                ),
                
                _isLoading
                    ? const CircularProgressIndicator()
                    : BotonEstandar(texto: 'Publicar', onPressed: _subirPublicacion),
              ],
            )
          ],
        ),
      ),
    );
  }
}

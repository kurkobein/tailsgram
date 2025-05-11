import 'package:flutter/material.dart';
import 'package:tailsgram/services/storage/storage_service.dart';

class PaginaSubir extends StatelessWidget{
  const PaginaSubir({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subir Mascota'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            StorageService().uploadImage();
            
          },
          child: const Text('Subir Mascota'),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class post extends StatelessWidget {
  final String imagenUrl;
  final String nombreUsuario;
  final String texto;
  const post({
    super.key, 
    required this.imagenUrl, 
    required this.nombreUsuario, 
    required this.texto
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Text(
                nombreUsuario,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (imagenUrl.isNotEmpty)
              Image.network(imagenUrl, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                texto,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
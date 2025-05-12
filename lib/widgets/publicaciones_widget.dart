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
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Text(nombreUsuario[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: 10),
                  Text(
                    nombreUsuario,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            if (imagenUrl.isNotEmpty)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 350,
                ),
                child: Image.network(
                  imagenUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () {},
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 14, 15), // ← izquierda, arriba, derecha, abajo
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MascotaDetalleScreen extends StatelessWidget {
  const MascotaDetalleScreen({super.key});

@override
Widget build(BuildContext context) {
  final args = ModalRoute.of(context)!.settings.arguments;

  if (args is! DocumentSnapshot) {
    return const Scaffold(
      body: Center(child: Text('Error: datos de la mascota no válidos')),
    );
  }

  final data = args.data() as Map<String, dynamic>;

  return Scaffold(
    appBar: AppBar(title: Text(data['nombre'] ?? 'Mascota')),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nombre: ${data['nombre']}',
              style: const TextStyle(fontSize: 20)),
          Text('Raza: ${data['raza']}'),
          Text('Edad: ${data['edad']} años'),
          Text('Género: ${data['genero']}'),
          const SizedBox(height: 20),
          Text('Descripción:',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(data['descripcion'] ?? ''),
          const SizedBox(height: 20),
          if (data['imagenUrl'] != null && data['imagenUrl'].toString().isNotEmpty)
            Image.network(data['imagenUrl']),
        ],
      ),
    ),
  );
}
}
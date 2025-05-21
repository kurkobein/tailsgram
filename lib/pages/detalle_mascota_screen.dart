import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/mascota_service.dart';

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

    final mascota = args;
    final data = mascota.data() as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFFC5F3D6),
      appBar: AppBar(
        title: Text(data['nombre'] ?? 'Mascota'),
        backgroundColor: const Color(0xFFAAF0D1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Image.network(
                data['imagenUrl'] ?? '',
                width: 150,
                fit: BoxFit.cover,
                
              ),
            ),
            Text('Nombre:', style: _etiqueta()),
            Text(data['nombre'] ?? '', style: _valor()),

            const SizedBox(height: 12),
            Text('Raza:', style: _etiqueta()),
            Text(data['raza'] ?? '', style: _valor()),

            const SizedBox(height: 12),
            Text('Edad:', style: _etiqueta()),
            Text('${data['edad'] ?? '-'} años', style: _valor()),

            const SizedBox(height: 12),
            Text('Género:', style: _etiqueta()),
            Text(data['genero'] ?? '', style: _valor()),

            const SizedBox(height: 20),
            Text('Descripción:', style: _etiqueta()),
            Text(data['descripcion'] ?? '-', style: _valor()),

            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/mascota-editar',
                        arguments: mascota,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B81),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirmacion = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Eliminar mascota'),
                          content: const Text('¿Estás seguro que deseas eliminar esta mascota?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );

                      if (confirmacion == true) {
                        await MascotaService().eliminarMascota(mascota.id);
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacementNamed(context, '/mascota-list');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Eliminar'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  TextStyle _etiqueta() => const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.black87,
      );

  TextStyle _valor() => const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      );
}

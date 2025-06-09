import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/mascota_service.dart';

class MascotaDetalleScreen extends StatelessWidget {
  final DocumentSnapshot datos;
  const MascotaDetalleScreen({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    


    Map<String, dynamic> data = datos.data() as Map<String, dynamic>;
    String mascotaId = datos.id;
    final String usuarioIdActual = FirebaseAuth.instance.currentUser!.uid;

    // Asegúrate de que el documento de la mascota tiene este campo:
    final String duenoUid = data['duenoId'] ?? '';
    final bool esMiPerfil = usuarioIdActual == duenoUid;

    if (args is DocumentSnapshot) {
      mascotaId = args.id;
      data = args.data() as Map<String, dynamic>;
    } else if (args is Map<String, dynamic> && args.containsKey('id')) {
      mascotaId = args['id'];
      data = args;
    } else {
      return const Scaffold(
        body: Center(child: Text('Error: datos de la mascota no válidos')),
      );
    }

    print('Datos de mascota: $data');
    print('UID del dueño: ${data['duenoId']}');
    print('UID actual: $usuarioIdActual');


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
            if (data['imagenUrl'] != null && data['imagenUrl'].toString().isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Image.network(
                  data['imagenUrl'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
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
            if (esMiPerfil) ...{
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/mascota-editar',
                          arguments: {'id': mascotaId, ...data},
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
                          await MascotaService().eliminarMascota(mascotaId);
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
            } else ...{
              SizedBox(width: 1)
            }
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

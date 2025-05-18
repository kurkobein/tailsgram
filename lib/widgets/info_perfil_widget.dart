import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tailsgram/widgets/boton_estandar_perfil.dart';
import 'package:tailsgram/pages/list_mascota_screen.dart';

class Informacion extends StatefulWidget {
  final String idPerfil;
  const Informacion({super.key, required this.idPerfil});
  

  @override
  State<Informacion> createState() => _InformacionState();
}

class _InformacionState extends State<Informacion> {
  final String idUsuarioActual = FirebaseAuth.instance.currentUser!.uid;

  Future<DocumentSnapshot> obtenerDatosPerfil() async {
    return await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.idPerfil)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final bool miPerfil = widget.idPerfil == idUsuarioActual;

    return FutureBuilder<DocumentSnapshot>(
      future: obtenerDatosPerfil(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text("No se encontró el perfil.");
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String idPerfil = snapshot.data!.id;
        final String idUsuarioActual = FirebaseAuth.instance.currentUser!.uid;
        print('estos son idUsuarioActual $idUsuarioActual e idPerfil $idPerfil');

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                    child: Text('3 Mascotas', style: TextStyle(fontSize: 12)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                    child: Text('50 seguidores', style: TextStyle(fontSize: 12)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                    child: Text('30 seguidos', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                 
                  if (miPerfil) ...[
                    // Botón: Editar mascotas (si es tu perfil)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                      child: BotonEstandarPerfil(
                        texto: 'Editar Mascotas',
                        onPressed: () {
                          Navigator.pushNamed(context, '/mascota-list');
                        },
                        ancho: 20,
                      ),
                    ),
                    // Botón: Editar perfil
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                      child: BotonEstandarPerfil(
                        texto: 'Editar Perfil',
                        onPressed: () async {
                          Navigator.pushNamed(context, '/configuracion');
                        },
                        ancho: 28,
                      ),

                    ),
                  ] else ...[
                    // Botón: Ver mascotas del otro usuario
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                      child: BotonEstandarPerfil(
                        texto: 'Ver Mascotas',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MascotaListScreen(uid: widget.idPerfil),
                            ),
                          );
                        },
                        ancho: 28,
                      ),
                    ),
                    // Botón: Seguir / Dejar de seguir
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                      child: BotonEstandarPerfil(
                        texto: 'Siguiendo',
                        onPressed: () async {
                          // await _toggleSeguir(idPerfil);
                        },
                        ancho: 20,
                      ),
                    ),
                  ],
                ],
              ),

            ],
          ),
        );
      },
    );
  }
}

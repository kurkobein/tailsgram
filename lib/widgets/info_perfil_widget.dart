import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tailsgram/widgets/boton_estandar_perfil.dart';
import 'package:tailsgram/pages/mascota_screen/list_mascota_screen.dart';
import 'package:tailsgram/widgets/boton_seguir.dart';

class Informacion extends StatefulWidget {
  final String idPerfil;
  const Informacion({super.key, required this.idPerfil});
  

  @override
  State<Informacion> createState() => _InformacionState();
}

class _InformacionState extends State<Informacion> {
  final String idUsuarioActual = FirebaseAuth.instance.currentUser!.uid;

  Future<bool> yaSigoA(String idSeguido) async {
    final idActual = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('seguidos')
        .doc(idActual)
        .collection('usuarios')
        .doc(idSeguido)
        .get();

    return doc.exists;
  }

  Future<int> contarSeguidores(String idUsuario) async {
    final snap = await FirebaseFirestore.instance
        .collection('seguidores')
        .doc(idUsuario)
        .collection('usuarios')
        .get();
    return snap.docs.length;
  }

  Future<int> contarSeguidos(String idUsuario) async {
    final snap = await FirebaseFirestore.instance
        .collection('seguidos')
        .doc(idUsuario)
        .collection('usuarios')
        .get();
    return snap.docs.length;
  }

  Future<DocumentSnapshot> obtenerDatosPerfil() async {
    return await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.idPerfil)
        .get();
  }

  Future<int> contarMascotasUsuario(String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('mascotas')
        .where('duenoId', isEqualTo: userId)
        .get();
    return querySnapshot.docs.length;
  }

  Future<List<dynamic>> obtenerDatosPerfilYConteo() async {
    final perfil = await obtenerDatosPerfil();
    final bool miPerfil = widget.idPerfil == idUsuarioActual;
    if (miPerfil){
      final cantidadMascotas = await contarMascotasUsuario(idUsuarioActual);
      final seguidores = await contarSeguidores(idUsuarioActual);
      final seguidos = await contarSeguidos(idUsuarioActual);
      final yaSigo = await yaSigoA(idUsuarioActual);
      return [perfil, cantidadMascotas, seguidores, seguidos, yaSigo];
    } 
    else {
      final cantidadMascotas = await contarMascotasUsuario(widget.idPerfil);
      final seguidores = await contarSeguidores(widget.idPerfil);
      final seguidos = await contarSeguidos(widget.idPerfil);
      final yaSigo = await yaSigoA(widget.idPerfil);
      return [perfil, cantidadMascotas, seguidores, seguidos, yaSigo];
    }
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<List<dynamic>>(
      future: obtenerDatosPerfilYConteo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Text('No se pudieron cargar los datos');
        }

        final perfil = snapshot.data![0] as DocumentSnapshot;
        final cantidadMascotas = snapshot.data![1] as int;
        final seguidores = snapshot.data![2] as int;
        final seguidos = snapshot.data![3] as int;
        final yaSigo = snapshot.data![4] as bool;

        print("ya sigo a esta persona $yaSigo");

        final bool miPerfil = widget.idPerfil == idUsuarioActual;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (miPerfil) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      child: Text('$cantidadMascotas Mascotas', style: const TextStyle(fontSize: 12)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      child: Text('$seguidores seguidores', style: const TextStyle(fontSize: 12)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      child: Text('$seguidos seguidos', style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ] else ...[
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      child: Text('$cantidadMascotas Mascotas', style: const TextStyle(fontSize: 12)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      child: Text('$seguidores seguidores', style: const TextStyle(fontSize: 12)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      child: Text('$seguidos seguidos', style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (miPerfil) ...[
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                      child: BotonEstandarPerfil(
                        texto: 'Editar Perfil',
                        onPressed: () {
                          Navigator.pushNamed(context, '/configuracion');
                        },
                        ancho: 28,
                      ),
                    ),
                  ] else ...[
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                      child: BotonSeguir(idSeguido: widget.idPerfil),
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

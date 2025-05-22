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
      print('Cantidad de mascotas: $cantidadMascotas');
      return [perfil, cantidadMascotas];
    } 
    else {
      print('No es mi perfil ' + widget.idPerfil);
      final cantidadMascotas = await contarMascotasUsuario(widget.idPerfil);
      print('Cantidad de mascotas: $cantidadMascotas');
      return [perfil, cantidadMascotas];
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

        print('Perfil: ${perfil.data()}');
        print('Cantidad de mascotas: $cantidadMascotas');

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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      child: Text('50 seguidores', style: TextStyle(fontSize: 12)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      child: Text('30 seguidos', style: TextStyle(fontSize: 12)),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      child: Text('50 seguidores', style: TextStyle(fontSize: 12)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      child: Text('30 seguidos', style: TextStyle(fontSize: 12)),
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
                      child: BotonEstandarPerfil(
                        texto: 'Siguiendo',
                        onPressed: () {
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

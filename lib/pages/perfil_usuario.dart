import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tailsgram/widgets/info_perfil_widget.dart';
import 'package:tailsgram/widgets/publicaciones_perfil.dart';
import 'package:tailsgram/widgets/boton_estandar_perfil.dart';
class PerfilUsuarioScreen extends StatelessWidget {
  const PerfilUsuarioScreen({super.key});

  Future<void> toggleSeguirUsuario(String idSeguido) async {
    final idActual = FirebaseAuth.instance.currentUser!.uid;

    final docSeguidor = FirebaseFirestore.instance
        .collection('seguidores')
        .doc(idSeguido)
        .collection('usuarios')
        .doc(idActual);

    final docSeguido = FirebaseFirestore.instance
        .collection('seguidos')
        .doc(idActual)
        .collection('usuarios')
        .doc(idSeguido);

    final docSnapshot = await docSeguidor.get();

    if (docSnapshot.exists) {
      await docSeguidor.delete();
      await docSeguido.delete();
    } else {
      final now = Timestamp.now();
      await docSeguidor.set({'timestamp': now});
      await docSeguido.set({'timestamp': now});
    }
  }

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


  @override
  Widget build(BuildContext context) {
    final String uid = ModalRoute.of(context)!.settings.arguments as String;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final data = snapshot.data!.data() as Map<String, dynamic>;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 198, 241, 214),
            automaticallyImplyLeading: true,
            title: Text(
              data['usuario'] ?? 'Perfil',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(data['fotoPerfilUrl'] ?? ''),    
                          ),
                          SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['nombre'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              Informacion(idPerfil: uid,),
                              BotonEstandarPerfil(texto: 'Enviar mensaje', onPressed: () {
                              Navigator.pushNamed(context, '/chat', arguments: uid);
                            }, ancho: 15),
                          const Divider(thickness: 1, color: Color(0xFFD8D8D8)),
                          const SizedBox(height: 5),],
                          )
                        ],
                      )
                    ],
                  ),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFFD8D8D8)),
                      color: const Color(0xFFEFFDF5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          data['descripcion'] ?? '',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.left, 
                          maxLines: null,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),

                  const Divider(thickness: 1, color: Color(0xFFD8D8D8)),
                  const SizedBox(height: 5),
                  
                  const Divider(thickness: 1, color: Color(0xFFD8D8D8)),
                  const SizedBox(height: 5),
            
                  ListaPublicacionesPerfil(uidPerfil: uid),
                  
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

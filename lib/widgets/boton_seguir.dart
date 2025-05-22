import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tailsgram/widgets/boton_estandar_perfil.dart';

class BotonSeguir extends StatefulWidget {
  final String idSeguido;

  const BotonSeguir({super.key, required this.idSeguido});

  @override
  State<BotonSeguir> createState() => _BotonSeguirState();
}

class _BotonSeguirState extends State<BotonSeguir> {
  bool estaSiguiendo = false;
  bool cargando = true;

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

  @override
  void initState() {
    super.initState();
    verificarEstado();
  }

  Future<void> verificarEstado() async {
    final sigue = await yaSigoA(widget.idSeguido);
    setState(() {
      estaSiguiendo = sigue;
      cargando = false;
    });
  }

  Future<void> toggle() async {
    setState(() {
      cargando = true;
    });

    await toggleSeguirUsuario(widget.idSeguido);
    await verificarEstado();
  }

  @override
  Widget build(BuildContext context) {

    return BotonEstandarPerfil(
      texto: estaSiguiendo ? 'Siguiendo' : 'Seguir',
      onPressed: toggle,
      ancho: 20,
    );
  }
}

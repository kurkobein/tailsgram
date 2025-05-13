import 'package:flutter/material.dart';

class BotonEstandarPerfil extends StatelessWidget {
  final String texto;
  final Function() onPressed;
  final double ancho;
  const BotonEstandarPerfil({
    super.key,
    required this.texto,
    required this.onPressed,
    required this.ancho,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEFFDF5),
        
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: ancho, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: Color(0xFFD8D8D8)),
        ),
        elevation: 0,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
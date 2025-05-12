import 'package:flutter/material.dart';

class BotonEstandar extends StatelessWidget {
  final String texto;
  final Function() onPressed;
  const BotonEstandar({
    super.key,
    required this.texto,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(255, 107, 129, 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Text(texto, style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class PaginaHome extends StatelessWidget {
  const PaginaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 198, 241, 214),
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover,
          height: 35,
        ),
      ),
      body: Center(
        child: Text(
          'home',
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
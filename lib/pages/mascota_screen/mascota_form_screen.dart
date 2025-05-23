import 'package:flutter/material.dart';
import '../../forms/mascota_form.dart';

class MascotaFormScreen extends StatelessWidget {
  const MascotaFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC5F3D6), 
      appBar: AppBar(
        title: const Text('Registro de mascota'),
        centerTitle: true,
        backgroundColor: const Color(0xFFAAF0D1), 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Text(
              'Completa la información de tu mascota',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            MascotaForm(),
          ],
        ),
      ),
    );
  }
}

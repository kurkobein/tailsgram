import 'package:flutter/material.dart';
import '../forms/mascota_form.dart';

class MascotaFormScreen extends StatelessWidget {
  const MascotaFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Mascota')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: MascotaForm(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usuarioController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();

  bool _cargando = false;

  Future<void> _registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _cargando = true);

      try {
        // Crear usuario en Firebase Auth
        final credenciales = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _correoController.text.trim(),
              password: _passwordController.text.trim(),
            );

        final uid = credenciales.user!.uid;

        // Guardar datos adicionales en Firestore
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
          'usuario': _usuarioController.text.trim(),
          'nombre': _nombreController.text.trim(),
          'apellido': _apellidoController.text.trim(),
          'email': _correoController.text.trim(),
          'telefono': _telefonoController.text.trim(),
          'fechaRegistro': FieldValue.serverTimestamp(),
          'descripcion': '',
        });

        // Redirigir al home o perfil
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _usuarioController,
                      decoration: const InputDecoration(labelText: 'Usuario'),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: _apellidoController,
                      decoration: const InputDecoration(labelText: 'Apellido'),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: _correoController,
                      decoration: const InputDecoration(labelText: 'Correo'),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: _telefonoController,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      keyboardType: TextInputType.phone,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration:
                          const InputDecoration(labelText: 'Contraseña'),
                      validator: (value) =>
                          value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                    ),
                    TextFormField(
                      controller: _confirmarPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Confirmar contraseña'),
                      validator: (value) =>
                          value != _passwordController.text
                              ? 'Las contraseñas no coinciden'
                              : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _registrarUsuario,
                      child: const Text('Registrarse'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

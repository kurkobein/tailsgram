import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _cargando = false;

  Future<void> _iniciarSesion() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _cargando = true);

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _correoController.text.trim(),
          password: _passwordController.text.trim(),
        );

        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión: ${e.toString()}')),
        );
      } finally {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _correoController,
                      decoration: const InputDecoration(labelText: 'Correo'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                      validator: (value) =>
                          value == null || value.length < 6
                              ? 'Mínimo 6 caracteres'
                              : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _iniciarSesion,
                      child: const Text('Iniciar sesión'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/registro');
                      },
                      child: const Text('¿No tienes cuenta? Regístrate'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

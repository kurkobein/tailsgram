import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tailsgram/services/storage/storage_foto_usuario.dart';

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
  File? _selectedImage;
  String? _imageFileName;

  Future<void> _seleccionarImagen() async {
    final result = await StorageServiceUsuario().seleccionarImagen();
    if (result != null) {
      setState(() {
        _selectedImage = result.file;
        _imageFileName = result.fileName;
      });
    }
  }


  Future<void> _registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _cargando = true);

      final nombreUsuario = _usuarioController.text.trim();
      final existe = await usuarioExiste(nombreUsuario);

      if (existe) {
        setState(() => _cargando = false);

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El nombre de usuario ya está en uso')),
        );
        return;
      }

      try {
        final credenciales = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _correoController.text.trim(),
              password: _passwordController.text.trim(),
            );

        final uid = credenciales.user!.uid;

        String? imagenUrl;
        if (_selectedImage != null && _imageFileName != null) {
          imagenUrl = await StorageServiceUsuario()
              .subirImagenDesdeFile(_selectedImage!, _imageFileName!);
        }


        await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
          'usuario': _usuarioController.text.trim(),
          'nombre': _nombreController.text.trim(),
          'apellido': _apellidoController.text.trim(),
          'email': _correoController.text.trim(),
          'telefono': _telefonoController.text.trim(),
          'fechaRegistro': FieldValue.serverTimestamp(),
          'fotoPerfilUrl': imagenUrl ?? 'https://qehohrpghlqjkatoyqux.supabase.co/storage/v1/object/public/imagenes/fotos_defecto/default.png',
        });

        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => _cargando = false);
      }
    }
  }

  Future<bool> usuarioExiste(String nombreusuario) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('usuario', isEqualTo: nombreusuario)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  InputDecoration _decoracion(String label) => InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC5F3D6), 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Ingresa tus datos',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _usuarioController,
                  decoration: _decoracion('Nombre de usuario'),
                  validator: (value) =>
                      value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreController,
                  decoration: _decoracion('Nombre'),
                  validator: (value) =>
                      value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _apellidoController,
                  decoration: _decoracion('Apellido'),
                  validator: (value) =>
                      value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _correoController,
                  decoration: _decoracion('Ingrese su correo electronico'),
                  validator: (value) =>
                      value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefonoController,
                  decoration: _decoracion('Teléfono'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _decoracion('Ingrese su Contraseña'),
                  validator: (value) =>
                      value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmarPasswordController,
                  obscureText: true,
                  decoration: _decoracion('Reingrese su Contraseña'),
                  validator: (value) =>
                      value != _passwordController.text
                          ? 'Las contraseñas no coinciden'
                          : null,
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _seleccionarImagen,
                  icon: const Icon(Icons.photo),
                  label: const Text('Seleccionar foto de perfil'),
                ),

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _registrarUsuario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B81), 
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Ingresar',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

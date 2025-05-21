import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tailsgram/services/storage/storage_foto_usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConfiguracionPerfil extends StatefulWidget {
  const ConfiguracionPerfil({super.key});

  @override
  State<ConfiguracionPerfil> createState() => _ConfiguracionPerfilState();
}

class _ConfiguracionPerfilState extends State<ConfiguracionPerfil> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _correoController = TextEditingController();
  final _fotoController = TextEditingController();
  File? _selectedImage;
  String? _imageFileName;
  bool _cargando = true;
  late DocumentReference usuarioRef;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    usuarioRef = FirebaseFirestore.instance.collection('usuarios').doc(uid);
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final doc = await usuarioRef.get();

    if (!doc.exists || doc.data() == null) {
      setState(() => _cargando = false);
      return;
    }

    final data = doc.data()! as Map<String, dynamic>;

    _fotoController.text = data['fotoPerfilUrl'] ?? '';
    _usuarioController.text = data['usuario'] ?? '';
    _nombreController.text = data['nombre'] ?? '';
    _apellidoController.text = data['apellido'] ?? '';
    _telefonoController.text = data['telefono'] ?? '';
    _descripcionController.text = data['descripcion'] ?? '';
    _correoController.text = FirebaseAuth.instance.currentUser?.email ?? '';

    setState(() => _cargando = false);
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageFileName = pickedFile.name;
      });
    }
  }

  Future<bool> usuarioExiste(String nombreusuario) async {
    final uidActual = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('usuario', isEqualTo: nombreusuario)
        .get();

    for (var doc in snapshot.docs) {
      if (doc.id != uidActual) {
        return true; // Existe otro usuario con ese nombre
      }
    }
    return false; // Solo existes tú, o no existe
  }


  Future<void> _guardarCambios() async {
    final nombreUsuario = _usuarioController.text.trim();
    final existe = await usuarioExiste(nombreUsuario);

    if (existe) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre de usuario ya está en uso')),
      );
      return;
    }

    if (_selectedImage != null && _imageFileName != null) {
      final url = await StorageServiceUsuario().subirImagenDesdeFile(
        _selectedImage!,
        _imageFileName!,
      );

      if (url != null) {
        try {
          await usuarioRef.set({
            'fotoPerfilUrl': url,
          }, SetOptions(merge: true));
          _fotoController.text = url;
          setState(() {
            _selectedImage = null;
          });
        } catch (e) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir la imagen')),
          );
          return;
        }
      }
    }

    if (_formKey.currentState!.validate()) {
      await usuarioRef.set({
        'usuario': nombreUsuario,
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'fotoPerfilUrl': _fotoController.text.trim(),
      }, SetOptions(merge: true));

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
    }
  }


  InputDecoration _decoracion(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: const Color(0xFFC5F3D6),
      appBar: AppBar(
        title: const Text('Ajustes de perfil'),
        centerTitle: true,
        backgroundColor: const Color(0xFFAAF0D1),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (_fotoController.text.isNotEmpty
                            ? NetworkImage(_fotoController.text)
                            : const NetworkImage('https://example.com/default_avatar.png')) as ImageProvider,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black87),
                    onPressed: _seleccionarImagen,
                  ),
                ],
              ),

              TextFormField(
                controller: _usuarioController,
                decoration: _decoracion('Usuario'),
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
                decoration: _decoracion('Correo'),
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: _decoracion('Teléfono'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: _decoracion('Descripción'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B81),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: _guardarCambios,
                child: const Text('Guardar cambios', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  // ignore: use_build_context_synchronously
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Cerrar sesión', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/mascota-form');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Agregar mascota'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/mascota-list');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Lista de mascotas'),
              ),
              ElevatedButton(
                onPressed: () {
                  _mostrarDialogoConfirmacion(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white,),
                child: const Text('Eliminar cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _mostrarDialogoConfirmacion(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa tu correo y contraseña para eliminar tu cuenta.'),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final email = emailController.text.trim();
              final password = passwordController.text;

              try {
                final credential = EmailAuthProvider.credential(
                  email: email,
                  password: password,
                );

                final user = FirebaseAuth.instance.currentUser;
                await user?.reauthenticateWithCredential(credential);

                // ✅ Eliminar publicaciones del usuario
                final uid = user?.uid;
                if (uid != null) {
                  final publicaciones = await FirebaseFirestore.instance
                      .collection('publicaciones')
                      .where('uid', isEqualTo: uid)
                      .get();

                  for (final doc in publicaciones.docs) {
                    await doc.reference.delete();
                  }
                }
                
                await FirebaseFirestore.instance.collection('usuarios').doc(uid).delete();
                await user?.delete();

                // ignore: use_build_context_synchronously
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);

              } catch (e) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error al eliminar la cuenta.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

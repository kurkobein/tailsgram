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
      // Maneja el caso cuando no hay datos
      setState(() => _cargando = false);
      return;
    }

    final data = doc.data()! as Map<String, dynamic>;

    _usuarioController.text = data['usuario'] ?? '';
    _nombreController.text = data['nombre'] ?? '';
    _apellidoController.text = data['apellido'] ?? '';
    _telefonoController.text = data['telefono'] ?? '';
    _descripcionController.text = data['descripcion'] ?? '';
    _correoController.text = FirebaseAuth.instance.currentUser?.email ?? '';

    setState(() => _cargando = false);
  }


  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      await usuarioRef.set({
        'usuario': _usuarioController.text.trim(),
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
      }, SetOptions(merge: true)); // 👈 esto evita el error

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes de perfil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usuarioController,
                decoration: const InputDecoration(labelText: 'usuario'),
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
                enabled: false, // 🔒 solo lectura
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(255, 107, 129, 1),
                                                foregroundColor:Colors.white),
                onPressed: _guardarCambios,
                child: const Text('Guardar cambios'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
                                                foregroundColor:Colors.white),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Cerrar sesión'),
                
              ),
              Row(
                children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
                                                foregroundColor:Colors.white),
                onPressed: () async {
                  Navigator.pushNamed(context, '/mascota-form');

                },
                child: const Text('Agregar mascotas'),
                
              ),
              
                ],
              
              ),
              Row(children: [
                
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
                                                foregroundColor:Colors.white),
                onPressed: () async {
                  Navigator.pushNamed(context, '/mascota-list');
                },
                child: const Text('lista_mascotas'),
                
              ),
            ])
            ],
          ),
        ),
      ),
    );
  }
}

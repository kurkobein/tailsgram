import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tailsgram/widgets/info_perfil_widget.dart';
import 'package:tailsgram/widgets/publicaciones_perfil.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _fotoController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    final String uidActual = FirebaseAuth.instance.currentUser!.uid;
    if (_cargando) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 198, 241, 214),
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _usuarioController.text.isNotEmpty ? _usuarioController.text : 'Nombre',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 35,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey,
                        backgroundImage: _fotoController.text.isNotEmpty
                            ? NetworkImage(_fotoController.text)
                            : null,    
                      ),
                      SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_nombreController.text.isNotEmpty ? _nombreController.text : 'Nombre', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Informacion(idPerfil: FirebaseAuth.instance.currentUser!.uid),
                        ],
                      )
                    ],
                  )
                ],
              ),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFFD8D8D8)),
                  color: const Color(0xFFEFFDF5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      _descripcionController.text,
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.left, 
                      maxLines: null,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              const Divider(thickness: 1, color: Color(0xFFD8D8D8)),
              const SizedBox(height: 5),
              const Text(
                'Publicaciones',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Cambiamos el Expanded por un Container con un height fijo o lo eliminamos
              // ya que SingleChildScrollView no puede tener hijos con restricciones flexibles
              ListaPublicacionesPerfil(uidPerfil: uidActual),
            ],
          ),
        ),
      ),
    );
  }
}
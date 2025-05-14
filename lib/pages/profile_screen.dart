import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tailsgram/widgets/info_perfil_widget.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
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

    _nombreController.text = data['nombre'] ?? '';
    _apellidoController.text = data['apellido'] ?? '';
    _telefonoController.text = data['telefono'] ?? '';
    _descripcionController.text = data['descripcion'] ?? '';
    _correoController.text = FirebaseAuth.instance.currentUser?.email ?? '';

    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 198, 241, 214),
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Nombre alineado a la izquierda
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _nombreController.text.isNotEmpty ? _nombreController.text : 'Nombre',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ),
            // Logo centrado
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

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    //AQUI DEBE IR LA FOTO DEL USUARIO🔥🔥🔥🔥🔥
                    CircleAvatar(
                      radius: 25,
                        backgroundColor: Colors.grey,
                        child: Text(_nombreController.text.isNotEmpty ? _nombreController.text[0].toUpperCase() : '', style: const TextStyle(color: Colors.white)),
                      ),
                      SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_nombreController.text.isNotEmpty ? _nombreController.text : 'Nombre', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Informacion(),
                      ],
                    )
                  ],
                )
              ],
            ),
            Container(
              height: 150,
              width: double.infinity, // Este hace que el contenedor ocupe todo el ancho disponible
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0xFFD8D8D8)),
                color: const Color(0xFFEFFDF5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: double.infinity, // Esto hace que el Text ocupe todo el ancho disponible dentro del padding
                  child: Text(
                    _descripcionController.text,
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.left, // o center, justify, right según lo que quieras
                    maxLines: null, // Permite múltiples líneas si el texto es largo
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

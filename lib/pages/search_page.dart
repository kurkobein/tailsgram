import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BuscadorUsuarios extends StatefulWidget {
  const BuscadorUsuarios({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BuscadorUsuariosState createState() => _BuscadorUsuariosState();
}

class _BuscadorUsuariosState extends State<BuscadorUsuarios> {
  String _textoBusqueda = '';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Buscar Usuarios')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar por nombre de usuario',
                border: OutlineInputBorder(),
              ),
              onChanged: (valor) {
                setState(() {
                  _textoBusqueda = valor.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: buscarUsuarios(_textoBusqueda),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No se encontraron usuarios.'));
                }
                final String uidActual = FirebaseAuth.instance.currentUser!.uid;
                final usuarios = snapshot.data!.docs;
                final usuariosFiltrados = usuarios.where((u) => u.id != uidActual).toList();

                return ListView.builder(
                  itemCount: usuariosFiltrados.length,
                  itemBuilder: (context, index) {
                    final usuario = usuariosFiltrados[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          usuario['fotoPerfilUrl'] ??
                          'https://qehohrpghlqjkatoyqux.supabase.co/storage/v1/object/public/imagenes/fotos_defecto/default.png',
                        ),
                      ),
                      title: Text(usuario['usuario'] ?? 'Sin usuario'),
                      subtitle: Text(usuario['nombre'] ?? ''),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/perfil-usuario',
                          arguments: usuario.id,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> buscarUsuarios(String texto) {
    if (texto.isEmpty) {
      return FirebaseFirestore.instance.collection('usuarios').snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('usuarios')
          .where('usuario', isGreaterThanOrEqualTo: texto)
          .where('usuario', isLessThan: '${texto}z')
          .snapshots();
    }
  }
}

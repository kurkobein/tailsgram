import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BuscadorUsuarios extends StatefulWidget {
  @override
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
                labelText: 'Buscar por nombre',
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
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return Center(child: Text('No se encontraron usuarios.'));

                final usuarios = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = usuarios[index];
                    return ListTile(
                      title: Text(usuario['nombre'] ?? 'Sin nombre'),
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
          .where('nombre', isGreaterThanOrEqualTo: texto)
          .where('nombre', isLessThan: texto + 'z')
          .snapshots();
    }
  }
}

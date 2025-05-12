import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MascotaListScreen extends StatelessWidget {
  const MascotaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final mascotasRef = FirebaseFirestore.instance
        .collection('mascotas')
        .where('duenioId', isEqualTo: uid);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Mascotas')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: mascotasRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text('No tienes mascotas registradas.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final mascota = docs[index].data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(mascota['nombre'] ?? 'Sin nombre'),
                      subtitle: Text('Raza: ${mascota['raza'] ?? 'Desconocida'}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          '/mascota-detalle',
                          arguments: docs[index],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          /*Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
                                                foregroundColor:Colors.white),
                onPressed: () async {
                  Navigator.pushReplacementNamed(context, '/perfil');
                },
                child: const Text('atras'),
                
                
              ),
          ),*/
        ],
      ),
    );
  }
}

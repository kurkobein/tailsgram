import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaginaPerfil extends StatefulWidget {
  const PaginaPerfil({super.key});

  @override
  State<PaginaPerfil> createState() => _PaginaPerfilState();
}

class _PaginaPerfilState extends State<PaginaPerfil> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Correo: ${user?.email ?? "No disponible"}'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text('Nombre: ${user?.displayName ?? "No establecido"}'),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar nombre',
                  onPressed: () => _editarNombre(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/sign-in');
              },
              child: const Text('Cerrar sesión'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _mostrarDialogoConfirmacion(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar cuenta'),
            ),
          ],
        ),
      ),
    );
  }

  void _editarNombre(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final TextEditingController nombreController =
        TextEditingController(text: user?.displayName ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar nombre'),
        content: TextField(
          controller: nombreController,
          decoration: const InputDecoration(labelText: 'Nuevo nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nuevoNombre = nombreController.text.trim();
              if (nuevoNombre.isNotEmpty) {
                await user?.updateDisplayName(nuevoNombre);
                await user?.reload();

                // 🔄 Actualizar nombre en publicaciones
                final publicaciones = await FirebaseFirestore.instance
                    .collection('publicaciones')
                    .where('uid', isEqualTo: user?.uid)
                    .get();

                for (final doc in publicaciones.docs) {
                  await doc.reference.update({'nombreUsuario': nuevoNombre});
                }

                setState(() {}); // Refresca la pantalla
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
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
            child: const Text('Eliminar'),
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
                await user?.delete();

                Navigator.pushNamedAndRemoveUntil(context, '/sign-in', (_) => false);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error al eliminar la cuenta.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MascotaService {
  final _db = FirebaseFirestore.instance;

  final _uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> crearMascota({
    required String nombre,
    required String raza,
    required int edad,
    required String genero,
    required String descripcion,
    required String imagenUrl,
  }) async {
    await _db.collection('mascotas').add({
      'nombre': nombre,
      'raza': raza,
      'edad': edad,
      'genero': genero,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
      'duenoId': _uid,
      'fechaCreacion': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> obtenerMascotasDelUsuario() {
    return _db
        .collection('mascotas')
        .where('duenoId', isEqualTo: _uid)
        .snapshots();
  }

  Future<void> actualizarMascota({
    required String id,
    required String nombre,
    required String raza,
    required int edad,
    required String genero,
    required String descripcion,
    required String imagenUrl,
  }) async {
    await editarMascota(id, {
      'nombre': nombre,
      'raza': raza,
      'edad': edad,
      'genero': genero,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
    });
  }

  Future<void> editarMascota(String mascotaId, Map<String, dynamic> nuevosDatos) async {
    await _db.collection('mascotas').doc(mascotaId).update(nuevosDatos);
  }

  Future<void> eliminarMascota(String mascotaId) async {
    await _db.collection('mascotas').doc(mascotaId).delete();
  }
}

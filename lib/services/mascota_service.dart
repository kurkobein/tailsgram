// Importamos Firestore (base de datos) y Firebase Auth (para saber qué usuario está logueado)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MascotaService {
  // Referencia a Firestore
  final _db = FirebaseFirestore.instance;

  // UID del usuario actual autenticado
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  // 🔹 Crear una nueva mascota 
  Future<void> crearMascota({
    required String nombre,
    required String raza,
    required int edad,
    required String genero,
    required String descripcion,
    required String imagenUrl,
  }) async {
    // Guardamos la mascota en la colección 'mascotas'
    await _db.collection('mascotas').add({
      'nombre': nombre,
      'raza': raza,
      'edad': edad,
      'genero': genero,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
      'duenioId': _uid, // Asociamos la mascota al usuario actual
    });
  }

  // Obtener en tiempo real las mascotas del usuario actual
  Stream<QuerySnapshot> obtenerMascotasDelUsuario() {
    return _db
        .collection('mascotas')                     // de la colección 'mascotas'
        .where('duenioId', isEqualTo: _uid)         // solo donde duenioId == UID actual
        .snapshots();                               // escuchar cambios en tiempo real
  }

  // Editar los datos de una mascota ya creada
  Future<void> editarMascota(String mascotaId, Map<String, dynamic> nuevosDatos) async {
    await _db.collection('mascotas').doc(mascotaId).update(nuevosDatos);
  }

  //  Eliminar una mascota
  Future<void> eliminarMascota(String mascotaId) async {
    await _db.collection('mascotas').doc(mascotaId).delete();
  }
}

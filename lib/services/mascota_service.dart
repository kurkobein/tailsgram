import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';

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
    required double lat, 
    required double lng, 
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
      'ubicacion' : GeoPoint(lat,lng)
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


  Future<List<Map<String, dynamic>>> obtenerMascotasCercanasNoVistas(
      LatLng ubicacionUsuario) async {
    final todas = await _db.collection('mascotas').get();

    final likesPrevios = await _db
        .collection('likes')
        .where('usuarioId', isEqualTo: _uid)
        .get();

    final yaVistas = likesPrevios.docs
        .map((doc) => doc['mascotaId'] as String)
        .toSet();

    final distancia = Distance();

    final mascotasFiltradas = todas.docs.where((doc) {
      final data = doc.data();
      final id = doc.id;

      if (data['duenioId'] == _uid) return false;

      if (yaVistas.contains(id)) return false;

      final geo = data['ubicacion'];
      if (geo == null) return false;

      final distanciaKm = distancia.as(
        LengthUnit.Kilometer,
        ubicacionUsuario,
        LatLng(geo.latitude, geo.longitude),
      );

      return distanciaKm <= 5;
    }).map((doc) => {...doc.data(), 'id': doc.id}).toList();

    return mascotasFiltradas;
  }
}



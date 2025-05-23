import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  /// Guarda un like o dislike hacia una mascota (se guarda con await LikeService().registrarAccion(mascotaId, "like o dislike");
  Future<void> registrarAccion(String mascotaId, String accion) async {
    // Evita duplicados
    final yaExiste = await yaInteractuoCon(mascotaId);
    if (yaExiste) return;

    // Guardar like/dislike
    await _db.collection('likes').add({
      'usuarioId': _uid,
      'mascotaId': mascotaId,
      'accion': accion, // "like" o "dislike"
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Si fue un like, verifica si hay match
    if (accion == "like") {
      await _verificarYCrearMatch(mascotaId);
    }
  }

  /// Verifica si esta mascota ya recibió like del otro lado
  Future<void> _verificarYCrearMatch(String mascotaId) async {
    // Buscar si la otra mascota ya dio like al usuario actual
    final inverso = await _db
        .collection('likes')
        .where('usuarioId', isEqualTo: mascotaId) // la otra persona
        .where('mascotaId', isEqualTo: _uid)      // dio like a ti
        .where('accion', isEqualTo: 'like')
        .get();

    if (inverso.docs.isNotEmpty) {
      // Evitar duplicados de match
      final yaExiste = await _db
          .collection('matches')
          .where('mascota1Id', whereIn: [_uid, mascotaId])
          .where('mascota2Id', whereIn: [_uid, mascotaId])
          .get();

      if (yaExiste.docs.isEmpty) {
        await _db.collection('matches').add({
          'mascota1Id': _uid,
          'mascota2Id': mascotaId,
          'fechaMatch': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  /// Verifica si el usuario ya interactuó (like/dislike) con la mascota
  Future<bool> yaInteractuoCon(String mascotaId) async {
    final resultado = await _db
        .collection('likes')
        .where('usuarioId', isEqualTo: _uid)
        .where('mascotaId', isEqualTo: mascotaId)
        .get();
    return resultado.docs.isNotEmpty;
  }

  /// Devuelve los IDs de las mascotas que este usuario ha likeado
  Future<List<String>> obtenerMascotasLikeadas() async {
    final snapshot = await _db
        .collection('likes')
        .where('usuarioId', isEqualTo: _uid)
        .where('accion', isEqualTo: 'like')
        .get();

    return snapshot.docs
        .map((doc) => doc['mascotaId'] as String)
        .toList();
  }
}

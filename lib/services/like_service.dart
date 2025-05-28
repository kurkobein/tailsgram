import 'package:cloud_firestore/cloud_firestore.dart';

class LikeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Registra un like o dislike desde una mascota hacia otra
  Future<void> registrarAccion({
    required String desdeMascotaId,
    required String haciaMascotaId,
    required String accion, // 'like' o 'dislike'
    void Function()? onMatch,
  }) async {
    // Verificar si ya interactuó
    final yaExiste = await yaInteractuoCon(desdeMascotaId, haciaMascotaId);
    if (yaExiste) return;

    // Registrar la acción
    await _db.collection('likes').add({
      'usuarioId': desdeMascotaId,
      'mascotaId': haciaMascotaId,
      'accion': accion,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Si fue un like, verificar si el otro también dio like
    if (accion == 'like') {
      final inverso = await _db
          .collection('likes')
          .where('usuarioId', isEqualTo: haciaMascotaId)
          .where('mascotaId', isEqualTo: desdeMascotaId)
          .where('accion', isEqualTo: 'like')
          .get();

      if (inverso.docs.isNotEmpty) {
        // Verificar si ya existe el match
        final yaExisteMatch = await _db
            .collection('matchs')
            .where('mascota1Id', whereIn: [desdeMascotaId, haciaMascotaId])
            .where('mascota2Id', whereIn: [desdeMascotaId, haciaMascotaId])
            .get();

        if (yaExisteMatch.docs.isEmpty) {
          await _db.collection('matchs').add({
            'mascota1Id': desdeMascotaId,
            'mascota2Id': haciaMascotaId,
            'fechaMatch': FieldValue.serverTimestamp(),
          });

          if (onMatch != null) {
            onMatch();
          }
        }
      }
    }
  }

  /// Verifica si ya se registró una interacción entre las dos mascotas
  Future<bool> yaInteractuoCon(String desdeId, String haciaId) async {
    final resultado = await _db
        .collection('likes')
        .where('usuarioId', isEqualTo: desdeId)
        .where('mascotaId', isEqualTo: haciaId)
        .get();
    return resultado.docs.isNotEmpty;
  }
}

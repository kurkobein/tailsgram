import 'package:cloud_firestore/cloud_firestore.dart';

class LikeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> registrarAccion({
    required String desdeMascotaId,
    required String haciaMascotaId,
    required String accion,
    void Function()? onMatch,
  }) async {
    final yaExiste = await yaInteractuoCon(desdeMascotaId, haciaMascotaId);
    if (yaExiste) return;

    await _db.collection('likes').add({
      'usuarioId': desdeMascotaId,
      'mascotaId': haciaMascotaId,
      'accion': accion,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (accion == 'like') {
      final inverso = await _db
          .collection('likes')
          .where('usuarioId', isEqualTo: haciaMascotaId)
          .where('mascotaId', isEqualTo: desdeMascotaId)
          .where('accion', isEqualTo: 'like')
          .get();

      if (inverso.docs.isNotEmpty) {
        final yaExisteMatch = await _db
            .collection('matches') 
            .where('mascota1Id', whereIn: [desdeMascotaId, haciaMascotaId])
            .where('mascota2Id', whereIn: [desdeMascotaId, haciaMascotaId])
            .get();

        if (yaExisteMatch.docs.isEmpty) {
          await _db.collection('matches').add({
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

  Future<bool> yaInteractuoCon(String desdeId, String haciaId) async {
    final resultado = await _db
        .collection('likes')
        .where('usuarioId', isEqualTo: desdeId)
        .where('mascotaId', isEqualTo: haciaId)
        .get();
    return resultado.docs.isNotEmpty;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class MapEventService {
  final _db = FirebaseFirestore.instance;

  /// Consulta todos los eventos y retorna solo los que estén a 10 km o menos
  Future<List<Map<String, dynamic>>> obtenerEventosCercanos(LatLng ubicacion) async {
  final snapshot = await _db.collection('eventos').get();
  final distancia = Distance();

  final eventosFiltrados = snapshot.docs.where((doc) {
    final data = doc.data();

    if (!data.containsKey('ubicacion')) return false;

    final dynamic rawGeo = data['ubicacion'];

    if (rawGeo is! GeoPoint) return false;

    final LatLng puntoEvento = LatLng(rawGeo.latitude, rawGeo.longitude);

    final distanciaKm = distancia.as(LengthUnit.Kilometer, ubicacion, puntoEvento);

    return distanciaKm <= 10.0;
  }).map((doc) => {
    ...doc.data(),
    'id': doc.id,
  }).toList();

  return eventosFiltrados;
}

  
}

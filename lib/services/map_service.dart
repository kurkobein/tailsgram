import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';


class FuncionesMapa {
  static Future<LatLng?> solicitarUbicacion(Function(bool) onPermisoDenegado) async {
    final permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      final solicitado = await Geolocator.requestPermission();
      if (solicitado == LocationPermission.deniedForever ||
          solicitado == LocationPermission.denied) {
        onPermisoDenegado(true);
        return null;
      }
    }

    final posicion = await Geolocator.getCurrentPosition();
    onPermisoDenegado(false);
    return LatLng(posicion.latitude, posicion.longitude);
  }

  static Future<void> abrirAjustesSiNecesario() async {
    final permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/map_service.dart';



class PaginaMapa extends StatefulWidget {
  const PaginaMapa({super.key});

  @override
  State<PaginaMapa> createState() => _PaginaMapaState();
}

class _PaginaMapaState extends State<PaginaMapa> {
  LatLng? _ubicacionActual;
  bool _permisoDenegado = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _cargarUbicacion();
  }

  void _cargarUbicacion() async {
    final ubicacion = await FuncionesMapa.solicitarUbicacion((denegado) {
      if (mounted) setState(() => _permisoDenegado = denegado);
    });

    if (ubicacion != null && mounted) {
      setState(() => _ubicacionActual = ubicacion);
    }
  }
  
  void _centrarEnMiUbicacion() {
    if (_ubicacionActual != null) {
      _mapController.move(_ubicacionActual!, 18);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        backgroundColor: const Color(0xFFAAF0D1),
      ),
      body: _permisoDenegado
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 50, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text(
                    'Debes habilitar los permisos de ubicación\npara usar el mapa.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () async {
                      await FuncionesMapa.abrirAjustesSiNecesario();
                      final nuevaUbicacion =
                          await FuncionesMapa.solicitarUbicacion((denegado) {
                        if (mounted) setState(() => _permisoDenegado = denegado);
                      });

                      if (nuevaUbicacion != null && mounted) {
                        setState(() => _ubicacionActual = nuevaUbicacion);
                      }
                    },
                    child: const Text(
                      'Volver a intentar',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : _ubicacionActual == null
              ?  Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _ubicacionActual!,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(markers: [
                      Marker(
                        point: _ubicacionActual!,
                        width: 200,
                        height: 200,
                        child:Column(
                          children: const[
                            Icon(Icons.person_pin_circle, color: Colors.blue,size:80),
                            Text('Mi Ubicacion',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
                          ],
                        )
                      )
                    ])
                  ],
                ),
      floatingActionButton: _ubicacionActual == null
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              onPressed: _centrarEnMiUbicacion,
              tooltip: 'Ir a mi ubicación',
              child: const Icon(Icons.my_location),
            ),
    );
  }
}

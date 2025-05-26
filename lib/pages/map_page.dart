import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/map_service.dart';
import '../services/map_event_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PaginaMapa extends StatefulWidget {
  const PaginaMapa({super.key});

  @override
  State<PaginaMapa> createState() => _PaginaMapaState();
}

class _PaginaMapaState extends State<PaginaMapa> {
  LatLng? _ubicacionActual;
  bool _permisoDenegado = false;
  final MapController _mapController = MapController();
  List<Map<String, dynamic>> _eventosCercanos = [];

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
    final eventos = await MapEventService().obtenerEventosCercanos(ubicacion!);
    if (mounted) {
      setState(() => _eventosCercanos = eventos);
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
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    
                   MarkerLayer(
  markers: [
    // marcador del usuario
    Marker(
      point: _ubicacionActual!,
      width: 150,
      height: 80,
      child: Column(
        children: const [
          Icon(Icons.person_pin_circle, color: Colors.blue, size: 50),
          Text('Mi ubicación',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
    // marcadores de eventos
    ..._eventosCercanos.map((evento) {
      final geo = evento['ubicacion'] as GeoPoint;
      return Marker(
        point: LatLng(geo.latitude, geo.longitude),
        width: 160,
        height: 80,
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(
                            context,
                            '/evento-detalle',
                            arguments: evento,
                          );
          },
          child: Column(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 40),
              Text(
                evento['titulo'] ?? 'Evento',
                style: const TextStyle(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }),
  ],
)

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

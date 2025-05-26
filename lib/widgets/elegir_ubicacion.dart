import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SeleccionarUbicacion extends StatefulWidget {
  const SeleccionarUbicacion({super.key});

  @override
  State<SeleccionarUbicacion> createState() => _SeleccionarUbicacionState();
}

class _SeleccionarUbicacionState extends State<SeleccionarUbicacion> {
  LatLng? _ubicacionSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar ubicación')),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(-33.4489, -70.6693), // Santiago, por ejemplo
          zoom: 13.0,
          onTap: (tapPosition, point) {
            setState(() {
              _ubicacionSeleccionada = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          if (_ubicacionSeleccionada != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _ubicacionSeleccionada!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, size: 40, color: Colors.red),
                )
              ],
            ),
        ],
      ),
      floatingActionButton: _ubicacionSeleccionada == null
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, _ubicacionSeleccionada);
              },
            ),
    );
  }
}

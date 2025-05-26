import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EventoDetalleScreen extends StatelessWidget {
  const EventoDetalleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;

    if (args == null || args is! Map<String, dynamic>) {
      return const Scaffold(
        body: Center(child: Text('Evento no válido')),
      );
    }

    final evento = args;
    final String titulo = evento['titulo'] ?? 'Sin título';
    final String descripcion = evento['descripcion'] ?? 'Sin descripción';
    final Timestamp? fechaHora = evento['fechaHora'];
    final GeoPoint? geo = evento['ubicacion'];

    final String fechaFormateada = fechaHora != null
        ? '${fechaHora.toDate().day}/${fechaHora.toDate().month}/${fechaHora.toDate().year} '
          '${fechaHora.toDate().hour}:${fechaHora.toDate().minute.toString().padLeft(2, '0')}'
        : 'Fecha no definida';

    final LatLng? ubicacion = geo != null ? LatLng(geo.latitude, geo.longitude) : null;

    final mapController = MapController();

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: const Color(0xFFAAF0D1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Text('Título',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(titulo, style: TextStyle(fontSize: 16)),

            const SizedBox(height: 20),
            Text('Fecha y hora',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(fechaFormateada, style: TextStyle(fontSize: 16)),

            const SizedBox(height: 20),
            Text('Descripción',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(descripcion, style: TextStyle(fontSize: 16)),

            const SizedBox(height: 20),
            Text('Ubicación',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),


            if (ubicacion != null)
              Container(
                margin:  EdgeInsets.all(10),
                padding: EdgeInsets.all(8.0), 
                height: 250,
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: ubicacion,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: ubicacion,
                          width: 80,
                          height: 80,
                          child: const Icon(Icons.location_on, size: 50, color: Colors.red),
                        )
                      ],
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

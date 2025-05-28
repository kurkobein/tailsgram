import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class BuscarEventosScreen extends StatefulWidget {
  const BuscarEventosScreen({super.key});

  @override
  State<BuscarEventosScreen> createState() => _BuscarEventosScreenState();
}

class _BuscarEventosScreenState extends State<BuscarEventosScreen> {
  List<Map<String, dynamic>> _eventosCercanos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _buscarEventos();
  }

  Future<void> _buscarEventos() async {
    try {
      final posicion = await Geolocator.getCurrentPosition();
      final usuario = LatLng(posicion.latitude, posicion.longitude);

      final snapshot = await FirebaseFirestore.instance.collection('eventos').get();
      final distancia = Distance();

      final eventosFiltrados = snapshot.docs.where((doc) {
        final geo = doc['ubicacion'];
        if (geo == null) return false;

        final eventoLatLng = LatLng(geo.latitude, geo.longitude);
        final dist = distancia.as(LengthUnit.Kilometer, usuario, eventoLatLng);

        return dist <= 5;
      }).map((doc) => {
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }).toList();

      setState(() {
        _eventosCercanos = eventosFiltrados;
        _cargando = false;
      });
    } catch (e) {
      print('Error al obtener eventos: $e');
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos Cercanos'),
        backgroundColor: const Color(0xFFAAF0D1),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _eventosCercanos.isEmpty
              ? const Center(child: Text('No hay eventos cercanos.'))
              : ListView.builder(
                  itemCount: _eventosCercanos.length,
                  itemBuilder: (context, index) {
                    final evento = _eventosCercanos[index];
                    final fechaHora = (evento['fechaHora'] as Timestamp).toDate();
                    return ListTile(
                      title: Text(evento['titulo'] ?? 'Sin título'),
                      subtitle: Text(
                        '${evento['descripcion'] ?? ''}\n${fechaHora.day}/${fechaHora.month}/${fechaHora.year} - ${fechaHora.hour}:${fechaHora.minute.toString().padLeft(2, '0')}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/evento-detalle',
                          arguments: evento,
                        );
                      },
                    );
                  },
                ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:tailsgram/widgets/elegir_ubicacion.dart';

class CrearEvento extends StatefulWidget {
  final Function(String titulo, String descripcion, DateTime fechaHora) onGuardar;

  const CrearEvento({super.key, required this.onGuardar});

  @override
  State<CrearEvento> createState() => _CrearEvento();
}

class _CrearEvento extends State<CrearEvento> {
  final _formKey = GlobalKey<FormState>();
  String _titulo = '';
  String _descripcion = '';
  DateTime? _fechaHora;
  String _ubicacion = '';
  bool _guardando = false;

  void _seleccionarFechaHora() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (fecha != null) {
      final TimeOfDay? hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (hora != null) {
        setState(() {
          _fechaHora = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
        });
      }
    }
  }

  LatLng? _latLngSeleccionado;

  Future<void> _irSeleccionarUbicacion() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SeleccionarUbicacion()),
    );

    if (resultado != null && resultado is LatLng) {
      setState(() {
        _latLngSeleccionado = resultado;
      });
    }
  }


  Future<void> _guardarEvento() async {
    if (_formKey.currentState!.validate() && _fechaHora != null && _latLngSeleccionado != null) {
      _formKey.currentState!.save();

      await FirebaseFirestore.instance.collection('eventos').add({
        'titulo': _titulo,
        'descripcion': _descripcion,
        'fechaHora': _fechaHora,
        'ubicacion': GeoPoint(_latLngSeleccionado!.latitude, _latLngSeleccionado!.longitude),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento guardado')),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Evento'),
        backgroundColor: const Color(0xFFAAF0D1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value == null || value.isEmpty ? 'Ingresa un título' : null,
                onSaved: (value) => _titulo = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Ingresa una descripción' : null,
                onSaved: (value) => _descripcion = value!,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _seleccionarFechaHora,
                child: Text(_fechaHora == null
                    ? 'Seleccionar fecha y hora'
                    : '${_fechaHora!.day}/${_fechaHora!.month}/${_fechaHora!.year} ${_fechaHora!.hour}:${_fechaHora!.minute.toString().padLeft(2, '0')}'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _irSeleccionarUbicacion,
                icon: const Icon(Icons.map),
                label: Text(_latLngSeleccionado == null
                    ? 'Seleccionar ubicación en el mapa'
                    : 'Ubicación seleccionada: ${_latLngSeleccionado!.latitude.toStringAsFixed(4)}, ${_latLngSeleccionado!.longitude.toStringAsFixed(4)}'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _guardarEvento,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Evento'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

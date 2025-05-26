import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:tailsgram/widgets/boton_estandar.dart';
import 'package:tailsgram/widgets/elegir_ubicacion.dart';
import 'package:tailsgram/widgets/boton_estandar.dart';

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
              SizedBox(height: 16),
              Text('Nombre del evento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextFormField(
                validator: (value) => value == null || value.isEmpty ? 'Ingrese un nombre' : null,
                onSaved: (value) => _titulo = value!,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  labelText: 'Nombre del evento'
                ),
              ),
              SizedBox(height: 26),
              Text('Descripcion el evento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextFormField(
                onSaved: (value) => _descripcion = value!,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  labelText: 'Descripcion del evento',
                ),
              ),
              const SizedBox(height: 16),
              BotonEstandar(
                texto: '',
                onPressed: _seleccionarFechaHora,
                child: Text(
                  _fechaHora == null
                    ? 'Seleccionar fecha y hora'
                    : '${_fechaHora!.day}/${_fechaHora!.month}/${_fechaHora!.year} ${_fechaHora!.hour}:${_fechaHora!.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              BotonEstandar(
                texto: 'asdasdasd',
                onPressed: _irSeleccionarUbicacion,
                child: Text(_latLngSeleccionado == null
                    ? 'Seleccionar ubicación en el mapa'
                    : 'Ubicación seleccionada: ${_latLngSeleccionado!.latitude.toStringAsFixed(4)}, ${_latLngSeleccionado!.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(color: Colors.white),
                  )
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

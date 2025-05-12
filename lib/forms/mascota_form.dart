import 'package:flutter/material.dart';
import '../services/mascota_service.dart';

class MascotaForm extends StatefulWidget {
  const MascotaForm({super.key});

  @override
  State<MascotaForm> createState() => _MascotaFormState();
}

class _MascotaFormState extends State<MascotaForm> {
  final _nombreController = TextEditingController();
  final _razaController = TextEditingController();
  final _edadController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _imagenUrlController = TextEditingController();

  String _generoSeleccionado = 'Macho';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nombreController,
            decoration: const InputDecoration(labelText: 'Nombre'),
            validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
          ),
          TextFormField(
            controller: _razaController,
            decoration: const InputDecoration(labelText: 'Raza'),
            validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
          ),
          TextFormField(
            controller: _edadController,
            decoration: const InputDecoration(labelText: 'Edad'),
            keyboardType: TextInputType.number,
            validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
          ),
          DropdownButtonFormField<String>(
            value: _generoSeleccionado,
            items: ['Macho', 'Hembra']
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _generoSeleccionado = value);
            },
            decoration: const InputDecoration(labelText: 'Género'),
          ),
          TextFormField(
            controller: _descripcionController,
            decoration: const InputDecoration(labelText: 'Descripción'),
          ),
          TextFormField(
            controller: _imagenUrlController,
            decoration: const InputDecoration(labelText: 'URL de imagen'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await MascotaService().crearMascota(
                  nombre: _nombreController.text,
                  raza: _razaController.text,
                  edad: int.parse(_edadController.text),
                  genero: _generoSeleccionado,
                  descripcion: _descripcionController.text,
                  imagenUrl: _imagenUrlController.text,
                );
                Navigator.pushReplacementNamed(context, '/mascota-list');
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

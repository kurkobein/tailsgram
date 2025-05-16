import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tailsgram/services/mascota_service.dart';
import 'package:tailsgram/services/storage/storage_foto_mascota.dart';

class MascotaForm extends StatefulWidget {
  const MascotaForm({super.key});

  @override
  State<MascotaForm> createState() => _MascotaFormState();
}

class _MascotaFormState extends State<MascotaForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _razaController = TextEditingController();
  final _edadController = TextEditingController();
  final _descripcionController = TextEditingController();

  String _generoSeleccionado = 'Macho';
  File? _selectedImage;
  String? _imageFileName;
  bool _isLoading = false;

  Future<void> _seleccionarImagen() async {
    final result = await StorageService().seleccionarImagen();
    if (result != null) {
      setState(() {
        _selectedImage = result.file;
        _imageFileName = result.fileName;
      });
    }
  }

  Future<void> _guardarMascota() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null || _imageFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una imagen.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Subir imagen y obtener URL
    final imageUrl = await StorageService().subirImagenDesdeFile(
      _selectedImage!,
      _imageFileName!,
    );

    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al subir la imagen.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    // Guardar datos en Firestore
    await MascotaService().crearMascota(
      nombre: _nombreController.text,
      raza: _razaController.text,
      edad: int.parse(_edadController.text),
      genero: _generoSeleccionado,
      descripcion: _descripcionController.text,
      imagenUrl: imageUrl,
    );

    setState(() => _isLoading = false);

    Navigator.pushReplacementNamed(context, '/mascota-list');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nombreController,
            decoration: const InputDecoration(labelText: 'Nombre'),
            validator: (value) =>
                value == null || value.isEmpty ? 'Requerido' : null,
          ),
          TextFormField(
            controller: _razaController,
            decoration: const InputDecoration(labelText: 'Raza'),
            validator: (value) =>
                value == null || value.isEmpty ? 'Requerido' : null,
          ),
          TextFormField(
            controller: _edadController,
            decoration: const InputDecoration(labelText: 'Edad'),
            keyboardType: TextInputType.number,
            validator: (value) =>
                value == null || value.isEmpty ? 'Requerido' : null,
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
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _seleccionarImagen,
            icon: const Icon(Icons.photo_library),
            label: const Text('Seleccionar Imagen'),
          ),
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(_selectedImage!, height: 150),
            ),
          const SizedBox(height: 20),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _guardarMascota,
                  child: const Text('Guardar'),
                ),
        ],
      ),
    );
  }
}

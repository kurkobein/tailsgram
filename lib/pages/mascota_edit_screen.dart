import 'dart:io';
import 'package:tailsgram/services/storage/storage_foto_mascota.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/mascota_service.dart';
import 'package:geolocator/geolocator.dart';


class MascotaEditarScreen extends StatefulWidget {
  const MascotaEditarScreen({super.key});

  @override
  State<MascotaEditarScreen> createState() => _MascotaEditarScreenState();
}

class _MascotaEditarScreenState extends State<MascotaEditarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _razaController = TextEditingController();
  final _edadController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _imagenUrlController = TextEditingController();
  String _genero = 'Macho';
  File? _selectedImage;
  String? _imageFileName;


  late DocumentSnapshot mascota;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mascota = ModalRoute.of(context)!.settings.arguments as DocumentSnapshot;
    final data = mascota.data() as Map<String, dynamic>;

    _nombreController.text = data['nombre'] ?? '';
    _razaController.text = data['raza'] ?? '';
    _edadController.text = data['edad']?.toString() ?? '';
    _descripcionController.text = data['descripcion'] ?? '';
    _imagenUrlController.text = data['imagenUrl'] ?? '';
    _genero = data['genero'] ?? 'Macho';
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageFileName = pickedFile.name;
      });
    }
  }


  Future<void> _guardarCambios() async {
    String? nuevaUrl = _imagenUrlController.text;

    if (_selectedImage != null && _imageFileName != null) {
      final urlSubida = await StorageService().subirImagenDesdeFile(
        _selectedImage!,
        _imageFileName!,
      );
      if (urlSubida != null) nuevaUrl = urlSubida;
    }

    if (_formKey.currentState!.validate()) {
      await MascotaService().actualizarMascota(
        id: mascota.id,
        nombre: _nombreController.text,
        raza: _razaController.text,
        edad: int.parse(_edadController.text),
        genero: _genero,
        descripcion: _descripcionController.text,
        imagenUrl: nuevaUrl,
      );


      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/mascota-list');
    }
  }

  Future<void> _confirmarEliminacion() async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar mascota'),
        content: const Text('¿Estás seguro de que deseas eliminar esta mascota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      await MascotaService().eliminarMascota(mascota.id);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/mascota-list');
    }
  }

  InputDecoration _decoracion(String texto) => InputDecoration(
        labelText: texto,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC5F3D6),
      appBar: AppBar(
        title: const Text('Editar Mascota'),
        backgroundColor: const Color(0xFFAAF0D1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: _decoracion('Nombre'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _razaController,
                decoration: _decoracion('Raza'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _edadController,
                decoration: _decoracion('Edad'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _genero,
                items: ['Macho', 'Hembra']
                    .map((g) =>
                        DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _genero = value);
                },
                decoration: _decoracion('Género'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: _decoracion('Descripción'),
              ),
              const SizedBox(height: 16),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(_selectedImage!, height: 100),
                )
              else if (_imagenUrlController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(_imagenUrlController.text, height: 100),
                ),

              ElevatedButton.icon(
                onPressed: _seleccionarImagen,
                icon: const Icon(Icons.photo),
                label: const Text('Seleccionar nueva imagen'),
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _guardarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B81),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Actualizar mascota'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _confirmarEliminacion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Eliminar mascota'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

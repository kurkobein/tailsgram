import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

String sanitizeFileName(String fileName) {
  return fileName.toLowerCase().replaceAll(RegExp(r'[^\w\-.]'), '_');
}

class ImagenSeleccionada {
  final File file;
  final String fileName;
  ImagenSeleccionada({required this.file, required this.fileName});
}

class StorageService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<ImagenSeleccionada?> seleccionarImagen() async {
    var pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.files.first.path!);
      final fileName = sanitizeFileName(pickedFile.files.first.name);
      return ImagenSeleccionada(file: file, fileName: fileName);
    }
    return null;
  }

  Future<String?> subirImagenDesdeFile(File file, String originalName) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final folderPath = 'publicaciones/$uid';
      final finalName = await _getUniqueFileName(folderPath, originalName);
      final fullPath = '$folderPath/$finalName';

      await supabase.storage.from('imagenes').upload(fullPath, file);

      final imageUrl = supabase.storage.from('imagenes').getPublicUrl(fullPath);
      return imageUrl;
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  Future<String> _getUniqueFileName(String folder, String fileName) async {
    final storage = supabase.storage.from('imagenes');
    final existingFiles = await storage.list(path: folder);

    final base = fileName.contains('.') ? fileName.substring(0, fileName.lastIndexOf('.')) : fileName;
    final extension = fileName.contains('.') ? fileName.substring(fileName.lastIndexOf('.')) : '';

    String name = fileName;
    int count = 1;

    final names = existingFiles.map((f) => f.name).toSet();
    while (names.contains(name)) {
      name = '$base($count)$extension';
      count++;
    }

    return name;
  }
}

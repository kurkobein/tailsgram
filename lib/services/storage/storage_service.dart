import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

String sanitizeFileName(String fileName) {
  // Reemplaza espacios y caracteres no alfanuméricos por guiones
  return fileName
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\-.]'), '_'); // permite letras, números, guiones, puntos
}


class StorageService {

  final SupabaseClient supabase = Supabase.instance.client;
  uploadImage() async {
    var pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (pickedFile != null) {
      try {
        File file = File(pickedFile.files.first.path!);
        String rawName = pickedFile.files.first.name;
        String cleanName = sanitizeFileName(rawName);
        final uid = FirebaseAuth.instance.currentUser?.uid;
        String folderPath = 'publicaciones/$uid';
        String finalName = await _getUniqueFileName(folderPath, cleanName);
        String fullPath = '$folderPath/$finalName';
        await supabase.storage.from('imagenes').upload(fullPath, file);

        print('Imagen subida: $fullPath');

      } catch (e) {
        print('Error al seleccionar la imagen: $e');
      }
    }
  }

  Future<String> _getUniqueFileName(String folder, String fileName) async {
    final storage = supabase.storage.from('imagenes');
    final existingFiles = await storage.list(path: folder);

    final base = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;
    final extension = fileName.contains('.')
        ? fileName.substring(fileName.lastIndexOf('.'))
        : '';

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
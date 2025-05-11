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
        String path = 'images/$uid/$cleanName';
        await supabase.storage.from('publicaciones').upload(path, file);

        print('Imagen subida: $path');

      } catch (e) {
        print('Error al seleccionar la imagen: $e');
      }
    }
  }
}
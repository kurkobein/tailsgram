import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_routes.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {

  await Supabase.initialize(
    url: 'https://qehohrpghlqjkatoyqux.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFlaG9ocnBnaGxxamthdG95cXV4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcwMDA4NjMsImV4cCI6MjA2MjU3Njg2M30.S_yXuRn1KsfgoQhQHGOa8zqE466N4-idYMe6zfvTO1o',
  );

  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializa Firebase solo si no está hecho
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase ya estaba inicializado: $e');
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
      routes: AppRoutes.routes,
    );
  }
}

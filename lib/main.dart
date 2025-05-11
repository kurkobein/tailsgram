import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_routes.dart';

import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> main() async {

  await Supabase.initialize(
    url: 'https://wzxmbjxfryqtddwsrhqx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6eG1ianhmcnlxdGRkd3NyaHF4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5OTQzMjksImV4cCI6MjA2MjU3MDMyOX0.nAPUt-fRL3oWJR0-ar26gEmh1JjjgIrvtBr0cePgslI',
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
    // Evita que la app crashee si Firebase ya fue inicializado
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
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/home',
      routes: AppRoutes.routes,
    );
  }
}

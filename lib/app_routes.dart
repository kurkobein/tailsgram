import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:path/path.dart';
import 'package:tailsgram/pages/profile_config_page.dart';
import 'import.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginScreen(),
    '/registro': (context) => const RegistroScreen(),
    '/home': (context) => const HomeScreen(),
    '/mascota-form': (context) => const MascotaFormScreen(),
    '/mascota-list': (context)=> const MascotaListScreen(),
    '/mascota-detalle': (context)=>const MascotaDetalleScreen(),
    '/perfil': (context)=>const PerfilScreen(),
    '/configuracion': (context)=>const ConfiguracionPerfil(),

  };
}

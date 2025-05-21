import 'package:flutter/material.dart';
import 'package:tailsgram/pages/profile_config_page.dart';
import 'package:tailsgram/pages/perfil_usuario.dart';
import 'import.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginScreen(),
    '/sign-in': (context) => const LoginScreen(),
    '/registro': (context) => const RegistroScreen(),
    '/home': (context) => const HomeScreen(),
    '/mascota-form': (context) => const MascotaFormScreen(),
    '/mascota-list': (context) {
      final args = ModalRoute.of(context)!.settings.arguments as String?;
      return MascotaListScreen(uid: args);
    },
    '/mascota-detalle': (context)=>const MascotaDetalleScreen(),
    '/perfil': (context)=>const PerfilScreen(),
    '/configuracion': (context)=>const ConfiguracionPerfil(),
    '/mascota-editar': (context) => const MascotaEditarScreen(),
    '/perfil-usuario': (context) => const PerfilUsuarioScreen(),
  };
}

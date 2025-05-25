import 'package:flutter/material.dart';
import 'package:tailsgram/pages/auth_screen/profile_config_page.dart';
import 'package:tailsgram/pages/perfil_usuario.dart';
import 'package:tailsgram/pages/test_mensajeria.dart';
import 'package:tailsgram/pages/lista_chats.dart' as chats;
import 'package:tailsgram/pages/test_mensajeria.dart';
import 'import.dart';
import 'package:tailsgram/pages/crear_evento.dart';

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
    '/chat': (context) {
      final args = ModalRoute.of(context)!.settings.arguments as String;
      return ChatScreen(otherUserId: args);
    },
    '/lista-chats': (context) => chats.ListaChatsScreen(),

  };
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'import.dart';

class AppRoutes {
  // Proveedores de autenticación (puedes agregar más)
  static final providers = [EmailAuthProvider()];

  // Todas las rutas centralizadas
  static Map<String, WidgetBuilder> routes = {
    '/sign-in': (context) => SignInScreen(
          providers: providers,
          actions: [
            AuthStateChangeAction<UserCreated>((context, state) {
              Navigator.pushReplacementNamed(context, '/profile');
            }),
            AuthStateChangeAction<SignedIn>((context, state) {
              Navigator.pushReplacementNamed(context, '/home');
            }),
          ],
        ),
    '/home': (context) => const HomeScreen(),
    '/mascota-form':(context)=> const MascotaFormScreen(),
    '/profile': (context) => ProfileScreen(
          providers: providers,
          actions: [
            SignedOutAction((context) {
              Navigator.pushReplacementNamed(context, '/sign-in');
            }),
          ],
        ),
  };
}

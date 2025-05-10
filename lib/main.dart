import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/add_page.dart';
import 'pages/map_page.dart';
import 'pages/calendario_page.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int paginaActual = 0;
  List<Widget> paginas = [
    const PaginaHome(),
    const PaginaBuscar(),
    const PaginaSubir(),
    const PaginaCalendario(),
    const PaginaMapa(),
    const PaginaPerfil(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      home: Scaffold(
        body: paginas[paginaActual],
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: const Color.fromARGB(255, 2, 2, 2), 
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              paginaActual = index;
            });

          },
          currentIndex: paginaActual,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 35),
              activeIcon: Icon(Icons.home, size: 35),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 35),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline, size: 35),
              activeIcon: Icon(Icons.add_circle_outlined, size: 35),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined, size: 35),
              activeIcon: Icon(Icons.map, size: 35),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined, size: 35),
              activeIcon: Icon(Icons.calendar_month, size: 35),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 35),
              activeIcon: Icon(Icons.person, size: 35),
              label: '',
            ),
          ],
        ),
      ),
      
    );
  }
}

import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/search_page.dart';
import 'posts_page.dart';
import '../pages/map_page.dart';
import '../pages/calendario_page.dart';
import '../import.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int paginaActual = 0;

  final List<Widget> paginas = [
    const ListaPublicaciones(),
    BuscadorUsuarios(),
    const PaginaSubir(),
    const PaginaMapa(),
    const PaginaCalendario(),
    const PerfilScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: paginas[paginaActual],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color.fromARGB(255, 2, 2, 2),
        type: BottomNavigationBarType.fixed,
        currentIndex: paginaActual,
        onTap: (index) {
          setState(() {
            paginaActual = index;
          });
        },
        items: const [
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
          )
        ],
      ),
    );
  }
}
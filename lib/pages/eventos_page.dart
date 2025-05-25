import 'package:flutter/material.dart';
import 'package:tailsgram/widgets/boton_estandar.dart';
import 'package:tailsgram/pages/crear_evento.dart';

class PaginaEventos extends StatelessWidget {
  const PaginaEventos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            'assets/images/logo.png',
            height: 40,
          ),
        ),
        backgroundColor: const Color(0xFFAAF0D1),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color.fromARGB(255, 133, 133, 133), width: 1),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text(
                  'Al parecer no tienes eventos listados',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                    SizedBox(height: 5),
                    Text('¿Por que no creas alguno o buscas eventos cercanos a ti?',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                  ],
                ),
              )
            ),
          ),
          SizedBox(height: 30),
          BotonEstandar(
            texto: 'Crear evento nuevo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CrearEvento(
                    onGuardar: (titulo, descripcion, fechaHora) {
                      // Aquí haces algo con el evento, por ejemplo:
                      print('Título: $titulo\nDescripción: $descripcion\nFechaHora: $fechaHora');
                    },
                  ),
                ),
              );


            },
          ),
          SizedBox(height: 30),
          BotonEstandar(
            texto: 'Buscar Eventos',
            onPressed: () {
              Navigator.pushNamed(context, '/buscar-eventos');
            },
          ),
        ],
      ),
    );
  }
}
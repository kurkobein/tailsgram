import 'package:flutter/material.dart';
import 'package:tailsgram/widgets/boton_estandar_perfil.dart';

class Informacion extends StatelessWidget {
  const Informacion({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                child: Text('3 Mascotas', style: TextStyle(fontSize: 12),),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                child: Text('50 seguidores', style: TextStyle(fontSize: 12)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                child: Text('30 seguidores', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: BotonEstandarPerfil(
                  texto: 'Editar Mascotas',
                  onPressed: () async {
                  Navigator.pushNamed(context, '/mascota-list');
                },
                  ancho: 20,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                child: BotonEstandarPerfil(
                  texto: 'Editar Perfil',
                  onPressed: () async {
                    Navigator.pushNamed(context, '/configuracion');
                  },
                  ancho: 34,
                ),


              ),
            ],
          ),
        ],
      )
    );
  }
}
import 'package:flutter/material.dart';
import 'package:tailsgram/widgets/boton_estandar.dart';
import 'package:tailsgram/pages/crear_evento.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('eventos').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: const Color.fromARGB(255, 133, 133, 133),
                          width: 1,
                        ),
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
                            Text(
                              '¿Por qué no creas alguno o buscas eventos cercanos a ti?',
                              style: TextStyle(color: Colors.black, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final evento = snapshot.data!.docs[index];
                      final titulo = evento['titulo'] ?? 'Sin título';
                      final descripcion = evento['descripcion'] ?? '';
                      final fechaHora = evento['fechaHora'] != null
                          ? (evento['fechaHora'] as Timestamp).toDate()
                          : null;

                      final ahora = DateTime.now();
                      final hoy = DateTime(ahora.year, ahora.month, ahora.day, ahora.hour, ahora.minute);

                      for (final doc in snapshot.data!.docs) {
                        final fechaEvento = (doc['fechaHora'] as Timestamp).toDate();
                        final fechaEventoSinHora = DateTime(fechaEvento.year, fechaEvento.month, fechaEvento.day, fechaEvento.hour, fechaEvento.minute);

                        if (fechaEventoSinHora.isBefore(hoy)) {
                          FirebaseFirestore.instance.collection('eventos').doc(doc.id).delete();
                        }
                      }

                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                titulo,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                descripcion,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    fechaHora != null
                                        ? '${fechaHora.day}/${fechaHora.month}/${fechaHora.year} ${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}'
                                        : 'Fecha no disponible',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              Divider(
                                color: const Color.fromARGB(255, 133, 133, 133),
                                height: 30,
                              ),
                            ],
                          ),
                        );
                    },
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          BotonEstandar(
            texto: 'Crear evento nuevo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CrearEvento(
                    onGuardar: (titulo, descripcion, fechaHora) {
                      print('Título: $titulo\nDescripción: $descripcion\nFechaHora: $fechaHora');
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          BotonEstandar(
            texto: 'Buscar Eventos',
            onPressed: () {
              Navigator.pushNamed(context, '/buscar-eventos');
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

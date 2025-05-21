import 'package:flutter/material.dart';
import 'package:tcard/tcard.dart';

class Match extends StatelessWidget {
  const Match({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> cards = List.generate(
      5,
      (index) => Card(
        color: Colors.primaries[index % Colors.primaries.length],
        child: Center(
          child: Text('Mascota ${index + 1}', style: TextStyle(fontSize: 24)),
        ),
      ),
    );

    final TCardController controller = TCardController();

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          height: 40,
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 198, 241, 214),
      ),
      body: Center(
        child: TCard(
          size: Size(350, 500),
          cards: cards,
          controller: controller,
          onForward: (index, info) {
          },
          onEnd: () {
          },
        ),
      ),
    );
  }
}

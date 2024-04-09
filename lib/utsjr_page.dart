import 'package:flutter/material.dart';

class UTSJRPage extends StatelessWidget {
  const UTSJRPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UTSJR'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Redirige a la página anterior (en este caso, la HomePage)
          },
          child: const Text('Regresar'),
        ),
      ),
    );
  }
}

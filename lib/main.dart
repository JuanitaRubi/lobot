import 'package:flutter/material.dart';
import 'login_page.dart'; // Importa la página de inicio de sesión
// Importa la página principal

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: LoginPage(), // Inicia con la página de inicio de sesión
    );
  }
}

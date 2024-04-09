import 'package:flutter/material.dart';
import 'home_page.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _expediente = '';
  String _contrasena = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LOBOT', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black, 
        centerTitle: true, 
      ),
      body: Container(
        color: Colors.lightBlue, 
        child: Center(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 20), 
            elevation: 4, 
            child: Padding(
              padding: const EdgeInsets.all(20), 
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  const Text(
                    'Inicio de Sesión',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20), 
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _expediente = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Número de Expediente',
                    ),
                  ),
                  const SizedBox(height: 10), 
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _contrasena = value;
                      });
                    },
                    obscureText: true, 
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                    ),
                  ),
                  const SizedBox(height: 20), 
                  ElevatedButton(
                    onPressed: () {
                      
                      if (_expediente == 'lobot' && _contrasena == '1234') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage(usuario: _expediente)),
                        );
                      } else if (_expediente == 'alumno' && _contrasena == 'alumno') {
                        
                        _mostrarSubirImagenDialog(context);
                      } else {
                        
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error de inicio de sesión'),
                            content: const Text('El número de expediente o la contraseña son incorrectos.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Aceptar'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: const Text('Iniciar Sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarSubirImagenDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Subir Imagen'),
          content: const Text('¿Desea subir una imagen como nuevo usuario?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage(usuario: _expediente, imagenUsuario: null)), 
                );
              },
              child: const Text('Sí'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}

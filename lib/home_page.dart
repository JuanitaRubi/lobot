import 'package:flutter/material.dart';
import 'chat_page.dart'; 
import 'utsjr_page.dart'; 
import 'login_page.dart'; 

class HomePage extends StatelessWidget {
  final String usuario;
  final String? imagenUsuario;

  const HomePage({Key? key, required this.usuario, this.imagenUsuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            _regresarAlLogin(context); // Regresa al formulario 
          },
          child: const Text('LOBOT', style: TextStyle(color: Colors.white)), 
        ),
        backgroundColor: Colors.black, 
        actions: [
          IconButton(
            onPressed: () {
              _regresarAlLogin(context); // Regresa al formulario 
            },
            icon: const Icon(Icons.logout, color: Colors.white), 
          ),
        ],
      ),
      drawer: Drawer(
        // ignore: sized_box_for_whitespace
        child: Container( 
          width: MediaQuery.of(context).size.width * 0.2, 
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Menú', style: TextStyle(color: Colors.white)), 
              ),
              ListTile(
                title: const Text('CHAT'),
                onTap: () {
                  _navegarAlChat(context); //página de chat
                },
              ),
              ListTile(
                title: const Text('UTSJR'),
                onTap: () {
                  _navegarAUTSJR(context); // página de UTSJR
                },
              ),
              
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.lightBlue,
        child: Center(
          child: ClipOval(
            child: Image.asset(
              usuario == 'lobot' ? 'assets/juancho.png' : (imagenUsuario ?? 'assets/default_image.png'),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  void _regresarAlLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()), // Regresa al formulario
    );
  }

  void _navegarAlChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatPage()), //página de chat
    );
  }

  void _navegarAUTSJR(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UTSJRPage()), //página de UTSJR
    );
  }
}

import 'package:flutter/material.dart';
import 'home-page.dart'; // Importa la página principal

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    // Redirige a la página principal después de 3 segundos
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red, // Fondo rojo Pokémon
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen de bienvenida
            Image.network(
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png', // Imagen de Pikachu
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20), // Espacio entre la imagen y el texto
            Text(
              '¡Bienvenido a la Pokedex!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.yellow, // Color amarillo para la bienvenida
              ),
            ),
            SizedBox(height: 10),
            Text(
              '¡Prepara tu equipo de Pokémon!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white, // Texto en blanco para resaltar sobre el rojo
              ),
            ),
          ],
        ),
      ),
    );
  }
}

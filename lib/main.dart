import 'package:flutter/material.dart';
import 'screens/landing_page.dart'; // Asegúrate de que la ruta sea correcta

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokedex App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LandingPage(), // Página inicial es la Landing Page
    );
  }
}
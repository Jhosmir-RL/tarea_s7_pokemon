import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class DetailPage extends StatefulWidget {
  final String pokemonId;

  const DetailPage({Key? key, required this.pokemonId}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map<String, dynamic> pokemonDetails = {};
  bool isLoading = true;
  Color backgroundColor = Colors.deepPurple; // Color de fondo dinámico

  @override
  void initState() {
    super.initState();
    fetchPokemonDetails();
  }

  Future<void> fetchPokemonDetails() async {
    final dio = Dio();
    try {
      final response = await dio.get('https://pokeapi.co/api/v2/pokemon/${widget.pokemonId}');
      if (response.statusCode == 200) {
        setState(() {
          pokemonDetails = response.data;
          isLoading = false;
          // Cambia el color de fondo según el tipo de Pokémon
          if (pokemonDetails["types"].isNotEmpty) {
            backgroundColor = _getColorFromType(pokemonDetails["types"][0]["type"]["name"]);
          }
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Función para obtener un color basado en el tipo de Pokémon
  Color _getColorFromType(String type) {
    switch (type) {
      case "fire":
        return Colors.orangeAccent;
      case "water":
        return Colors.blueAccent;
      case "grass":
        return Colors.greenAccent;
      case "electric":
        return Colors.yellowAccent;
      case "psychic":
        return Colors.purpleAccent;
      case "ice":
        return Colors.lightBlueAccent;
      case "dragon":
        return Colors.indigoAccent;
      case "dark":
        return Colors.brown;
      case "fairy":
        return Colors.pinkAccent;
      case "normal":
        return Colors.grey;
      case "fighting":
        return Colors.deepOrange;
      case "flying":
        return Colors.lightBlue;
      case "poison":
        return Colors.purple;
      case "ground":
        return Colors.brown[400]!;
      case "rock":
        return Colors.grey[700]!;
      case "bug":
        return Colors.lightGreen;
      case "ghost":
        return Colors.deepPurple;
      case "steel":
        return Colors.blueGrey;
      default:
        return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // Fondo dinámico basado en el tipo de Pokémon
      appBar: AppBar(
        title: Text(
          pokemonDetails["name"]?.toString().toUpperCase() ?? "Detalles del Pokémon",
          style: TextStyle(
            color: Colors.black, // Texto en negro
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.5), // AppBar semi-transparente
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black), // Ícono de retroceso negro
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.black, // Indicador de carga en negro
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Imagen del Pokémon (más grande y centrada)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Image.network(
                          pokemonDetails["sprites"]["front_default"],
                          width: 300, // Imagen más grande
                          height: 300, // Imagen más grande
                          fit: BoxFit.cover, // Ajusta la imagen al contenedor
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Nombre del Pokémon
                    Text(
                      pokemonDetails["name"]?.toString().toUpperCase() ?? "",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Texto en negro
                      ),
                    ),
                    SizedBox(height: 10),
                    // Tipos del Pokémon
                    Wrap(
                      spacing: 8,
                      children: pokemonDetails["types"].map<Widget>((type) {
                        return Chip(
                          label: Text(
                            type["type"]["name"].toString().toUpperCase(),
                            style: TextStyle(
                              color: Colors.black, // Texto en negro
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: _getColorFromType(type["type"]["name"]).withOpacity(0.7),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    // Detalles del Pokémon
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow("Altura", "${pokemonDetails["height"]} dm"),
                          _buildDetailRow("Peso", "${pokemonDetails["weight"]} hg"),
                          _buildDetailRow("Experiencia base", "${pokemonDetails["base_experience"]} XP"),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    // Estadísticas del Pokémon
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Estadísticas",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Texto en negro
                            ),
                          ),
                          SizedBox(height: 10),
                          ...pokemonDetails["stats"].map<Widget>((stat) {
                            return _buildStatRow(
                              stat["stat"]["name"].toString().toUpperCase(),
                              stat["base_stat"],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Widget para construir una fila de detalles
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black, // Texto en negro
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black, // Texto en negro
            ),
          ),
        ],
      ),
    );
  }

  // Widget para construir una fila de estadísticas
  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black, // Texto en negro
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black), // Barra de progreso en negro
            ),
          ),
          SizedBox(width: 10),
          Text(
            "$value",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black, // Texto en negro
            ),
          ),
        ],
      ),
    );
  }
}
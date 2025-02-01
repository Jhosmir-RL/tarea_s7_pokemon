import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'detail-page.dart'; // Importa la página de detalles

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> pkmns = []; // Lista de Pokémon
  HTTP_STATES state = HTTP_STATES.INITIAL; // Estado de la carga
  int offset = 0; // Offset para la paginación
  final int limit = 20; // Límite de Pokémon por carga
  bool isLoadingMore = false; // Para evitar múltiples cargas simultáneas
  bool hasMore = true; // Indica si hay más Pokémon por cargar

  @override
  void initState() {
    super.initState();
    fetchPokemons(); // Carga inicial de Pokémon
  }

  Future<void> fetchPokemons() async {
    if (!hasMore) return; // Si no hay más Pokémon, no hacer nada

    final dio = Dio();
    try {
      final response = await dio
          .get('https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset');
      if (response.statusCode == 200) {
        final newPokemons =
            List<Map<String, dynamic>>.from(response.data["results"]);

        setState(() {
          if (newPokemons.isEmpty) {
            hasMore = false; // No hay más Pokémon por cargar
          } else {
            pkmns.addAll(newPokemons); // Agrega los nuevos Pokémon a la lista
            offset += limit; // Incrementa el offset para la próxima carga
          }
          state = HTTP_STATES.SUCCESS;
        });
      }
    } catch (e) {
      setState(() {
        state = HTTP_STATES.ERROR;
      });
    } finally {
      setState(() {
        isLoadingMore = false; // Finaliza la carga
      });
    }
  }

  void _loadMorePokemons() {
    if (!isLoadingMore && hasMore) {
      setState(() {
        isLoadingMore = true;
      });
      fetchPokemons(); // Carga más Pokémon
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pokédex",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.yellow, // Color amarillo inspirado en Pokémon
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red, // Fondo rojo inspirado en Pokémon
        elevation: 10,
      ),
      backgroundColor: Colors.grey[200], // Fondo gris claro
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (state) {
      case HTTP_STATES.SUCCESS:
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // Cargar más Pokémon cuando el usuario llegue al final de la lista
            if (!isLoadingMore &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              _loadMorePokemons();
            }
            return true;
          },
          child: GridView.builder(
            padding: EdgeInsets.all(16), // Espaciado alrededor de la lista
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columnas
              crossAxisSpacing: 16, // Espacio horizontal entre los Pokémon
              mainAxisSpacing: 16, // Espacio vertical entre los Pokémon
              childAspectRatio: 0.8, // Relación de aspecto (ancho/alto)
            ),
            itemCount: pkmns.length +
                (hasMore ? 1 : 0), // +1 para el indicador de carga
            itemBuilder: (context, index) {
              if (index < pkmns.length) {
                final pokemon = pkmns[index];
                final pokemonId =
                    pokemon["url"].split("/")[6]; // Extrae el ID del Pokémon
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(pokemonId: pokemonId),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 6, // Sombra de la tarjeta
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16), // Bordes redondeados
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red[100]!,
                            Colors.yellow[100]!
                          ], // Gradiente rojo-amarillo
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Imagen del Pokémon
                          Image.network(
                            "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png",
                            width: 120, // Tamaño de la imagen
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.error_outline,
                                size: 60,
                                color: Colors.red,
                              ); // Ícono de error si la imagen no carga
                            },
                          ),
                          SizedBox(
                              height:
                                  10), // Espacio entre la imagen y el nombre
                          // Nombre del Pokémon
                          Text(
                            pokemon["name"].toString().toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Texto en negro
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                // Indicador de carga al final de la lista
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.red, // Indicador de carga en rojo
                  ),
                );
              }
            },
          ),
        );
      case HTTP_STATES.ERROR:
        return Center(
          child: Text(
            "Error al cargar los Pokémon",
            style: TextStyle(
              fontSize: 18,
              color: Colors.red, // Mensaje de error en rojo
            ),
          ),
        );
      case HTTP_STATES.LOADING:
      default:
        return Center(
          child: CircularProgressIndicator(
            color: Colors.red, // Indicador de carga en rojo
          ),
        );
    }
  }
}

enum HTTP_STATES { INITIAL, LOADING, ERROR, SUCCESS }

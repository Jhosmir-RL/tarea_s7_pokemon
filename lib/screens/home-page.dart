import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'detail-page.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> pkmns = [];
  HTTP_STATES state = HTTP_STATES.INITIAL; 
  int offset = 0; 
  final int limit = 20; 
  bool isLoadingMore = false; 
  bool hasMore = true; 

  @override
  void initState() {
    super.initState();
    fetchPokemons(); 
  }

  Future<void> fetchPokemons() async {
    if (!hasMore) return; 

    final dio = Dio();
    try {
      final response = await dio
          .get('https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset');
      if (response.statusCode == 200) {
        final newPokemons =
            List<Map<String, dynamic>>.from(response.data["results"]);

        setState(() {
          if (newPokemons.isEmpty) {
            hasMore = false; 
          } else {
            pkmns.addAll(newPokemons); 
            offset += limit; 
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
        isLoadingMore = false; 
      });
    }
  }

  void _loadMorePokemons() {
    if (!isLoadingMore && hasMore) {
      setState(() {
        isLoadingMore = true;
      });
      fetchPokemons(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pokédex",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.yellow, 
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red, 
        elevation: 10,
      ),
      backgroundColor: Colors.grey[200], 
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (state) {
      case HTTP_STATES.SUCCESS:
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!isLoadingMore &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              _loadMorePokemons();
            }
            return true;
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(16), 
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              crossAxisSpacing: 16, 
              mainAxisSpacing: 16, 
              childAspectRatio: 0.8, 
            ),
            itemCount: pkmns.length +
                (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < pkmns.length) {
                final pokemon = pkmns[index];
                final pokemonId =
                    pokemon["url"].split("/")[6];
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
                    elevation: 6, 
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red[100]!,
                            Colors.yellow[100]!
                          ], 
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png",
                            width: 120, 
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.error_outline,
                                size: 60,
                                color: Colors.red,
                              ); 
                            },
                          ),
                          const SizedBox(
                              height:
                                  10), 
                          Text(
                            pokemon["name"].toString().toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, 
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.red, 
                  ),
                );
              }
            },
          ),
        );
      case HTTP_STATES.ERROR:
        return const Center(
          child: Text(
            "Error al cargar los Pokémon",
            style: TextStyle(
              fontSize: 18,
              color: Colors.red, 
            ),
          ),
        );
      case HTTP_STATES.LOADING:
      default:
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.red,
          ),
        );
    }
  }
}

enum HTTP_STATES { INITIAL, LOADING, ERROR, SUCCESS }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'buscar_page.dart';
import 'api_service.dart';
import 'dart:convert';

void main() {
  runApp(ReceitasApp());
}

class ReceitasApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receitas Fáceis',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0; // 0: Home, 1: Buscar, 2: Favoritos
  Set<String> _favoritosAPI = {};
  Map<String, Map<String, dynamic>> _detalhesReceitasAPI = {};

  @override
  void initState() {
    super.initState();
    _carregarFavoritos();
  }

  Future<void> _carregarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritosAPIString = prefs.getStringList('favoritosAPI') ?? [];
    final detalhesString = prefs.getString('detalhesReceitasAPI') ?? '{}';
    
    setState(() {
      _favoritosAPI = favoritosAPIString.toSet();
      _detalhesReceitasAPI = Map<String, Map<String, dynamic>>.from(
        json.decode(detalhesString).map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)))
      );
    });
  }

  Future<void> _salvarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoritosAPI', _favoritosAPI.toList());
    await prefs.setString('detalhesReceitasAPI', json.encode(_detalhesReceitasAPI));
  }

  void _toggleFavoritoAPI(String idMeal, String nome, String thumb) {
    setState(() {
      if (_favoritosAPI.contains(idMeal)) {
        _favoritosAPI.remove(idMeal);
        _detalhesReceitasAPI.remove(idMeal);
      } else {
        _favoritosAPI.add(idMeal);
        _detalhesReceitasAPI[idMeal] = {
          'idMeal': idMeal,
          'strMeal': nome,
          'strMealThumb': thumb,
        };
      }
    });
    _salvarFavoritos();
  }

  bool _isFavoritaAPI(String idMeal) {
    return _favoritosAPI.contains(idMeal);
  }

  @override
  Widget build(BuildContext context) {
    Widget _getPaginaAtual() {
      switch (_currentIndex) {
        case 0:
          return HomePage(
            favoritosAPI: _favoritosAPI,
            onToggleFavoritoAPI: _toggleFavoritoAPI,
            isFavoritaAPI: _isFavoritaAPI,
          );
        case 1:
          return BuscarPage(
            favoritosAPI: _favoritosAPI,
            onToggleFavoritoAPI: _toggleFavoritoAPI,
            isFavoritaAPI: _isFavoritaAPI,
          );
        case 2:
          return FavoritosPage(
            favoritosAPI: _favoritosAPI,
            detalhesReceitasAPI: _detalhesReceitasAPI,
            onToggleFavoritoAPI: _toggleFavoritoAPI,
            isFavoritaAPI: _isFavoritaAPI,
          );
        default:
          return HomePage(
            favoritosAPI: _favoritosAPI,
            onToggleFavoritoAPI: _toggleFavoritoAPI,
            isFavoritaAPI: _isFavoritaAPI,
          );
      }
    }

    return Scaffold(
      body: _getPaginaAtual(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

// Tela Home - Receitas da API por Categoria
class HomePage extends StatefulWidget {
  final Set<String> favoritosAPI;
  final Function(String, String, String) onToggleFavoritoAPI;
  final bool Function(String) isFavoritaAPI;

  const HomePage({
    Key? key,
    required this.favoritosAPI,
    required this.onToggleFavoritoAPI,
    required this.isFavoritaAPI,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _categoriaSelecionada = 'Todas';
  List<String> _categorias = [];
  List<ReceitaAPI> _receitas = [];
  bool _carregandoCategorias = true;
  bool _carregandoReceitas = false;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    setState(() => _carregandoCategorias = true);
    
    final categorias = await MealDBService.listarCategorias();
    
    setState(() {
      _categorias = ['Todas', ...categorias];
      _carregandoCategorias = false;
    });
    
    _carregarReceitas('Todas');
  }

  Future<void> _carregarReceitas(String categoria) async {
    setState(() {
      _carregandoReceitas = true;
      _categoriaSelecionada = categoria;
    });
    
    List<ReceitaAPI> receitas = [];
    
    if (categoria == 'Todas') {
      // Carregar receitas de TODAS as categorias disponíveis
      final categoriasReais = _categorias.where((c) => c != 'Todas').toList();
      
      for (var cat in categoriasReais) {
        final receitasCategoria = await MealDBService.buscarPorCategoria(cat);
        receitas.addAll(receitasCategoria.take(3)); // Pega 3 de cada categoria
      }
    } else {
      receitas = await MealDBService.buscarPorCategoria(categoria);
    }
    
    setState(() {
      _receitas = receitas;
      _carregandoReceitas = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas Internacionais'),
        backgroundColor: Colors.orange,
      ),
      body: _carregandoCategorias
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    'Carregando categorias...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Filtro de Categorias
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.orange[50],
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categorias.map((categoria) {
                        final isSelected = categoria == _categoriaSelecionada;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(categoria),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              if (isSelected) {
                                // Desseleciona a categoria atual
                                setState(() {
                                  _categoriaSelecionada = null;
                                  _receitas = [];
                                });
                              } else {
                                // Seleciona a nova categoria
                                _carregarReceitas(categoria);
                              }
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.orange,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.orange[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                
                // Lista de Receitas
                Expanded(
                  child: _carregandoReceitas
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.orange),
                              const SizedBox(height: 16),
                              Text(
                                'Carregando receitas...',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : _categoriaSelecionada == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[300]),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Selecione uma categoria',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Escolha uma categoria acima\npara ver as receitas!',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : _receitas.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Nenhuma receita nesta categoria.',
                                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _receitas.length,
                              itemBuilder: (context, index) {
                                final receita = _receitas[index];
                                final isFavorita = widget.isFavoritaAPI(receita.idMeal);
                                
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  elevation: 2,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        receita.strMealThumb,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 70,
                                            height: 70,
                                            color: Colors.orange[100],
                                            child: Icon(Icons.restaurant, size: 40, color: Colors.orange),
                                          );
                                        },
                                      ),
                                    ),
                                    title: Text(
                                      receita.strMeal,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(Icons.public, size: 14, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Receita internacional',
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                        if (_categoriaSelecionada != null) ...[
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.orange[100],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _categoriaSelecionada!,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.orange[800],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        isFavorita ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorita ? Colors.red : Colors.grey,
                                        size: 28,
                                      ),
                                      onPressed: () => widget.onToggleFavoritoAPI(
                                        receita.idMeal,
                                        receita.strMeal,
                                        receita.strMealThumb,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetalhesReceitaAPIPage(
                                            idMeal: receita.idMeal,
                                            nome: receita.strMeal,
                                            isFavorita: isFavorita,
                                            onToggleFavorito: () {
                                              widget.onToggleFavoritoAPI(
                                                receita.idMeal,
                                                receita.strMeal,
                                                receita.strMealThumb,
                                              );
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }
}

// Tela de Favoritos
class FavoritosPage extends StatelessWidget {
  final Set<String> favoritosAPI;
  final Map<String, Map<String, dynamic>> detalhesReceitasAPI;
  final Function(String, String, String) onToggleFavoritoAPI;
  final bool Function(String) isFavoritaAPI;

  const FavoritosPage({
    Key? key,
    required this.favoritosAPI,
    required this.detalhesReceitasAPI,
    required this.onToggleFavoritoAPI,
    required this.isFavoritaAPI,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, Map<String, dynamic>>> receitasAPIFavoritas = 
        detalhesReceitasAPI.entries.toList();

    final bool temFavoritos = receitasAPIFavoritas.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        backgroundColor: Colors.orange,
      ),
      body: !temFavoritos
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 24),
                  Text(
                    'Nenhum favorito ainda',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Marque receitas como favoritas\nnas abas Home ou Buscar!',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.orange[50],
                  child: Row(
                    children: [
                      Icon(Icons.favorite, size: 22, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Receitas Favoritas (${receitasAPIFavoritas.length})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                ),
                ...receitasAPIFavoritas.map((entry) {
                  final idMeal = entry.key;
                  final receita = entry.value;
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          receita['strMealThumb'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 70,
                              height: 70,
                              color: Colors.orange[100],
                              child: Icon(Icons.restaurant, size: 40, color: Colors.orange),
                            );
                          },
                        ),
                      ),
                      title: Text(receita['strMeal'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Row(
                        children: [
                          Icon(Icons.public, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('Receita internacional', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.favorite, color: Colors.red, size: 28),
                        onPressed: () => onToggleFavoritoAPI(idMeal, receita['strMeal'], receita['strMealThumb']),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalhesReceitaAPIPage(
                              idMeal: idMeal,
                              nome: receita['strMeal'],
                              isFavorita: true,
                              onToggleFavorito: () => onToggleFavoritoAPI(idMeal, receita['strMeal'], receita['strMealThumb']),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
    );
  }
}

// Tela de Detalhes da Receita da API
class DetalhesReceitaAPIPage extends StatefulWidget {
  final String idMeal;
  final String nome;
  final bool isFavorita;
  final VoidCallback onToggleFavorito;

  const DetalhesReceitaAPIPage({
    Key? key,
    required this.idMeal,
    required this.nome,
    required this.isFavorita,
    required this.onToggleFavorito,
  }) : super(key: key);

  @override
  _DetalhesReceitaAPIPageState createState() => _DetalhesReceitaAPIPageState();
}

class _DetalhesReceitaAPIPageState extends State<DetalhesReceitaAPIPage> {
  ReceitaAPIDetalhada? _receita;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDetalhes();
  }

  Future<void> _carregarDetalhes() async {
    final receita = await MealDBService.buscarDetalhes(widget.idMeal);
    setState(() {
      _receita = receita;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nome),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(
              widget.isFavorita ? Icons.favorite : Icons.favorite_border,
              color: widget.isFavorita ? Colors.red : Colors.white,
            ),
            onPressed: widget.onToggleFavorito,
          ),
        ],
      ),
      body: _carregando
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    'Carregando detalhes...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : _receita == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar detalhes',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        _receita!.strMealThumb,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 250,
                            color: Colors.grey[300],
                            child: Icon(Icons.restaurant, size: 100, color: Colors.grey),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _receita!.strMeal,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                Chip(
                                  label: Text(_receita!.strCategory),
                                  backgroundColor: Colors.orange[100],
                                  avatar: Icon(Icons.category, size: 18, color: Colors.orange[700]),
                                ),
                                Chip(
                                  label: Text(_receita!.strArea),
                                  backgroundColor: Colors.orange[100],
                                  avatar: Icon(Icons.public, size: 18, color: Colors.orange[700]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Ingredientes',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                            ),
                            const SizedBox(height: 12),
                            ...List.generate(
                              _receita!.ingredientes.length,
                              (index) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.orange, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${_receita!.medidas[index].trim().isNotEmpty ? _receita!.medidas[index] + " - " : ""}${_receita!.ingredientes[index]}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Modo de Preparo',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _receita!.strInstructions,
                              style: const TextStyle(fontSize: 16, height: 1.6),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

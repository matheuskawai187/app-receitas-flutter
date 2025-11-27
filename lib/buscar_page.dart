import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dart:async';

class BuscarPage extends StatefulWidget {
  final Set<String> favoritosAPI;
  final Function(String, String, String) onToggleFavoritoAPI;
  final bool Function(String) isFavoritaAPI;

  const BuscarPage({
    Key? key,
    required this.favoritosAPI,
    required this.onToggleFavoritoAPI,
    required this.isFavoritaAPI,
  }) : super(key: key);

  @override
  _BuscarPageState createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
  List<ReceitaAPI> _receitas = [];
  bool _carregando = false;
  bool _buscouPelaAPI = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancelar o timer anterior se existir
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Criar um novo timer que executa após 500ms
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.trim().isNotEmpty) {
        _buscarPorNome(_searchController.text);
      } else {
        setState(() {
          _receitas = [];
          _buscouPelaAPI = false;
        });
      }
    });
  }

  Future<void> _buscarPorNome(String nome) async {
    if (nome.trim().isEmpty) {
      setState(() {
        _receitas = [];
        _buscouPelaAPI = false;
      });
      return;
    }

    setState(() {
      _carregando = true;
      _buscouPelaAPI = true;
    });

    final receitas = await MealDBService.buscarPorNome(nome);
    
    setState(() {
      _receitas = receitas;
      _carregando = false;
    });
  }

  void _limparBusca() {
    _searchController.clear();
    setState(() {
      _receitas = [];
      _buscouPelaAPI = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Receitas Internacionais'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // Campo de busca
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Digite o nome de uma receita...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.orange[700], size: 28),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.orange[700]),
                            onPressed: _limparBusca,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  style: const TextStyle(fontSize: 16),
                  textInputAction: TextInputAction.search,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Busca em tempo real na API TheMealDB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Resultado da busca
          Expanded(
            child: _carregando
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.orange),
                        const SizedBox(height: 16),
                        Text(
                          'Buscando receitas...',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : !_buscouPelaAPI
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 24),
                            Text(
                              'Busque por receitas internacionais',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                'Digite o nome de uma receita no campo acima para descobrir pratos deliciosos!',
                                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildSuggestionChip('Pasta', context),
                                _buildSuggestionChip('Chicken', context),
                                _buildSuggestionChip('Soup', context),
                                _buildSuggestionChip('Dessert', context),
                                _buildSuggestionChip('Salad', context),
                              ],
                            ),
                          ],
                        ),
                      )
                    : _receitas.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhuma receita encontrada',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tente buscar por outro nome',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        // Imagem
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            receita.strMealThumb,
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: 90,
                                                height: 90,
                                                color: Colors.orange[100],
                                                child: Icon(
                                                  Icons.restaurant,
                                                  size: 50,
                                                  color: Colors.orange,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Informações
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                receita.strMeal,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.public,
                                                    size: 16,
                                                    color: Colors.orange[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Receita internacional',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Botão de favorito
                                        IconButton(
                                          icon: Icon(
                                            isFavorita ? Icons.favorite : Icons.favorite_border,
                                            color: isFavorita ? Colors.red : Colors.grey,
                                            size: 28,
                                          ),
                                          onPressed: () {
                                            widget.onToggleFavoritoAPI(
                                              receita.idMeal,
                                              receita.strMeal,
                                              receita.strMealThumb,
                                            );
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label, BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _searchController.text = label;
        _buscarPorNome(label);
      },
      backgroundColor: Colors.orange[50],
      labelStyle: TextStyle(color: Colors.orange[700]),
      side: BorderSide(color: Colors.orange[200]!),
    );
  }
}

// Tela de detalhes da receita da API
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

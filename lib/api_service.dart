import 'dart:convert';
import 'package:http/http.dart' as http;

class MealDBService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Buscar receitas por categoria
  static Future<List<ReceitaAPI>> buscarPorCategoria(String categoria) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filter.php?c=$categoria'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;

        if (meals == null) return [];

        return meals.map((meal) => ReceitaAPI.fromJson(meal)).toList();
      } else {
        throw Exception('Erro ao buscar receitas');
      }
    } catch (e) {
      print('Erro: $e');
      return [];
    }
  }

  // Buscar detalhes completos de uma receita pelo ID
  static Future<ReceitaAPIDetalhada?> buscarDetalhes(String idMeal) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lookup.php?i=$idMeal'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;

        if (meals == null || meals.isEmpty) return null;

        return ReceitaAPIDetalhada.fromJson(meals[0]);
      } else {
        throw Exception('Erro ao buscar detalhes');
      }
    } catch (e) {
      print('Erro: $e');
      return null;
    }
  }

  // Buscar receitas por nome
  static Future<List<ReceitaAPI>> buscarPorNome(String nome) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search.php?s=$nome'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;

        if (meals == null) return [];

        return meals.map((meal) => ReceitaAPI.fromJson(meal)).toList();
      } else {
        throw Exception('Erro ao buscar receitas');
      }
    } catch (e) {
      print('Erro: $e');
      return [];
    }
  }

  // Listar categorias disponíveis
  static Future<List<String>> listarCategorias() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categories = data['categories'] as List;

        return categories
            .map((cat) => cat['strCategory'] as String)
            .toList();
      } else {
        throw Exception('Erro ao buscar categorias');
      }
    } catch (e) {
      print('Erro: $e');
      return [];
    }
  }
}

// Modelo simplificado para lista de receitas (sem detalhes)
class ReceitaAPI {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;

  ReceitaAPI({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
  });

  factory ReceitaAPI.fromJson(Map<String, dynamic> json) {
    return ReceitaAPI(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? 'Sem nome',
      strMealThumb: json['strMealThumb'] ?? '',
    );
  }
}

// Modelo completo com todos os detalhes da receita
class ReceitaAPIDetalhada {
  final String idMeal;
  final String strMeal;
  final String strCategory;
  final String strArea;
  final String strInstructions;
  final String strMealThumb;
  final List<String> ingredientes;
  final List<String> medidas;

  ReceitaAPIDetalhada({
    required this.idMeal,
    required this.strMeal,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strMealThumb,
    required this.ingredientes,
    required this.medidas,
  });

  factory ReceitaAPIDetalhada.fromJson(Map<String, dynamic> json) {
    // Extrair ingredientes e medidas (a API retorna até 20 campos)
    List<String> ingredientes = [];
    List<String> medidas = [];

    for (int i = 1; i <= 20; i++) {
      String? ingrediente = json['strIngredient$i'];
      String? medida = json['strMeasure$i'];

      if (ingrediente != null && ingrediente.trim().isNotEmpty) {
        ingredientes.add(ingrediente);
        medidas.add(medida ?? '');
      }
    }

    return ReceitaAPIDetalhada(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? 'Sem nome',
      strCategory: json['strCategory'] ?? 'Sem categoria',
      strArea: json['strArea'] ?? 'Internacional',
      strInstructions: json['strInstructions'] ?? 'Sem instruções',
      strMealThumb: json['strMealThumb'] ?? '',
      ingredientes: ingredientes,
      medidas: medidas,
    );
  }

  // Converter para o formato da sua classe Receita original
  String get ingredientesFormatados {
    List<String> lista = [];
    for (int i = 0; i < ingredientes.length; i++) {
      String medida = medidas[i].trim().isNotEmpty ? '${medidas[i]} - ' : '';
      lista.add('$medida${ingredientes[i]}');
    }
    return lista.join('\n');
  }
}
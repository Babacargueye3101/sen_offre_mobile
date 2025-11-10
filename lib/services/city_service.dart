import 'dart:convert';
import 'dart:io';
import '../config/api_config.dart';
import '../models/city.dart';
import '../services/user_service.dart';

class CityService {
  static const String _citiesEndpoint = '/countries/SN/cities';

  /// Récupérer toutes les villes du Sénégal
  static Future<List<City>> getAllCities() async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;

      final uri = Uri.parse('${ApiConfig.getBaseUrl()}$_citiesEndpoint');
      print('🏙️ Tentative de récupération des villes');
      print('URL: $uri');

      final httpRequest = await client.getUrl(uri);

      // Ajouter les headers par défaut
      ApiConfig.defaultHeaders.forEach((key, value) {
        httpRequest.headers.set(key, value);
      });

      // Ajouter le token d'authentification si disponible
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        httpRequest.headers.set('Authorization', authHeader);
        print('Token d\'authentification ajouté: $authHeader');
      }

      final response = await httpRequest.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('🌐 Cities API response status: ${response.statusCode}');
      print('📄 Cities API response body: $responseBody');

      client.close();

      if (response.statusCode == 200) {
        try {
          print('🔍 Parsing JSON des villes...');
          final Map<String, dynamic> jsonData = jsonDecode(responseBody);
          print('✅ JSON parsé avec succès');
          print('📊 Success: ${jsonData['success']}');
          print('📊 Message: ${jsonData['message']}');
          print('📊 Result data length: ${jsonData['result']['data'].length}');

          final cityResponse = CityResponse.fromJson(jsonData);
          print('🎯 CityResponse créé avec ${cityResponse.result.data.length} éléments');
          return cityResponse.result.data;
        } catch (parseError) {
          print('❌ JSON parsing error for cities: $parseError');
          print('📄 Response body was: $responseBody');
          return [];
        }
      } else {
        print(
          '❌ Erreur lors de la récupération des villes: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('Error fetching cities: $e');
      return [];
    }
  }

  /// Filtrer les villes actives
  static List<City> getActiveCities(List<City> cities) {
    return cities.where((city) => city.active).toList();
  }

  /// Récupérer une ville par son ID
  static City? getCityById(List<City> cities, int id) {
    try {
      return cities.firstWhere((city) => city.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Récupérer les villes les plus peuplées (pour affichage prioritaire)
  static List<City> getPopularCities(List<City> cities, {int limit = 10}) {
    final sortedCities = List<City>.from(cities);
    sortedCities.sort((a, b) => b.population.compareTo(a.population));
    return sortedCities.take(limit).toList();
  }

  /// Rechercher des villes par nom
  static List<City> searchCitiesByName(List<City> cities, String query) {
    if (query.isEmpty) return cities;
    
    final lowerQuery = query.toLowerCase();
    return cities.where((city) => 
      city.name.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}

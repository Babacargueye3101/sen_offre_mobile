import 'dart:convert';
import 'dart:io';
import '../models/category.dart';
import '../config/api_config.dart';
import 'api_service.dart';
import 'user_service.dart';

class CategoryService {
  static const Map<String, String> _headers = ApiConfig.defaultHeaders;

  /// Récupérer toutes les catégories avec pagination
  static Future<CategoryResponse> getCategories({int page = 1}) async {
    try {
      print('Tentative de récupération des catégories, page: $page');
      print('URL: ${ApiConfig.getBaseUrl()}${ApiConfig.categoriesEndpoint}?page=$page');
      
      final client = HttpClient();
      // Désactiver la vérification SSL pour le développement local
      client.badCertificateCallback = (cert, host, port) {
        print('Certificat SSL ignoré pour: $host:$port');
        return true;
      };
      
      final uri = Uri.parse('${ApiConfig.getBaseUrl()}${ApiConfig.categoriesEndpoint}?page=$page');
      final httpRequest = await client.getUrl(uri);
      
      // Ajouter les headers
      _headers.forEach((key, value) {
        httpRequest.headers.set(key, value);
      });
      
      // Ajouter le token d'authentification si disponible
      if (UserService.isLoggedIn && UserService.authToken != null && UserService.authToken!.isNotEmpty) {
        httpRequest.headers.set('Authorization', 'Bearer ${UserService.authToken}');
        print('Token d\'authentification ajouté: ${UserService.authToken}');
      } else {
        print('Aucun token d\'authentification disponible - isLoggedIn: ${UserService.isLoggedIn}, token: ${UserService.authToken}');
      }
      
      final response = await httpRequest.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('Categories response status: ${response.statusCode}');
      print('Categories response body: $responseBody');
      print('Response headers: ${response.headers}');

      client.close();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(responseBody);
        return CategoryResponse.fromJson(jsonData);
      } else {
        // Gérer les erreurs de l'API
        final Map<String, dynamic> errorData = jsonDecode(responseBody);
        throw ApiException(
          message: errorData['message'] ?? 'Erreur lors de la récupération des catégories',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      
      // Gérer les différents types d'erreurs
      String errorMessage;
      if (e.toString().contains('HandshakeException')) {
        errorMessage = 'Erreur SSL. Vérifiez la configuration du serveur.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Délai d\'attente dépassé. Le serveur ne répond pas.';
      } else {
        errorMessage = 'Erreur de connexion: ${e.toString()}';
      }
      
      print('Erreur détaillée: $e');
      throw ApiException(
        message: errorMessage,
        statusCode: 0,
      );
    }
  }

  /// Récupérer toutes les catégories (toutes les pages)
  static Future<List<Category>> getAllCategories() async {
    List<Category> allCategories = [];
    int currentPage = 1;
    bool hasMorePages = true;

    try {
      while (hasMorePages) {
        final response = await getCategories(page: currentPage);
        
        if (response.success) {
          allCategories.addAll(response.result.data);
          
          // Vérifier s'il y a d'autres pages
          hasMorePages = currentPage < response.result.meta.lastPage;
          currentPage++;
        } else {
          hasMorePages = false;
        }
      }
      
      return allCategories;
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer une catégorie par son ID
  static Future<Category?> getCategoryById(int id) async {
    try {
      final categories = await getAllCategories();
      return categories.firstWhere(
        (category) => category.id == id,
        orElse: () => throw Exception('Catégorie non trouvée'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Filtrer les catégories actives
  static List<Category> getActiveCategories(List<Category> categories) {
    return categories.where((category) => category.active == 1).toList();
  }

  /// Rechercher des catégories par nom
  static List<Category> searchCategories(List<Category> categories, String query) {
    if (query.isEmpty) return categories;
    
    final lowerQuery = query.toLowerCase();
    return categories.where((category) => 
      category.name.toLowerCase().contains(lowerQuery) ||
      category.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}

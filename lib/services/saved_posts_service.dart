import 'dart:convert';
import 'dart:io';
import '../config/api_config.dart';
import '../services/user_service.dart';
import '../models/saved_post.dart';

class SavedPostsService {
  static const Map<String, String> _headers = ApiConfig.defaultHeaders;

  /// Ajouter une offre aux favoris
  static Future<bool> addToFavorites(int postId) async {
    try {
      print('🔄 Ajout aux favoris - Post ID: $postId');
      
      final client = HttpClient();
      // Désactiver la vérification SSL pour le développement local
      client.badCertificateCallback = (cert, host, port) => true;
      
      final uri = Uri.parse('${ApiConfig.getBaseUrl()}${ApiConfig.savedPostsEndpoint}');
      final httpRequest = await client.postUrl(uri);
      
      // Ajouter les headers
      _headers.forEach((key, value) {
        httpRequest.headers.set(key, value);
      });
      
      // Ajouter l'autorisation si l'utilisateur est connecté
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        httpRequest.headers.set('Authorization', authHeader);
      }
      
      // Ajouter le body avec le post_id
      final body = jsonEncode({
        'post_id': postId,
      });
      httpRequest.write(body);
      
      final response = await httpRequest.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('📦 Favoris response status: ${response.statusCode}');
      print('📦 Favoris response body: $responseBody');

      client.close();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Offre ajoutée aux favoris avec succès');
        return true;
      } else {
        print('❌ Erreur lors de l\'ajout aux favoris: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Exception lors de l\'ajout aux favoris: $e');
      return false;
    }
  }

  /// Supprimer une offre des favoris
  static Future<bool> removeFromFavorites(int postId) async {
    try {
      print('🔄 Suppression des favoris - Post ID: $postId');
      
      final client = HttpClient();
      // Désactiver la vérification SSL pour le développement local
      client.badCertificateCallback = (cert, host, port) => true;
      
      final uri = Uri.parse('${ApiConfig.getBaseUrl()}${ApiConfig.savedPostsEndpoint}/$postId');
      final httpRequest = await client.deleteUrl(uri);
      
      // Ajouter les headers
      _headers.forEach((key, value) {
        httpRequest.headers.set(key, value);
      });
      
      // Ajouter l'autorisation si l'utilisateur est connecté
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        httpRequest.headers.set('Authorization', authHeader);
      }
      
      final response = await httpRequest.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('📦 Suppression favoris response status: ${response.statusCode}');
      print('📦 Suppression favoris response body: $responseBody');

      client.close();

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Offre supprimée des favoris avec succès');
        return true;
      } else {
        print('❌ Erreur lors de la suppression des favoris: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Exception lors de la suppression des favoris: $e');
      return false;
    }
  }

  /// Vérifier si une offre est dans les favoris
  static Future<bool> isFavorite(int postId) async {
    try {
      print('🔄 Vérification favoris - Post ID: $postId');
      
      final client = HttpClient();
      // Désactiver la vérification SSL pour le développement local
      client.badCertificateCallback = (cert, host, port) => true;
      
      final uri = Uri.parse('${ApiConfig.getBaseUrl()}${ApiConfig.savedPostsEndpoint}');
      final httpRequest = await client.getUrl(uri);
      
      // Ajouter les headers
      _headers.forEach((key, value) {
        httpRequest.headers.set(key, value);
      });
      
      // Ajouter l'autorisation si l'utilisateur est connecté
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        httpRequest.headers.set('Authorization', authHeader);
      }
      
      final response = await httpRequest.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('📦 Vérification favoris response status: ${response.statusCode}');

      client.close();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(responseBody);
        // Ici, vous devrez adapter selon la structure de réponse de votre API
        // Par exemple, si l'API retourne une liste des favoris
        if (jsonData['result'] != null && jsonData['result']['data'] != null) {
          final List<dynamic> favorites = jsonData['result']['data'];
          return favorites.any((fav) => fav['post_id'] == postId);
        }
        return false;
      } else {
        print('❌ Erreur lors de la vérification des favoris: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Exception lors de la vérification des favoris: $e');
      return false;
    }
  }

  /// Récupérer la liste des offres sauvegardées
  static Future<SavedPostResponse?> getSavedPosts() async {
    try {
      print('🔄 Récupération des favoris...');
      
      final client = HttpClient();
      // Désactiver la vérification SSL pour le développement local
      client.badCertificateCallback = (cert, host, port) => true;
      
      final uri = Uri.parse('${ApiConfig.getBaseUrl()}${ApiConfig.savedPostsEndpoint}?embed=post&sort=created_at');
      final httpRequest = await client.getUrl(uri);
      
      // Ajouter les headers
      _headers.forEach((key, value) {
        httpRequest.headers.set(key, value);
      });
      
      // Ajouter l'autorisation si l'utilisateur est connecté
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        httpRequest.headers.set('Authorization', authHeader);
      }
      
      final response = await httpRequest.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('📦 Favoris response status: ${response.statusCode}');
      print('📦 Favoris response body: ${responseBody.substring(0, responseBody.length > 500 ? 500 : responseBody.length)}...');

      client.close();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(responseBody);
        return SavedPostResponse.fromJson(jsonData);
      } else {
        print('❌ Erreur lors de la récupération des favoris: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Exception lors de la récupération des favoris: $e');
      return null;
    }
  }
}

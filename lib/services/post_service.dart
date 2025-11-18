import 'dart:convert';
import 'dart:io';
import '../models/post.dart';
import '../config/api_config.dart';
import 'user_service.dart';

class PostService {
  static const String _postsEndpoint = '/posts';

  /// Récupérer les offres avec pagination et filtres
  static Future<PostResponse> getPosts({
    int page = 1,
    int perPage = 10,
    int? cityId,
    int? postTypeId,
    int? categoryId,
  }) async {
    try {
      final client = HttpClient();
      // Désactiver la vérification SSL pour le développement local
      client.badCertificateCallback = (cert, host, port) => true;
      
      // Construire l'URL avec les paramètres de pagination et filtres
      final queryParams = {
        'page': page.toString(),
        'perPage': perPage.toString(),
        if (cityId != null) 'city_id': cityId.toString(),
        if (postTypeId != null) 'post_type_id': postTypeId.toString(),
        if (categoryId != null) 'category_id': categoryId.toString(),
      };
      
      final uri = Uri.parse('${ApiConfig.getBaseUrl()}$_postsEndpoint').replace(
        queryParameters: queryParams,
      );
      final httpRequest = await client.getUrl(uri);
      
      // Ajouter les headers par défaut
      ApiConfig.defaultHeaders.forEach((key, value) {
        httpRequest.headers.set(key, value);
      });
      
      // Ajouter le token d'authentification si disponible
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        httpRequest.headers.set('Authorization', authHeader);
        print('Using auth header: $authHeader');
      } else {
        print('Warning: No auth token available');
      }
      
      final response = await httpRequest.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('Posts API response status: ${response.statusCode}');
      print('Posts API response body: ${responseBody.substring(0, responseBody.length > 500 ? 500 : responseBody.length)}...');

      client.close();

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonData = jsonDecode(responseBody);
          print('JSON parsing successful, creating PostResponse...');
          return PostResponse.fromJson(jsonData);
        } catch (parseError) {
          print('JSON parsing error: $parseError');
          print('Response body: $responseBody');
          throw PostException(
            message: 'Erreur lors du parsing des données: $parseError',
            statusCode: response.statusCode,
          );
        }
      } else {
        // Gérer les erreurs de l'API
        throw PostException(
          message: 'Erreur lors de la récupération des offres',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      // Gérer les erreurs de réseau ou autres
      print('Error fetching posts: $e');
      throw PostException(
        message: 'Erreur de connexion. Veuillez vérifier votre connexion internet.',
        statusCode: 0,
      );
    }
  }

  /// Récupérer une offre par son ID
  static Future<Post?> getPostById(int id) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      
      final uri = Uri.parse('${ApiConfig.getBaseUrl()}$_postsEndpoint/$id');
      final httpRequest = await client.getUrl(uri);
      
      // Ajouter les headers par défaut
      ApiConfig.defaultHeaders.forEach((key, value) {
        httpRequest.headers.set(key, value);
      });
      
      // Ajouter le token d'authentification si disponible
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        httpRequest.headers.set('Authorization', authHeader);
      }
      
      final response = await httpRequest.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      client.close();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(responseBody);
        if (jsonData['success'] == true && jsonData['result'] != null) {
          return Post.fromJson(jsonData['result']);
        }
      }
      
      return null;
    } catch (e) {
      print('Error fetching post by ID: $e');
      return null;
    }
  }

  /// Rechercher des offres
  static Future<PostResponse> searchPosts({
    String? query,
    int? categoryId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      
      // Construire les paramètres de recherche
      final queryParams = <String, String>{
        'page': page.toString(),
        'perPage': perPage.toString(),
      };
      
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      
      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }
      
      final uri = Uri.parse('${ApiConfig.getBaseUrl()}$_postsEndpoint')
          .replace(queryParameters: queryParams);
      final httpRequest = await client.getUrl(uri);
      
      // Ajouter les headers par défaut
      ApiConfig.defaultHeaders.forEach((key, value) {
        httpRequest.headers.set(key, value);
      });
      
      // Ajouter le token d'authentification si disponible
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        httpRequest.headers.set('Authorization', authHeader);
      }
      
      final response = await httpRequest.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      client.close();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(responseBody);
        return PostResponse.fromJson(jsonData);
      } else {
        throw PostException(
          message: 'Erreur lors de la recherche des offres',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      print('Error searching posts: $e');
      throw PostException(
        message: 'Erreur de connexion lors de la recherche.',
        statusCode: 0,
      );
    }
  }
}

class PostException implements Exception {
  final String message;
  final int statusCode;

  PostException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => message;
}

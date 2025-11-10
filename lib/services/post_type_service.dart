import 'dart:convert';
import 'dart:io';
import '../config/api_config.dart';
import '../models/post_type.dart';
import '../services/user_service.dart';

class PostTypeService {
  static const String _postTypesEndpoint = '/postTypes';

  /// Récupérer tous les types d'offres
  static Future<List<PostType>> getAllPostTypes() async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;

      final uri = Uri.parse('${ApiConfig.getBaseUrl()}$_postTypesEndpoint');
      print('Tentative de récupération des types d\'offres');
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

      print('🌐 PostTypes API response status: ${response.statusCode}');
      print('📄 PostTypes API response body: $responseBody');

      client.close();

      if (response.statusCode == 200) {
        try {
          print('🔍 Parsing JSON des types d\'offres...');
          final Map<String, dynamic> jsonData = jsonDecode(responseBody);
          print('✅ JSON parsé avec succès');
          print('📊 Success: ${jsonData['success']}');
          print('📊 Message: ${jsonData['message']}');
          print('📊 Result data length: ${jsonData['result']['data'].length}');

          final postTypeResponse = PostTypeResponse.fromJson(jsonData);
          print(
            '🎯 PostTypeResponse créé avec ${postTypeResponse.result.data.length} éléments',
          );
          return postTypeResponse.result.data;
        } catch (parseError) {
          print('❌ JSON parsing error for post types: $parseError');
          print('📄 Response body was: $responseBody');
          return [];
        }
      } else {
        print(
          '❌ Erreur lors de la récupération des types d\'offres: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('Error fetching post types: $e');
      return [];
    }
  }

  /// Filtrer les types d'offres actifs
  static List<PostType> getActivePostTypes(List<PostType> postTypes) {
    return postTypes.where((postType) => postType.active).toList();
  }

  /// Récupérer un type d'offre par son ID
  static PostType? getPostTypeById(List<PostType> postTypes, int id) {
    try {
      return postTypes.firstWhere((postType) => postType.id == id);
    } catch (e) {
      return null;
    }
  }
}

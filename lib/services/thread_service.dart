import 'dart:convert';
import 'dart:io';
import '../models/thread.dart';
import '../config/api_config.dart';
import 'user_service.dart';

class ThreadService {
  static const String _threadsEndpoint = '/threads';

  /// Récupérer l'historique des candidatures de l'utilisateur
  static Future<ThreadResponse> getUserThreads({
    String filter = 'started',
    String embed = 'post',
    int perPage = 50,
  }) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      
      // Construire l'URL avec les paramètres
      final uri = Uri.parse(
        '${ApiConfig.getBaseUrl()}$_threadsEndpoint?filter=$filter&embed=$embed&perPage=$perPage'
      );
      
      print('Thread API URL: $uri');
      
      final httpRequest = await client.getUrl(uri);
      
      // Ajouter les headers
      ApiConfig.defaultHeaders.forEach((key, value) {
        httpRequest.headers.set(key, value);
      });
      
      // Ajouter le token d'authentification
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        httpRequest.headers.set('Authorization', authHeader);
        print('Using auth header: $authHeader');
      } else {
        throw Exception('Non authentifié');
      }
      
      final httpResponse = await httpRequest.close();
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      
      print('Thread API Response Status: ${httpResponse.statusCode}');
      print('Thread API Response: $responseBody');
      
      if (httpResponse.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return ThreadResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Erreur lors de la récupération de l\'historique: ${httpResponse.statusCode}');
      }
    } catch (e) {
      print('Erreur getUserThreads: $e');
      rethrow;
    }
  }
}

import 'dart:convert';
import 'dart:io';
import '../models/resume.dart';
import '../config/api_config.dart';
import 'user_service.dart';

class ResumeService {
  static const String _resumesEndpoint = '/resumes';

  /// Récupérer les CV de l'utilisateur connecté
  static Future<ResumeResponse> getUserResumes({
    int perPage = 10,
  }) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      
      // Construire l'URL avec les paramètres
      final uri = Uri.parse(
        '${ApiConfig.getBaseUrl()}$_resumesEndpoint?belongLoggedUser=1&perPage=$perPage'
      );
      
      final httpRequest = await client.getUrl(uri);
      
      // Ajouter les headers
      ApiConfig.defaultHeaders.forEach((key, value) {
        httpRequest.headers.set(key, value);
      });
      
      // Ajouter le token d'authentification
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        httpRequest.headers.set('Authorization', authHeader);
      } else {
        throw Exception('Non authentifié');
      }
      
      final httpResponse = await httpRequest.close();
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      
      print('Resume API Response: $responseBody');
      
      if (httpResponse.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return ResumeResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Erreur lors de la récupération des CV: ${httpResponse.statusCode}');
      }
    } catch (e) {
      print('Erreur getUserResumes: $e');
      rethrow;
    }
  }

  /// Postuler à une offre avec un CV existant ou nouveau
  static Future<Map<String, dynamic>> applyToPost({
    required int postId,
    required String body,
    int? resumeId,
    File? resumeFile,
  }) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      
      final uri = Uri.parse('${ApiConfig.getBaseUrl()}/threads');
      final httpRequest = await client.postUrl(uri);
      
      // Créer la requête multipart
      final boundary = 'dart-boundary-${DateTime.now().millisecondsSinceEpoch}';
      httpRequest.headers.set('Content-Type', 'multipart/form-data; boundary=$boundary');
      
      // Ajouter le token d'authentification
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        httpRequest.headers.set('Authorization', authHeader);
      } else {
        throw Exception('Non authentifié');
      }
      
      // Construire le corps de la requête multipart
      final List<int> bodyBytes = [];
      
      // Ajouter post_id
      bodyBytes.addAll(utf8.encode('--$boundary\r\n'));
      bodyBytes.addAll(utf8.encode('Content-Disposition: form-data; name="post_id"\r\n\r\n'));
      bodyBytes.addAll(utf8.encode('$postId\r\n'));
      
      // Ajouter body
      bodyBytes.addAll(utf8.encode('--$boundary\r\n'));
      bodyBytes.addAll(utf8.encode('Content-Disposition: form-data; name="body"\r\n\r\n'));
      bodyBytes.addAll(utf8.encode('$body\r\n'));
      
      // Ajouter resume_id si fourni
      if (resumeId != null) {
        bodyBytes.addAll(utf8.encode('--$boundary\r\n'));
        bodyBytes.addAll(utf8.encode('Content-Disposition: form-data; name="resume_id"\r\n\r\n'));
        bodyBytes.addAll(utf8.encode('$resumeId\r\n'));
      }
      
      // Ajouter le fichier CV si fourni
      if (resumeFile != null) {
        final fileBytes = await resumeFile.readAsBytes();
        final filename = resumeFile.path.split('/').last;
        
        bodyBytes.addAll(utf8.encode('--$boundary\r\n'));
        bodyBytes.addAll(utf8.encode(
          'Content-Disposition: form-data; name="resume[filename]"; filename="$filename"\r\n'
        ));
        bodyBytes.addAll(utf8.encode('Content-Type: application/octet-stream\r\n\r\n'));
        bodyBytes.addAll(fileBytes);
        bodyBytes.addAll(utf8.encode('\r\n'));
      }
      
      // Fermer la requête multipart
      bodyBytes.addAll(utf8.encode('--$boundary--\r\n'));
      
      httpRequest.contentLength = bodyBytes.length;
      httpRequest.add(bodyBytes);
      
      final httpResponse = await httpRequest.close();
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      
      print('Apply API Response: $responseBody');
      
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception('Erreur lors de la candidature: ${httpResponse.statusCode}');
      }
    } catch (e) {
      print('Erreur applyToPost: $e');
      rethrow;
    }
  }
}

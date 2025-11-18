import 'dart:convert';
import 'dart:io';
import '../config/api_config.dart';
import '../services/user_service.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class MessagingService {
  /// Récupérer la liste des conversations
  static Future<ConversationResponse> getConversations({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;

      final uri = Uri.parse(
        '${ApiConfig.getBaseUrl()}/threads?page=$page&perPage=$perPage',
      );

      final request = await client.openUrl('GET', uri);
      request.headers.set('Accept', 'application/json');
      
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        request.headers.set('Authorization', authHeader);
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('Get Conversations Response: $responseBody');

      if (response.statusCode == 200) {
        return ConversationResponse.fromJson(json.decode(responseBody));
      } else {
        throw Exception('Erreur lors du chargement des conversations');
      }
    } catch (e) {
      print('Erreur getConversations: $e');
      rethrow;
    }
  }

  /// Récupérer les détails d'une conversation avec ses messages
  static Future<ConversationDetailResponse> getConversationDetail(int threadId) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;

      final uri = Uri.parse('${ApiConfig.getBaseUrl()}/threads/$threadId');

      final request = await client.openUrl('GET', uri);
      request.headers.set('Accept', 'application/json');
      
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        request.headers.set('Authorization', authHeader);
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('Get Conversation Detail Response: $responseBody');

      if (response.statusCode == 200) {
        return ConversationDetailResponse.fromJson(json.decode(responseBody));
      } else {
        throw Exception('Erreur lors du chargement de la conversation');
      }
    } catch (e) {
      print('Erreur getConversationDetail: $e');
      rethrow;
    }
  }

  /// Récupérer les messages d'une conversation
  static Future<MessageResponse> getMessages(int threadId) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;

      final uri = Uri.parse('${ApiConfig.getBaseUrl()}/threads/$threadId/messages');

      final request = await client.openUrl('GET', uri);
      request.headers.set('Accept', 'application/json');
      
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        request.headers.set('Authorization', authHeader);
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('Get Messages Response: $responseBody');

      if (response.statusCode == 200) {
        return MessageResponse.fromJson(json.decode(responseBody));
      } else {
        throw Exception('Erreur lors du chargement des messages');
      }
    } catch (e) {
      print('Erreur getMessages: $e');
      rethrow;
    }
  }

  /// Créer une nouvelle conversation
  static Future<ConversationDetailResponse> createConversation({
    required int postId,
    required int toUserId,
    required String subject,
    required String message,
  }) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;

      final uri = Uri.parse('${ApiConfig.getBaseUrl()}/threads');
      final request = await client.openUrl('POST', uri);

      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');
      
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        request.headers.set('Authorization', authHeader);
      }

      final data = {
        'post_id': postId,
        'to_user_id': toUserId,
        'subject': subject,
        'message': message,
      };

      request.write(json.encode(data));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('Create Conversation Response: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ConversationDetailResponse.fromJson(json.decode(responseBody));
      } else {
        final errorResponse = json.decode(responseBody);
        throw Exception(errorResponse['message'] ?? 'Erreur lors de la création de la conversation');
      }
    } catch (e) {
      print('Erreur createConversation: $e');
      rethrow;
    }
  }

  /// Envoyer un message dans une conversation
  static Future<Map<String, dynamic>> sendMessage({
    required int threadId,
    required String body,
  }) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;

      final uri = Uri.parse('${ApiConfig.getBaseUrl()}/threads/$threadId/messages');
      final request = await client.openUrl('POST', uri);

      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');
      
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        request.headers.set('Authorization', authHeader);
      }

      final data = {'body': body};
      request.write(json.encode(data));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('Send Message Response: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        final errorResponse = json.decode(responseBody);
        throw Exception(errorResponse['message'] ?? 'Erreur lors de l\'envoi du message');
      }
    } catch (e) {
      print('Erreur sendMessage: $e');
      rethrow;
    }
  }

  /// Supprimer un message
  static Future<bool> deleteMessage(int threadId, int messageId) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;

      final uri = Uri.parse('${ApiConfig.getBaseUrl()}/threads/$threadId/messages/$messageId');
      final request = await client.openUrl('DELETE', uri);

      request.headers.set('Accept', 'application/json');
      
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        request.headers.set('Authorization', authHeader);
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('Delete Message Response: $responseBody');

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur deleteMessage: $e');
      return false;
    }
  }

  /// Marquer une conversation comme lue
  static Future<bool> markAsRead(int threadId) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;

      final uri = Uri.parse('${ApiConfig.getBaseUrl()}/threads/$threadId/mark-as-read');
      final request = await client.openUrl('POST', uri);

      request.headers.set('Accept', 'application/json');
      
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        request.headers.set('Authorization', authHeader);
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('Mark As Read Response: $responseBody');

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur markAsRead: $e');
      return false;
    }
  }

  /// Archiver une conversation
  static Future<bool> archiveConversation(int threadId) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;

      final uri = Uri.parse('${ApiConfig.getBaseUrl()}/threads/$threadId/archive');
      final request = await client.openUrl('POST', uri);

      request.headers.set('Accept', 'application/json');
      
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        request.headers.set('Authorization', authHeader);
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('Archive Conversation Response: $responseBody');

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur archiveConversation: $e');
      return false;
    }
  }

  /// Désarchiver une conversation
  static Future<bool> unarchiveConversation(int threadId) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;

      final uri = Uri.parse('${ApiConfig.getBaseUrl()}/threads/$threadId/unarchive');
      final request = await client.openUrl('POST', uri);

      request.headers.set('Accept', 'application/json');
      
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        request.headers.set('Authorization', authHeader);
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('Unarchive Conversation Response: $responseBody');

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur unarchiveConversation: $e');
      return false;
    }
  }
}

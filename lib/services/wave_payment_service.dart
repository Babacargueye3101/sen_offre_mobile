import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'user_service.dart';

class WavePaymentService {
  static Future<Map<String, dynamic>> initiatePayment({
    required double amount,
    required String reference,
    required String description,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.getBaseUrl()}/payments/wave/initiate');
      
      final body = {
        'amount': amount,
        'reference': reference,
        'description': description,
      };

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-AppApiToken': ApiConfig.defaultHeaders['X-AppApiToken'] ?? 'senoffre_api_token_2024_secure_key_xyz123',
      };

      // Ajouter le token d'authentification si disponible
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        headers['Authorization'] = authHeader;
      }

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> checkPaymentStatus({
    required String checkoutId,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.getBaseUrl()}/payments/wave/status/$checkoutId');
      
      final headers = {
        'Accept': 'application/json',
        'X-AppApiToken': ApiConfig.defaultHeaders['X-AppApiToken'] ?? 'senoffre_api_token_2024_secure_key_xyz123',
      };

      // Ajouter le token d'authentification si disponible
      final authHeader = UserService.authorizationHeader;
      if (authHeader != null) {
        headers['Authorization'] = authHeader;
      }

      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

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

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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
      
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
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

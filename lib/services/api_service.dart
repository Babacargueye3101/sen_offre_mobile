import 'dart:convert';
import 'dart:io';
import '../models/registration_request.dart';
import '../models/registration_response.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../config/api_config.dart';

class ApiService {
  static const Map<String, String> _headers = ApiConfig.defaultHeaders;

  /// Inscription d'un nouvel utilisateur
  static Future<RegistrationResponse> registerUser(RegistrationRequest request) async {
    try {
      print('Submitting registration: ${request.toJson()}');
      
      final client = HttpClient();
      final uri = Uri.parse('${ApiConfig.getBaseUrl()}${ApiConfig.registerEndpoint}');
      final httpRequest = await client.postUrl(uri);
      
      // Ajouter les headers
      _headers.forEach((key, value) {
        httpRequest.headers.set(key, value);
      });
      
      // Ajouter le body
      final body = jsonEncode(request.toJson());
      httpRequest.write(body);
      
      final response = await httpRequest.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      client.close();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(responseBody);
        return RegistrationResponse.fromJson(jsonData);
      } else {
        // Gérer les erreurs de l'API
        final Map<String, dynamic> errorData = jsonDecode(responseBody);
        final apiError = ApiError.fromJson(errorData);
        throw ApiException(
          message: apiError.message,
          statusCode: response.statusCode,
          errors: apiError.errors,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      // Gérer les erreurs de réseau ou autres
      throw ApiException(
        message: 'Erreur de connexion. Veuillez vérifier votre connexion internet.',
        statusCode: 0,
      );
    }
  }

  /// Connexion d'un utilisateur
  static Future<LoginResponse> loginUser(LoginRequest request) async {
    try {
      print('Submitting login: ${request.toJson()}');
      
      final client = HttpClient();
      final uri = Uri.parse('${ApiConfig.getBaseUrl()}${ApiConfig.loginEndpoint}');
      final httpRequest = await client.postUrl(uri);
      
      // Ajouter les headers
      _headers.forEach((key, value) {
        httpRequest.headers.set(key, value);
      });
      
      // Ajouter le body
      final body = jsonEncode(request.toJson());
      httpRequest.write(body);
      
      final response = await httpRequest.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('Login response status: ${response.statusCode}');
      print('Login response body: $responseBody');

      client.close();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(responseBody);
        return LoginResponse.fromJson(jsonData);
      } else {
        // Gérer les erreurs de l'API
        final Map<String, dynamic> errorData = jsonDecode(responseBody);
        final apiError = ApiError.fromJson(errorData);
        throw ApiException(
          message: apiError.message,
          statusCode: response.statusCode,
          errors: apiError.errors,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      // Gérer les erreurs de réseau ou autres
      throw ApiException(
        message: 'Erreur de connexion. Veuillez vérifier votre connexion internet.',
        statusCode: 0,
      );
    }
  }

  /// Convertir le type de compte en user_type_id
  static int getUserTypeId(String accountType) {
    // Map userType to user_type_id: 1 = Employeur, 2 = Demandeur d'emploi
    switch (accountType.toLowerCase()) {
      case 'societe':
      case 'employer':
        return 1; // Employeur
      case 'consultant':
      case 'demandeur':
      default:
        return 2; // Demandeur d'emploi
    }
  }

  /// Convertir la civilité en gender_id
  static int getGenderId(String? civilite) {
    // Map civilité to gender_id: 1 = Homme, 2 = Femme
    switch (civilite?.toLowerCase()) {
      case 'm.':
      case 'monsieur':
        return 1; // Homme
      case 'mme':
      case 'mlle':
      case 'madame':
      case 'mademoiselle':
        return 2; // Femme
      default:
        return 1; // Par défaut Homme
    }
  }

  /// Formater le téléphone avec le code pays
  static String formatPhoneWithCountry(String phone, String countryCode) {
    // Nettoyer le téléphone (supprimer espaces, tirets, etc.)
    final cleanPhone = phone.replaceAll(RegExp(r'[\s-]'), '');
    
    // Ajouter le code pays avec le +
    return '$countryCode$cleanPhone';
  }

  /// Extraire le code pays numérique (sans le +)
  static String getNumericCountryCode(String countryCode) {
    // Supprimer le + du début si présent
    return countryCode.startsWith('+') ? countryCode.substring(1) : countryCode;
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, List<String>>? errors;

  ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
  });

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      // Retourner la première erreur trouvée
      final firstError = errors!.values.first.first;
      return firstError;
    }
    return message;
  }

  /// Obtenir toutes les erreurs sous forme de liste
  List<String> getAllErrors() {
    if (errors == null) return [message];
    
    List<String> allErrors = [];
    errors!.forEach((field, fieldErrors) {
      allErrors.addAll(fieldErrors);
    });
    
    return allErrors.isEmpty ? [message] : allErrors;
  }
}

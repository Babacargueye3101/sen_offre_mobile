import 'dart:io';

class ApiConfig {
  // URL de base de l'API - Configuration automatique selon la plateforme
  static String get baseUrl {
    if (Platform.isIOS) {
      // Pour iOS (simulateur et appareil physique)
      return 'http://localhost:8000/api';
    } else if (Platform.isAndroid) {
      // Pour l'émulateur Android
      return 'http://10.0.2.2:8000/api';
    } else {
      // Fallback pour autres plateformes
      return 'http://localhost:8000/api';
    }
  }
  
  // Endpoints
  static const String registerEndpoint = '/users';
  static const String loginEndpoint = '/auth/login';
  static const String categoriesEndpoint = '/categories';
  static const String postsEndpoint = '/posts';
  static const String savedPostsEndpoint = '/savedPosts';
  static const String companiesEndpoint = '/companies';
  
  // Headers par défaut
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Configuration pour les différents environnements
  static String getBaseUrl() {
    // En production, vous pouvez changer cette URL
    // return 'https://your-production-api.com/api';
    return baseUrl;
  }
}

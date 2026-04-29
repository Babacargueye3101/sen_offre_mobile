class ApiConfig {
  // URL de base de l'API - Configuration automatique selon la plateforme
  static String get baseUrl {
    return 'http://update.senoffre.com/api';
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
    'X-AppApiToken': 'senoffre_api_token_2024_secure_key_xyz123',
  };
  
  // Configuration pour les différents environnements
  static String getBaseUrl() {
    // En production, vous pouvez changer cette URL
    // return 'https://your-production-api.com/api';
    return baseUrl;
  }
}

class ApiConfig {
  // URL de base de l'API
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Endpoints
  static const String registerEndpoint = '/users';
  static const String loginEndpoint = '/auth/login';
  
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

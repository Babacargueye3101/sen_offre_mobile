class ApiConfig {
  // URL de base de l'API
  // Pour l'émulateur Android, utilisez 10.0.2.2 au lieu de localhost
  // Pour un appareil physique, utilisez l'adresse IP de votre machine (ex: 192.168.1.x)
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
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

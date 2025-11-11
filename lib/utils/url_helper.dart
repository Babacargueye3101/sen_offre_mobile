class UrlHelper {
  /// Convertit les URLs localhost en URLs accessibles depuis l'émulateur Android
  /// Pour l'émulateur Android: localhost -> 10.0.2.2
  /// Pour un appareil physique, vous devrez utiliser l'IP de votre machine
  static String fixImageUrl(String url) {
    if (url.isEmpty) return url;
    
    // Remplacer localhost par 10.0.2.2 pour l'émulateur Android
    String fixedUrl = url.replaceAll('localhost', '10.0.2.2');
    
    // Remplacer https par http pour le développement local
    // (évite les problèmes de certificat SSL)
    if (fixedUrl.contains('10.0.2.2')) {
      fixedUrl = fixedUrl.replaceAll('https://', 'http://');
    }
    
    return fixedUrl;
  }
  
  /// Vérifie si une URL est une URL locale de développement
  static bool isLocalUrl(String url) {
    return url.contains('localhost') || 
           url.contains('127.0.0.1') || 
           url.contains('10.0.2.2');
  }
}

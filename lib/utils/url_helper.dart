import 'dart:io';

class UrlHelper {
  /// Convertit les URLs localhost en URLs accessibles selon la plateforme
  /// Pour l'émulateur Android: localhost -> 10.0.2.2
  /// Pour iOS: garde localhost (fonctionne sur simulateur)
  static String fixImageUrl(String url) {
    if (url.isEmpty) return url;
    
    String fixedUrl = url;
    
    // Forcer HTTP pour le développement local (éviter les problèmes SSL)
    fixedUrl = url.replaceAll('https://', 'http://');
    
    // Détection automatique de la plateforme
    if (fixedUrl.contains('localhost')) {
      try {
        // Pour l'émulateur Android: convertir localhost en 10.0.2.2
        if (Platform.isAndroid) {
          fixedUrl = fixedUrl.replaceAll('localhost', '10.0.2.2');
        }
        // Pour iOS simulateur: garder localhost tel quel
        // (localhost fonctionne directement sur iOS simulateur)
      } catch (e) {
        // Si Platform n'est pas disponible, garder l'URL originale
        fixedUrl = fixedUrl;
      }
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

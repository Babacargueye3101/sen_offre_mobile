import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static bool _isLoaded = false;

  /// Charger les variables d'environnement
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: ".env");
      _isLoaded = true;
      print('✅ Variables d\'environnement chargées avec succès');
      print('   - API Key: ${dotenv.env['AZURE_OPENAI_API_KEY']?.substring(0, 20)}...');
      print('   - Endpoint: ${dotenv.env['OPENAI_ENDPOINT']}');
    } catch (e) {
      print('⚠️  Erreur lors du chargement du .env: $e');
      print('⚠️  Utilisation des valeurs par défaut');
      _isLoaded = false;
    }
  }

  /// Vérifier si les variables sont chargées
  static bool get isLoaded => _isLoaded;

  /// Obtenir une variable d'environnement avec une valeur par défaut
  static String get(String key, {String defaultValue = ''}) {
    if (!_isLoaded) {
      return defaultValue;
    }
    return dotenv.env[key] ?? defaultValue;
  }

  // Azure OpenAI Configuration
  static String get azureOpenAIApiKey {
    final key = get('AZURE_OPENAI_API_KEY');
    if (key.isEmpty) {
      throw Exception('AZURE_OPENAI_API_KEY not found in .env file. Please create a .env file with your API key.');
    }
    return key;
  }
  
  static String get openAIEndpoint {
    final endpoint = get('OPENAI_ENDPOINT');
    if (endpoint.isEmpty) {
      // ⚠️ VALEUR DE SECOURS POUR LE DÉVELOPPEMENT
      return 'https://tuto-openai-sdt.openai.azure.com';
    }
    // Supprimer le slash final si présent
    return endpoint.endsWith('/') ? endpoint.substring(0, endpoint.length - 1) : endpoint;
  }
  
  static String get azureOpenAIApiVersion => get('AZURE_OPENAI_API_VERSION', defaultValue: '2023-05-15');
  static String get azureOpenAIDeployment => get('AZURE_OPENAI_DEPLOYMENT_GPT_35_TURBO', defaultValue: 'gpt-35-turbo');
}

import 'dart:convert';
import 'dart:io';
import '../config/env_config.dart';

class AzureOpenAIService {
  static String get _apiKey => EnvConfig.azureOpenAIApiKey;
  static String get _endpoint => EnvConfig.openAIEndpoint;
  static String get _apiVersion => EnvConfig.azureOpenAIApiVersion;
  static String get _deployment => EnvConfig.azureOpenAIDeployment;

  /// Envoyer un message au chatbot et obtenir une réponse
  static Future<String> sendMessage({
    required String userMessage,
    required String systemPrompt,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;

      // Construire l'URL de l'API Azure OpenAI
      print('🔍 Debug - Endpoint: $_endpoint');
      print('🔍 Debug - Deployment: $_deployment');
      print('🔍 Debug - API Version: $_apiVersion');
      
      final url = '$_endpoint/openai/deployments/$_deployment/chat/completions?api-version=$_apiVersion';
      final uri = Uri.parse(url);

      print('🤖 Calling Azure OpenAI API: $url');

      final httpRequest = await client.postUrl(uri);
      
      // Ajouter les headers avec encodage UTF-8
      httpRequest.headers.set('Content-Type', 'application/json; charset=utf-8');
      httpRequest.headers.set('api-key', _apiKey);

      // Construire les messages
      final messages = <Map<String, String>>[
        {'role': 'system', 'content': systemPrompt},
      ];

      // Ajouter l'historique de conversation si disponible
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        messages.addAll(conversationHistory);
      }

      // Ajouter le message de l'utilisateur
      messages.add({'role': 'user', 'content': userMessage});

      // Préparer le body de la requête
      final requestBody = {
        'messages': messages,
        'model': 'gpt-35-turbo',
        'max_tokens': 300, // Réduit de 800 à 300 pour des réponses plus rapides
        'temperature': 0.7,
        'top_p': 0.95,
        'frequency_penalty': 0,
        'presence_penalty': 0,
      };

      // Encoder le JSON en UTF-8
      final jsonBody = jsonEncode(requestBody);
      final utf8Body = utf8.encode(jsonBody);
      
      print('📤 Request body: ${jsonBody.substring(0, jsonBody.length > 200 ? 200 : jsonBody.length)}...');

      // Envoyer la requête avec encodage UTF-8
      httpRequest.add(utf8Body);

      final httpResponse = await httpRequest.close();
      final responseBody = await httpResponse.transform(utf8.decoder).join();

      print('📥 Response status: ${httpResponse.statusCode}');
      print('📥 Response body: $responseBody');

      client.close();

      if (httpResponse.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        
        // Extraire la réponse du chatbot
        if (jsonResponse['choices'] != null && 
            jsonResponse['choices'].isNotEmpty &&
            jsonResponse['choices'][0]['message'] != null) {
          final content = jsonResponse['choices'][0]['message']['content'];
          return content ?? 'Désolé, je n\'ai pas pu générer une réponse.';
        }
        
        return 'Désolé, je n\'ai pas pu générer une réponse.';
      } else {
        print('❌ Error response: $responseBody');
        throw Exception('Erreur API: ${httpResponse.statusCode}');
      }
    } catch (e) {
      print('❌ Error in sendMessage: $e');
      
      // Retourner un message d'erreur convivial au lieu de planter
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        return 'Désolé, je ne peux pas me connecter au service IA pour le moment. 😕\n\nVeuillez vérifier votre connexion internet et réessayer.';
      } else if (e.toString().contains('TimeoutException')) {
        return 'La connexion prend trop de temps. ⏱️\n\nVeuillez réessayer dans quelques instants.';
      } else {
        return 'Une erreur s\'est produite. 😕\n\nVeuillez réessayer.';
      }
    }
  }

  /// Analyser une requête utilisateur et extraire les paramètres de recherche
  static Future<Map<String, dynamic>> analyzeSearchQuery(String query) async {
    try {
      final systemPrompt = '''Tu es un assistant spécialisé dans l'analyse de requêtes de recherche d'emploi.
Ton rôle est d'extraire les informations pertinentes d'une requête utilisateur et de les structurer en JSON.

Extrait les informations suivantes si elles sont présentes:
- keywords: mots-clés de recherche (titre de poste, compétences)
- location: ville ou région
- timeframe: période (ex: "mois dernier", "année passée", "cette semaine")
- category: catégorie d'emploi
- salary_min: salaire minimum si mentionné
- salary_max: salaire maximum si mentionné

Réponds UNIQUEMENT avec un objet JSON valide, sans texte supplémentaire.
Exemple: {"keywords": "développeur", "location": "Dakar", "timeframe": "month"}''';

      final response = await sendMessage(
        userMessage: query,
        systemPrompt: systemPrompt,
      );

      // Parser la réponse JSON
      try {
        final cleanedResponse = response.trim();
        final jsonResponse = jsonDecode(cleanedResponse);
        return jsonResponse;
      } catch (e) {
        print('⚠️  Failed to parse JSON response: $response');
        // Retourner une recherche par mots-clés par défaut
        return {'keywords': query};
      }
    } catch (e) {
      print('❌ Error in analyzeSearchQuery: $e');
      return {'keywords': query};
    }
  }
}

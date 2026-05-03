import '../models/post.dart';
import 'azure_openai_service.dart';
import 'post_service.dart';

class JobSearchAIService {
  /// Rechercher des offres en utilisant l'IA pour comprendre la requête
  static Future<Map<String, dynamic>> searchJobsWithAI(String userQuery) async {
    try {
      print('🔍 Searching jobs with AI for query: $userQuery');

      // Analyse simple et rapide (sans appel IA pour plus de rapidité)
      final searchParams = _quickAnalyzeQuery(userQuery);
      print('📊 Extracted search params: $searchParams');

      // Récupérer les offres (limité pour la performance)
      final postsResponse = await PostService.getPosts(
        page: 1,
        perPage: 30, // Réduit de 100 à 30 pour plus de rapidité
      );

      List<Post> filteredPosts = postsResponse.result.data;

      // Filtrer par période si spécifiée
      if (searchParams['timeframe'] != null) {
        filteredPosts = _filterByTimeframe(
          filteredPosts,
          searchParams['timeframe'],
        );
      }

      // Filtrer par mots-clés si spécifiés
      if (searchParams['keywords'] != null) {
        filteredPosts = _filterByKeywords(
          filteredPosts,
          searchParams['keywords'],
        );
      }

      // Filtrer par localisation si spécifiée
      if (searchParams['location'] != null) {
        filteredPosts = _filterByLocation(
          filteredPosts,
          searchParams['location'],
        );
      }

      return {
        'success': true,
        'posts': filteredPosts,
        'count': filteredPosts.length,
        'searchParams': searchParams,
      };
    } catch (e) {
      print('❌ Error in searchJobsWithAI: $e');
      return {
        'success': false,
        'posts': [],
        'count': 0,
        'error': e.toString(),
      };
    }
  }

  /// Analyse rapide de la requête sans appel IA
  static Map<String, dynamic> _quickAnalyzeQuery(String query) {
    final queryLower = query.toLowerCase();
    final result = <String, dynamic>{};

    // Détecter la période
    if (queryLower.contains('aujourd\'hui') || queryLower.contains('today')) {
      result['timeframe'] = 'today';
    } else if (queryLower.contains('semaine') || queryLower.contains('week')) {
      result['timeframe'] = 'week';
    } else if (queryLower.contains('mois') || queryLower.contains('month') || queryLower.contains('dernier')) {
      result['timeframe'] = 'month';
    } else if (queryLower.contains('année') || queryLower.contains('annee') || queryLower.contains('year')) {
      result['timeframe'] = 'year';
    }

    // Détecter la localisation
    final cities = ['dakar', 'thiès', 'saint-louis', 'kaolack', 'ziguinchor', 'louga', 'matam', 'tambacounda'];
    for (final city in cities) {
      if (queryLower.contains(city)) {
        result['location'] = city;
        break;
      }
    }

    // Extraire les mots-clés pertinents (métiers, compétences, secteurs)
    final relevantKeywords = _extractRelevantKeywords(queryLower);
    if (relevantKeywords.isNotEmpty) {
      result['keywords'] = relevantKeywords.join(' ');
    }

    return result;
  }

  /// Extraire les mots-clés pertinents en ignorant les mots vides
  static List<String> _extractRelevantKeywords(String query) {
    // Mots vides à ignorer
    final stopWords = [
      'je', 'tu', 'il', 'elle', 'nous', 'vous', 'ils', 'elles',
      'le', 'la', 'les', 'un', 'une', 'des', 'du', 'de', 'à', 'au',
      'est', 'sont', 'ai', 'as', 'a', 'avons', 'avez', 'ont',
      'ce', 'cet', 'cette', 'ces', 'que', 'qui', 'quoi', 'dont',
      'me', 'te', 'se', 'mon', 'ton', 'son', 'ma', 'ta', 'sa',
      'mes', 'tes', 'ses', 'notre', 'votre', 'leur', 'nos', 'vos', 'leurs',
      'sur', 'dans', 'pour', 'avec', 'sans', 'par', 'en', 'y',
      'cherche', 'recherche', 'trouve', 'trouver', 'veux', 'veut', 'voudrais',
      'offre', 'offres', 'appel d\'offre', 'appels d\'offre', 'job', 'jobs', 'poste', 'postes',
      'travail', 'correspond', 'correspondant', 'correspondante',
    ];

    // Mots-clés de métiers et secteurs courants
    final jobKeywords = [
      'développeur', 'developpeur', 'programmeur', 'ingénieur', 'ingenieur',
      'commercial', 'comptable', 'manager', 'directeur', 'chef',
      'assistant', 'assistante', 'secrétaire', 'secretaire',
      'technicien', 'technicienne', 'ouvrier', 'ouvriere',
      'consultant', 'consultante', 'analyste', 'expert', 'experte',
      'designer', 'graphiste', 'architecte', 'médecin', 'medecin',
      'infirmier', 'infirmiere', 'professeur', 'enseignant', 'enseignante',
      'vendeur', 'vendeuse', 'caissier', 'caissiere', 'serveur', 'serveuse',
      'chauffeur', 'conducteur', 'conductrice', 'livreur', 'livreuse',
      'marketing', 'communication', 'finance', 'ressources', 'humaines',
      'informatique', 'web', 'mobile', 'data', 'réseau', 'reseau',
      'vente', 'achat', 'logistique', 'production', 'qualité', 'qualite',
    ];

    final words = query.split(RegExp(r'\s+'));
    final relevantWords = <String>[];

    for (final word in words) {
      final cleanWord = word.trim().toLowerCase();
      
      // Ignorer les mots vides et les mots trop courts
      if (cleanWord.length < 3 || stopWords.contains(cleanWord)) {
        continue;
      }

      // Garder les mots-clés de métiers
      if (jobKeywords.any((keyword) => cleanWord.contains(keyword) || keyword.contains(cleanWord))) {
        relevantWords.add(cleanWord);
        continue;
      }

      // Garder les mots qui semblent être des métiers ou compétences (plus de 4 lettres)
      if (cleanWord.length >= 4) {
        relevantWords.add(cleanWord);
      }
    }

    return relevantWords;
  }

  /// Filtrer les offres par période
  static List<Post> _filterByTimeframe(List<Post> posts, String timeframe) {
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (timeframe.toLowerCase()) {
      case 'today':
      case 'aujourd\'hui':
        cutoffDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
      case 'semaine':
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
      case 'mois':
        cutoffDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'year':
      case 'année':
      case 'annee':
        cutoffDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        return posts;
    }

    return posts.where((post) {
      try {
        final createdAt = DateTime.parse(post.createdAt);
        return createdAt.isAfter(cutoffDate);
      } catch (e) {
        return true; // Garder le post en cas d'erreur de parsing
      }
    }).toList();
  }

  /// Filtrer les offres par mots-clés
  static List<Post> _filterByKeywords(List<Post> posts, String keywords) {
    // Si pas de mots-clés spécifiques, retourner toutes les offres
    if (keywords.trim().isEmpty) {
      return posts;
    }

    final keywordsLower = keywords.toLowerCase();
    final keywordsList = keywordsLower.split(' ').where((k) => k.length >= 3).toList();

    // Si aucun mot-clé valide, retourner toutes les offres
    if (keywordsList.isEmpty) {
      return posts;
    }

    return posts.where((post) {
      final titleLower = post.title.toLowerCase();
      final descriptionLower = post.description.toLowerCase();
      final companyLower = post.companyName.toLowerCase();
      final companyDescLower = post.companyDescription.toLowerCase();

      // Vérifier si au moins un mot-clé est présent dans le titre, description ou entreprise
      return keywordsList.any((keyword) =>
          titleLower.contains(keyword) ||
          descriptionLower.contains(keyword) ||
          companyLower.contains(keyword) ||
          companyDescLower.contains(keyword));
    }).toList();
  }

  /// Filtrer les offres par localisation
  static List<Post> _filterByLocation(List<Post> posts, String location) {
    final locationLower = location.toLowerCase();

    return posts.where((post) {
      // On pourrait améliorer en utilisant les données de ville
      final descriptionLower = post.description.toLowerCase();
      return descriptionLower.contains(locationLower);
    }).toList();
  }

  /// Générer un résumé des résultats de recherche (version rapide)
  static Future<String> generateSearchSummary({
    required String userQuery,
    required List<Post> posts,
    required Map<String, dynamic> searchParams,
  }) async {
    // Version rapide sans appel IA
    final count = posts.length;
    
    if (count == 0) {
      return 'Désolé, je n\'ai trouvé aucune offre correspondant à votre recherche. 😕\n\nEssayez avec d\'autres mots-clés ou élargissez vos critères.';
    } else if (count == 1) {
      return 'J\'ai trouvé 1 offre correspondant à votre recherche ! 🎯\n\nConsultez-la ci-dessous.';
    } else if (count <= 5) {
      return 'Super ! J\'ai trouvé $count offres pour vous. 👍\n\nVoici les résultats :';
    } else {
      return 'Excellent ! J\'ai trouvé $count offres correspondant à votre recherche. 🎉\n\nVoici les 5 meilleures :';
    }
  }

  /// Répondre à une question générale sur les offres
  static Future<String> answerJobQuestion({
    required String question,
    List<Post>? contextPosts,
  }) async {
    try {
      // Construire le contexte détaillé des offres
      String offersContext = '';
      if (contextPosts != null && contextPosts.isNotEmpty) {
        final count = contextPosts.length;
        
        // Créer un résumé détaillé des offres
        final postsDetails = contextPosts.take(5).map((post) {
          final salary = post.salaryFormatted.isNotEmpty 
              ? post.salaryFormatted 
              : 'Non specifie';
          final location = 'Senegal'; // cityId: ${post.cityId}
          final company = post.companyName;
          final date = post.createdAtFormatted;
          
          return '''
Offre: ${post.title}
Entreprise: $company
Localisation: $location
Salaire: $salary
Date: $date
Vues: ${post.visits} vues''';
        }).join('\n\n');

        offersContext = '''

=== BASE DE DONNEES DES OFFRES ===
Nombre total d'offres disponibles: $count offres au Senegal

Details des offres principales:
$postsDetails

=== FIN DE LA BASE DE DONNEES ===''';
      }

      final systemPrompt = '''Vous etes un assistant virtuel expert en recherche d'appel d'offre au Senegal connecte a une base de donnees d'offres reelles.

Votre mission:
- Analyser les offres de la base de donnees pour repondre aux questions
- Donner des informations precises basees sur les vraies donnees (entreprises, localisations, salaires, dates)
- Fournir des statistiques et des insights pertinents
- Repondre de maniere naturelle, amicale et encourageante
- Utiliser des emojis pour rendre la conversation plus chaleureuse

Capacites d'analyse:
- Compter et analyser les offres par categorie, localisation, entreprise
- Identifier les tendances (offres les plus vues, entreprises qui recrutent le plus)
- Comparer les salaires et conditions
- Donner des conseils bases sur les donnees reelles

Style de communication:
- Ton amical et professionnel
- Reponses concises mais informatives (2-5 phrases)
- Encourageant et positif
- Utilisez des emojis simples
- Citez des exemples concrets de la base de donnees

Exemples de reponses avec donnees:
"Super ! J'ai analyse la base de donnees et je vois que DER recrute actuellement..."
"Excellente question ! Parmi les 15 offres, 5 sont a Dakar avec des salaires interessants..."
"Bonne nouvelle ! L'offre la plus populaire (325 vues) est pour un poste de..."''';

      final userMessage = '''Question de l'utilisateur: "$question"$offersContext

INSTRUCTIONS:
1. Analysez les donnees de la base de donnees ci-dessus
2. Repondez avec des informations precises et concretes
3. Citez des exemples reels (noms d'entreprises, localisations, statistiques)
4. Soyez naturel, amical et encourageant
5. Maximum 5 phrases

Repondez maintenant:''';

      final response = await AzureOpenAIService.sendMessage(
        userMessage: userMessage,
        systemPrompt: systemPrompt,
      );

      return response;
    } catch (e) {
      print('❌ Error answering question: $e');
      return 'Désolé, je n\'ai pas pu traiter votre question. 😕\n\nPouvez-vous la reformuler ?';
    }
  }
}

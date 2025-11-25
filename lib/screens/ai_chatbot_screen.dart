import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/job_search_ai_service.dart';
import 'post_detail_screen.dart';

class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  List<Post>? _lastSearchResults;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: 'Bonjour! 👋\n\nJe suis votre assistant virtuel pour la recherche d\'emploi. Je peux vous aider à:\n\n• Trouver des offres d\'emploi\n• Rechercher par période (mois dernier, année passée, etc.)\n• Filtrer par localisation ou catégorie\n• Répondre à vos questions sur les offres\n\nComment puis-je vous aider aujourd\'hui?',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Déterminer si c'est une recherche ou une question
      final isSearchQuery = _isSearchQuery(message);

      if (isSearchQuery) {
        // Rechercher des offres avec l'IA
        final result = await JobSearchAIService.searchJobsWithAI(message);

        if (result['success'] == true) {
          final posts = result['posts'] as List<Post>;
          _lastSearchResults = posts;

          // Générer un résumé simple et rapide (sans IA pour plus de rapidité)
          final count = posts.length;
          String summary;
          
          if (count == 0) {
            summary = 'Désolé, je n\'ai trouvé aucune offre correspondant à votre recherche. Essayez avec d\'autres mots-clés.';
          } else if (count == 1) {
            summary = 'J\'ai trouvé 1 offre correspondant à votre recherche ! 🎯';
          } else if (count <= 5) {
            summary = 'Super ! J\'ai trouvé $count offres pour vous. Voici les résultats :';
          } else {
            summary = 'Excellent ! J\'ai trouvé $count offres correspondant à votre recherche. Voici les 5 meilleures :';
          }

          setState(() {
            _messages.add(ChatMessage(
              text: summary,
              isUser: false,
              timestamp: DateTime.now(),
              searchResults: posts.take(5).toList(),
            ));
            _isLoading = false;
          });
        } else {
          setState(() {
            _messages.add(ChatMessage(
              text: 'Désolé, je n\'ai pas pu effectuer la recherche. Veuillez réessayer.',
              isUser: false,
              timestamp: DateTime.now(),
            ));
            _isLoading = false;
          });
        }
      } else {
        // Répondre à une question générale avec IA
        try {
          final response = await JobSearchAIService.answerJobQuestion(
            question: message,
            contextPosts: _lastSearchResults,
          );

          setState(() {
            _messages.add(ChatMessage(
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
            ));
            _isLoading = false;
          });
        } catch (e) {
          print('Erreur IA, utilisation du mode fallback: $e');
          // Mode de secours si l'IA ne fonctionne pas
          String fallbackResponse = _getFallbackResponse(message);
          
          setState(() {
            _messages.add(ChatMessage(
              text: fallbackResponse,
              isUser: false,
              timestamp: DateTime.now(),
            ));
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error sending message: $e');
      setState(() {
        _messages.add(ChatMessage(
          text: 'Désolé, une erreur s\'est produite. Veuillez réessayer.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  bool _isSearchQuery(String message) {
    final searchKeywords = [
      'cherche', 'recherche', 'trouve', 'offre', 'emploi', 'job',
      'poste', 'travail', 'opportunité', 'mois', 'année', 'semaine',
      'développeur', 'ingénieur', 'commercial', 'comptable', 'manager',
    ];

    final messageLower = message.toLowerCase();
    return searchKeywords.any((keyword) => messageLower.contains(keyword));
  }

  String _getFallbackResponse(String message) {
    final messageLower = message.toLowerCase();
    
    // Réponses prédéfinies pour les questions courantes
    if (messageLower.contains('bonjour') || messageLower.contains('salut') || messageLower.contains('hello') || messageLower.contains('hi')) {
      return 'Bonjour ! 👋\n\nJe suis votre assistant virtuel pour la recherche d\'emploi. Je peux vous aider à trouver des offres qui correspondent à vos critères.\n\nQue recherchez-vous aujourd\'hui ?';
    }
    
    if (messageLower.contains('aide') || messageLower.contains('help') || messageLower.contains('aider')) {
      return 'Bien sûr ! 😊\n\nJe peux vous aider à :\n\n• 🔍 Trouver des offres d\'emploi\n• 📅 Rechercher par période (mois dernier, année passée...)\n• 📍 Filtrer par localisation (Dakar, Thiès...)\n• 💼 Chercher par métier ou compétence\n\nTapez simplement ce que vous cherchez, par exemple :\n"Je cherche un emploi de développeur"';
    }
    
    if ((messageLower.contains('comment') && messageLower.contains('postuler')) || messageLower.contains('candidature')) {
      return 'Pour postuler à une offre : 👍\n\n1️⃣ Cherchez des offres qui vous intéressent\n2️⃣ Cliquez sur une offre pour voir les détails\n3️⃣ Suivez les instructions de candidature\n4️⃣ Préparez votre CV et lettre de motivation\n\nBonne chance ! 🎯';
    }
    
    if (messageLower.contains('conseil') || messageLower.contains('astuce') || messageLower.contains('tip')) {
      return 'Voici mes meilleurs conseils : 💡\n\n✅ Personnalisez votre CV pour chaque offre\n✅ Postulez rapidement aux offres récentes\n✅ Soignez votre lettre de motivation\n✅ Préparez-vous bien pour les entretiens\n✅ Suivez vos candidatures\n\nVoulez-vous chercher des offres maintenant ?';
    }
    
    if (messageLower.contains('merci') || messageLower.contains('thank')) {
      return 'De rien ! 😊\n\nJe suis ravi de vous aider. N\'hésitez pas si vous avez d\'autres questions ou si vous voulez chercher des offres !\n\nBonne chance dans votre recherche ! 🍀';
    }
    
    if (messageLower.contains('combien') || messageLower.contains('nombre')) {
      return 'Pour connaître le nombre d\'offres disponibles, tapez simplement :\n\n"Je cherche un emploi"\n\nJe vous montrerai toutes les offres récentes ! 📊';
    }
    
    if (messageLower.contains('qui es-tu') || messageLower.contains('qui êtes-vous') || messageLower.contains('c\'est quoi')) {
      return 'Je suis l\'assistant virtuel de SenOffre ! 🤖\n\nMa mission est de vous aider à trouver l\'emploi qui vous correspond au Sénégal.\n\nJe peux chercher des offres par mots-clés, période, ou localisation. Comment puis-je vous aider ? 😊';
    }
    
    // Réponse par défaut
    return 'Je comprends que vous avez une question, mais je ne suis pas sûr de pouvoir y répondre directement. 😕\n\nVoici ce que je peux faire pour vous :\n\n🔍 Chercher des offres d\'emploi\nExemple : "Je cherche un emploi de développeur"\n\n📅 Filtrer par période\nExemple : "Offres du mois dernier"\n\n📍 Filtrer par ville\nExemple : "Emploi à Dakar"\n\nEssayez l\'une de ces recherches ! 👍';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant IA'),
        backgroundColor: const Color(0xFF4CAF50), // Couleur SenOffre
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)), // Vert SenOffre
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'L\'assistant réfléchit...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50), // Couleur SenOffre
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              if (!message.isUser) const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isUser 
                        ? const Color(0xFF4CAF50) // Vert SenOffre pour utilisateur
                        : Colors.grey[100], // Gris clair pour bot
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              if (message.isUser) const SizedBox(width: 8),
              if (message.isUser)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
          if (message.searchResults != null && message.searchResults!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 44),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  ...message.searchResults!.map((post) => _buildJobCard(post)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Post post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(post: post),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                post.companyName,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    post.createdAtFormatted,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Posez votre question...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50), // Vert SenOffre
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                icon: const Icon(Icons.send),
                color: Colors.white,
                onPressed: _isLoading ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Post>? searchResults;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.searchResults,
  });
}

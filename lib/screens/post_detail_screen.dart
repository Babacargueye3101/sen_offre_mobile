import 'package:flutter/material.dart';
import '../models/post.dart';
import '../utils/url_helper.dart';
import '../services/saved_posts_service.dart';
import '../services/user_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _isFavorite = false;
  bool _isLoadingFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    if (!UserService.isLoggedIn) return;
    
    try {
      final response = await SavedPostsService.getSavedPosts();
      if (response != null && response.success) {
        setState(() {
          _isFavorite = response.result.data.any((savedPost) => savedPost.post.id == widget.post.id);
        });
      }
    } catch (e) {
      print('Erreur lors de la vérification du favori: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (!UserService.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour ajouter aux favoris'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingFavorite = true;
    });

    try {
      if (_isFavorite) {
        final success = await SavedPostsService.removeFromFavorites(widget.post.id);
        if (success) {
          setState(() {
            _isFavorite = false;
            _isLoadingFavorite = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Retiré des favoris'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        final success = await SavedPostsService.addToFavorites(widget.post.id);
        if (success) {
          setState(() {
            _isFavorite = true;
            _isLoadingFavorite = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ajouté aux favoris'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingFavorite = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur est survenue'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _applyToOffer() async {
    final url = widget.post.applicationUrl;
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun lien de candidature disponible'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir le lien'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'ouverture du lien'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Détail de l\'offre',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          _isLoadingFavorite
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.white,
                  ),
                  onPressed: _toggleFavorite,
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec logo et infos entreprise
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Logo de l'entreprise
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildCompanyLogo(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Nom de l'entreprise
                  Text(
                    widget.post.companyName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Localisation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.post.countryCode,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Contenu principal
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre de l'offre
                  Text(
                    widget.post.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Informations rapides
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.calendar_today,
                        widget.post.createdAtFormatted,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.visibility,
                        widget.post.visitsFormatted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Description de l'entreprise
                  if (widget.post.companyDescription.isNotEmpty) ...[
                    const Text(
                      'À propos de l\'entreprise',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.post.companyDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Description de l'offre
                  const Text(
                    'Description de l\'offre',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.post.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Informations de contact
                  if (widget.post.email.isNotEmpty || widget.post.phone.isNotEmpty) ...[
                    const Text(
                      'Contact',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.post.contactName.isNotEmpty)
                      _buildContactRow(Icons.person, widget.post.contactName),
                    if (widget.post.email.isNotEmpty)
                      _buildContactRow(Icons.email, widget.post.email),
                    if (widget.post.phone.isNotEmpty)
                      _buildContactRow(Icons.phone, widget.post.phone),
                    const SizedBox(height: 24),
                  ],
                  
                  // Boutons d'action
                  Row(
                    children: [
                      // Bouton Partager
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implémenter le partage
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fonctionnalité de partage à venir'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          },
                          icon: const Icon(Icons.share, size: 20),
                          label: const Text('Partager'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4CAF50),
                            side: const BorderSide(color: Color(0xFF4CAF50)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Bouton Postuler
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _applyToOffer,
                          icon: const Icon(Icons.send, size: 20),
                          label: const Text('Postuler'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyLogo() {
    String logoUrl = '';
    
    // Priorité: small -> medium -> full
    if (widget.post.logoUrl.small.isNotEmpty && widget.post.logoUrl.small != 'app/default/picture.jpg') {
      logoUrl = UrlHelper.fixImageUrl(widget.post.logoUrl.small);
    } else if (widget.post.logoUrl.medium.isNotEmpty && widget.post.logoUrl.medium != 'app/default/picture.jpg') {
      logoUrl = UrlHelper.fixImageUrl(widget.post.logoUrl.medium);
    } else if (widget.post.logoUrl.full.isNotEmpty && widget.post.logoUrl.full != 'app/default/picture.jpg') {
      logoUrl = UrlHelper.fixImageUrl(widget.post.logoUrl.full);
    }
    
    // Si pas de logo_url, essayer le champ logo direct
    if (logoUrl.isEmpty && widget.post.logo.isNotEmpty) {
      logoUrl = UrlHelper.fixImageUrl('http://localhost:8000/storage/${widget.post.logo}');
    }

    if (logoUrl.isNotEmpty) {
      return Image.network(
        logoUrl,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackLogo();
        },
      );
    } else {
      return _buildFallbackLogo();
    }
  }

  Widget _buildFallbackLogo() {
    String initials = '';
    List<String> words = widget.post.companyName.split(' ');
    if (words.isNotEmpty) {
      initials = words.take(2).map((word) => word.isNotEmpty ? word[0].toUpperCase() : '').join('');
    }
    if (initials.isEmpty) {
      initials = widget.post.companyName.isNotEmpty ? widget.post.companyName[0].toUpperCase() : '?';
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.8),
            const Color(0xFF2E7D32).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4CAF50)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

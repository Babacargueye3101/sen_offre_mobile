import 'package:flutter/material.dart';
import '../models/saved_post.dart';
import '../models/post.dart';
import '../services/saved_posts_service.dart';
import '../services/user_service.dart';
import '../utils/url_helper.dart';
import 'home_screen.dart';
import 'post_detail_screen.dart';

class FavorisScreen extends StatefulWidget {
  const FavorisScreen({super.key});

  @override
  State<FavorisScreen> createState() => _FavorisScreenState();
}

class _FavorisScreenState extends State<FavorisScreen> {
  List<SavedPost> _savedPosts = [];
  bool _isLoading = false;
  Set<int> _favoritePostIds = {}; // Pour tracker les favoris

  @override
  void initState() {
    super.initState();
    _loadSavedPosts();
  }

  Future<void> _loadSavedPosts() async {
    if (!UserService.isLoggedIn) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await SavedPostsService.getSavedPosts();
      if (response != null && response.success) {
        setState(() {
          _savedPosts = response.result.data;
          // Marquer tous les posts comme favoris
          _favoritePostIds = _savedPosts.map((savedPost) => savedPost.post.id).toSet();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du chargement des favoris'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erreur lors du chargement des favoris: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur est survenue'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshFavorites() async {
    await _loadSavedPosts();
  }

  /// Supprimer une offre des favoris
  Future<void> _removeFromFavorites(Post post) async {
    try {
      final success = await SavedPostsService.removeFromFavorites(post.id);
      if (success) {
        setState(() {
          _savedPosts.removeWhere((savedPost) => savedPost.post.id == post.id);
          _favoritePostIds.remove(post.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offre supprimée des favoris'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suppression'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Erreur lors de la suppression des favoris: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur est survenue'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildCompanyLogo(Post post) {
    // Gestion des logos avec conversion HTTPS->HTTP pour localhost et 10.0.2.2 pour Android
    String logoUrl = '';
    
    // Priorité: small -> medium -> full
    if (post.logoUrl.small.isNotEmpty && post.logoUrl.small != 'app/default/picture.jpg') {
      logoUrl = UrlHelper.fixImageUrl(post.logoUrl.small);
    } else if (post.logoUrl.medium.isNotEmpty && post.logoUrl.medium != 'app/default/picture.jpg') {
      logoUrl = UrlHelper.fixImageUrl(post.logoUrl.medium);
    } else if (post.logoUrl.full.isNotEmpty && post.logoUrl.full != 'app/default/picture.jpg') {
      logoUrl = UrlHelper.fixImageUrl(post.logoUrl.full);
    }
    
    // Si pas de logo_url, essayer le champ logo direct
    if (logoUrl.isEmpty && post.logo.isNotEmpty) {
      logoUrl = UrlHelper.fixImageUrl('http://localhost:8000/storage/${post.logo}');
    }

    if (logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          logoUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackLogo(post);
          },
        ),
      );
    } else {
      return _buildFallbackLogo(post);
    }
  }

  Widget _buildFallbackLogo(Post post) {
    String initials = '';
    List<String> words = post.companyName.split(' ');
    if (words.isNotEmpty) {
      initials = words.take(2).map((word) => word.isNotEmpty ? word[0].toUpperCase() : '').join('');
    }
    if (initials.isEmpty) {
      initials = post.companyName.isNotEmpty ? post.companyName[0].toUpperCase() : '?';
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.8),
            const Color(0xFF2E7D32).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCard(SavedPost savedPost) {
    final Post post = savedPost.post;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompanyLogo(post),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.excerpt,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _removeFromFavorites(post),
                icon: const Icon(
                  Icons.bookmark,
                  color: Color(0xFF4CAF50),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Bouton Partager
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF4CAF50)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.share, size: 14, color: const Color(0xFF4CAF50)),
                    const SizedBox(width: 4),
                    const Text(
                      'Partager',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Tag nom de l'entreprise
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    post.companyName.length > 20
                        ? '${post.companyName.substring(0, 20)}...'
                        : post.companyName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Bouton Appel d'offre
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Appel d'offre",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                post.createdAtFormatted,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                post.visitsFormatted,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                post.countryCode,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.bookmark_border,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Favoris',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos offres favorites',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune offre favorite pour le moment.\nAjoutez des offres à vos favoris pour les retrouver ici.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!UserService.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Favoris'),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.login,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Connexion requise',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vous devez être connecté pour voir vos favoris',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoris'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
              ),
            )
          : _savedPosts.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _refreshFavorites,
                  color: const Color(0xFF4CAF50),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _savedPosts.length,
                    itemBuilder: (context, index) {
                      return _buildOfferCard(_savedPosts[index]);
                    },
                  ),
                ),
    );
  }
}

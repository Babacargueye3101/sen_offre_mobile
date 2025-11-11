import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/category.dart';
import '../models/post_type.dart';
import '../models/city.dart';
import '../services/post_service.dart';
import '../services/category_service.dart';
import '../services/post_type_service.dart';
import '../services/city_service.dart';
import '../services/user_service.dart';
import '../services/saved_posts_service.dart';
import 'offers_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> _categories = [];
  List<PostType> _postTypes = [];
  List<City> _cities = [];
  bool _isLoadingCategories = false;
  bool _isLoadingPostTypes = false;
  bool _isLoadingCities = false;
  
  // Variables pour les dropdowns
  PostType? _selectedPostType;
  City? _selectedCity;
  Category? _selectedCategory;
  bool _showPostTypes = false;
  bool _showCities = false;
  bool _showCategories = false;
  
  // Variables pour les offres
  List<Post> _posts = [];
  bool _isLoadingPosts = false;
  int _currentPage = 1;
  final int _perPage = 10;
  bool _hasMorePosts = true;
  Set<int> _favoritePostIds = {}; // Pour tracker les favoris

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadPostTypes();
    _loadCities();
    _loadPosts();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoadingCategories = true;
      });

      final categories = await CategoryService.getAllCategories();
      final activeCategories = CategoryService.getActiveCategories(categories);

      setState(() {
        _categories = activeCategories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      print('Erreur lors du chargement des catégories: $e');
    }
  }

  Future<void> _loadPostTypes() async {
    try {
      setState(() {
        _isLoadingPostTypes = true;
      });

      final postTypes = await PostTypeService.getAllPostTypes();
      final activePostTypes = PostTypeService.getActivePostTypes(postTypes);

      setState(() {
        _postTypes = activePostTypes;
        _isLoadingPostTypes = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des types d\'offres: $e');
      setState(() {
        _isLoadingPostTypes = false;
      });
    }
  }

  Future<void> _loadCities() async {
    try {
      setState(() {
        _isLoadingCities = true;
      });

      final cities = await CityService.getAllCities();
      final activeCities = CityService.getActiveCities(cities);
      activeCities.sort((a, b) => a.name.compareTo(b.name));

      setState(() {
        _cities = activeCities;
        _isLoadingCities = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des villes: $e');
      setState(() {
        _isLoadingCities = false;
      });
    }
  }

  Future<void> _loadPosts() async {
    if (_isLoadingPosts) return;
    
    try {
      setState(() {
        _isLoadingPosts = true;
      });

      final response = await PostService.getPosts(
        page: _currentPage,
        perPage: _perPage,
      );

      setState(() {
        if (_currentPage == 1) {
          _posts = response.result.data;
        } else {
          _posts.addAll(response.result.data);
        }
        _hasMorePosts = response.result.links.next != null;
        _isLoadingPosts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPosts = false;
      });
      print('Erreur lors du chargement des offres: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des offres: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadMorePosts() async {
    if (_hasMorePosts && !_isLoadingPosts) {
      _currentPage++;
      await _loadPosts();
    }
  }

  Future<void> _refreshPosts() async {
    _currentPage = 1;
    await _loadPosts();
  }

  void _toggleCategories() {
    setState(() {
      _showCategories = !_showCategories;
    });
  }

  void _selectCategory(Category category) {
    setState(() {
      _showCategories = false;
    });
    print('Catégorie sélectionnée: ${category.name}');
  }

  void _selectPostType(PostType? postType) {
    setState(() {
      _selectedPostType = postType;
      _showPostTypes = false;
    });
  }

  void _selectCity(City? city) {
    setState(() {
      _selectedCity = city;
      _showCities = false;
    });
  }

  void _navigateToOffersList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OffersListScreen()),
    );
  }

  /// Ajouter ou supprimer une offre des favoris
  Future<void> _toggleFavorite(Post post) async {
    // Vérifier si l'utilisateur est connecté
    if (!UserService.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour ajouter aux favoris'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final bool isFavorite = _favoritePostIds.contains(post.id);
    
    try {
      bool success;
      if (isFavorite) {
        // Supprimer des favoris
        success = await SavedPostsService.removeFromFavorites(post.id);
        if (success) {
          setState(() {
            _favoritePostIds.remove(post.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Offre supprimée des favoris'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Ajouter aux favoris
        success = await SavedPostsService.addToFavorites(post.id);
        if (success) {
          setState(() {
            _favoritePostIds.add(post.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ajouté aux favoris avec succès'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
      
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFavorite 
              ? 'Erreur lors de la suppression des favoris' 
              : 'Erreur lors de l\'ajout aux favoris'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Erreur lors de la gestion des favoris: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur est survenue'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildPostTypeDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 250),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Option "Tous les types"
              InkWell(
                onTap: () => _selectPostType(null),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shopping_bag_outlined, 
                        color: const Color(0xFF4CAF50), size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Tous les types d\'offres',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_selectedPostType == null)
                        const Icon(Icons.check, 
                          color: Color(0xFF4CAF50), size: 20),
                    ],
                  ),
                ),
              ),
              // Liste des types d'offres
              if (_postTypes.isNotEmpty)
                ...(_postTypes.map((postType) => InkWell(
                  onTap: () => _selectPostType(postType),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.work_outline, 
                          color: const Color(0xFF4CAF50), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            postType.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (_selectedPostType?.id == postType.id)
                          const Icon(Icons.check, 
                            color: Color(0xFF4CAF50), size: 20),
                      ],
                    ),
                  ),
                )).toList())
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'Chargement des types d\'offres...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 350),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Option "Toutes les villes"
              InkWell(
                onTap: () => _selectCity(null),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, 
                        color: const Color(0xFF4CAF50), size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Toutes les villes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_selectedCity == null)
                        const Icon(Icons.check, 
                          color: Color(0xFF4CAF50), size: 20),
                    ],
                  ),
                ),
              ),
              // Liste des villes
              if (_cities.isNotEmpty)
                ...(_cities.map((city) => InkWell(
                  onTap: () => _selectCity(city),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_city, 
                          color: const Color(0xFF4CAF50), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            city.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (_selectedCity?.id == city.id)
                          const Icon(Icons.check, 
                            color: Color(0xFF4CAF50), size: 20),
                      ],
                    ),
                  ),
                )).toList())
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'Chargement des villes...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyLogo(Post post) {
    // Gestion des logos avec conversion HTTPS->HTTP pour localhost (comme dans React)
    String logoUrl = '';
    
    // Priorité: small -> medium -> full (comme dans React)
    if (post.logoUrl.small.isNotEmpty && post.logoUrl.small != 'app/default/picture.jpg') {
      logoUrl = post.logoUrl.small;
    } else if (post.logoUrl.medium.isNotEmpty && post.logoUrl.medium != 'app/default/picture.jpg') {
      logoUrl = post.logoUrl.medium;
    } else if (post.logoUrl.full.isNotEmpty && post.logoUrl.full != 'app/default/picture.jpg') {
      logoUrl = post.logoUrl.full;
    }
    
    // Conversion HTTPS->HTTP pour localhost (comme dans React)
    if (logoUrl.isNotEmpty && logoUrl.contains('https://localhost:8000')) {
      logoUrl = logoUrl.replaceAll('https://localhost:8000', 'http://localhost:8000');
    }
    
    // Si pas de logo_url, essayer le champ logo direct (comme dans React)
    if (logoUrl.isEmpty && post.logo.isNotEmpty) {
      logoUrl = 'http://localhost:8000/storage/${post.logo}';
    }

    if (logoUrl.isNotEmpty) {
      print('Chargement du logo: $logoUrl'); // Debug
      return Image.network(
        logoUrl,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: const Color(0xFF4CAF50),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Erreur de chargement du logo ($logoUrl): $error');
          return _buildFallbackLogo(post);
        },
      );
    } else {
      print('Aucun logo trouvé pour: ${post.companyName}'); // Debug
      return _buildFallbackLogo(post);
    }
  }

  Widget _buildFallbackLogo(Post post) {
    // Créer un logo de fallback avec les initiales de l'entreprise
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
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: _buildCompanyLogo(post),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 15,
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
                  onPressed: () => _toggleFavorite(post),
                  icon: Icon(
                    _favoritePostIds.contains(post.id) 
                      ? Icons.bookmark 
                      : Icons.bookmark_border,
                    color: _favoritePostIds.contains(post.id) 
                      ? const Color(0xFF4CAF50) 
                      : Colors.grey,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  post.createdAtFormatted,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF4CAF50)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          UserService.getWelcomeMessage(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          'Trouvez les meilleures opportunités',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: RefreshIndicator(
                  onRefresh: _refreshPosts,
                  color: const Color(0xFF4CAF50),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // Type d'offre et Localisation
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showPostTypes = !_showPostTypes;
                                    });
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.shopping_bag_outlined, 
                                            color: const Color(0xFF4CAF50), size: 20),
                                          const SizedBox(width: 8),
                                          const Text(
                                            "Type d'offre",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const Spacer(),
                                          Icon(
                                            _showPostTypes 
                                              ? Icons.keyboard_arrow_up 
                                              : Icons.keyboard_arrow_down, 
                                            color: Colors.grey, size: 20
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedPostType?.name ?? "Type d'offre",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey.withOpacity(0.3),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showCities = !_showCities;
                                    });
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.location_on_outlined, 
                                            color: const Color(0xFF4CAF50), size: 20),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Localisation',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const Spacer(),
                                          Icon(
                                            _showCities 
                                              ? Icons.keyboard_arrow_up 
                                              : Icons.keyboard_arrow_down, 
                                            color: Colors.grey, size: 20
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedCity?.name ?? 'Où',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Dropdowns
                        if (_showPostTypes) _buildPostTypeDropdown(),
                        if (_showCities) _buildCityDropdown(),
                        const SizedBox(height: 16),
                        // Catégories
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            child: InkWell(
                              onTap: _toggleCategories,
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(Icons.category_outlined, 
                                      color: const Color(0xFF4CAF50), size: 20),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Catégories',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF4CAF50),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _showCategories 
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                      color: const Color(0xFF4CAF50),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Liste déroulante des catégories
                        if (_showCategories)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: _isLoadingCategories
                                  ? const Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                                        ),
                                      ),
                                    )
                                  : _categories.isEmpty
                                      ? const Padding(
                                          padding: EdgeInsets.all(20.0),
                                          child: Center(
                                            child: Text(
                                              'Aucune catégorie disponible',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF4CAF50),
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(12),
                                                ),
                                              ),
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.category, color: Colors.white, size: 16),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Sélectionnez une catégorie',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              constraints: const BoxConstraints(maxHeight: 200),
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: _categories.length,
                                                itemBuilder: (context, index) {
                                                  final category = _categories[index];
                                                  return InkWell(
                                                    onTap: () => _selectCategory(category),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 12,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        border: index < _categories.length - 1
                                                            ? const Border(
                                                                bottom: BorderSide(
                                                                  color: Color(0xFFE0E0E0),
                                                                  width: 0.5,
                                                                ),
                                                              )
                                                            : null,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 32,
                                                            height: 32,
                                                            decoration: BoxDecoration(
                                                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                                                              borderRadius: BorderRadius.circular(16),
                                                            ),
                                                            child: const Icon(
                                                              Icons.folder,
                                                              color: Color(0xFF4CAF50),
                                                              size: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 12),
                                                          Expanded(
                                                            child: Text(
                                                              category.name,
                                                              style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w500,
                                                                color: Colors.black87,
                                                              ),
                                                            ),
                                                          ),
                                                          const Icon(
                                                            Icons.arrow_forward_ios,
                                                            color: Colors.grey,
                                                            size: 12,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                            ),
                          ),
                        
                        const SizedBox(height: 16),
                        // Sponsorisé banner
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.star,
                                    color: Color(0xFF4CAF50),
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFF4CAF50),
                                          ),
                                        ),
                                        child: const Text(
                                          'Sponsorisé',
                                          style: TextStyle(
                                            color: Color(0xFF4CAF50),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "Abonnez-vous dès aujourd'hui !",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "Accédez en illimité aux appels d'offres pour seulement 3.000 FCFA/mois.",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Text(
                                            'Découvrir maintenant',
                                            style: TextStyle(
                                              color: Color(0xFF4CAF50),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.arrow_forward, 
                                            color: Color(0xFF4CAF50), size: 16),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Toutes les offres
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Toutes les offres',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: _navigateToOffersList,
                                child: const Text(
                                  'Tout voir',
                                  style: TextStyle(
                                    color: Color(0xFF4CAF50),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Liste des offres dynamique
                        if (_isLoadingPosts && _posts.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          )
                        else if (_posts.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'Aucune offre disponible',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        else
                          ..._posts.take(3).map((post) => _buildPostCard(post)).toList(),
                        
                        // Bouton "Voir plus" si il y a plus d'offres
                        if (_posts.length > 3 || _hasMorePosts)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Center(
                              child: TextButton(
                                onPressed: _navigateToOffersList,
                                child: Text(
                                  _isLoadingPosts ? 'Chargement...' : 'Voir plus d\'offres',
                                  style: const TextStyle(
                                    color: Color(0xFF4CAF50),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

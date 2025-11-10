import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class OffersListScreen extends StatefulWidget {
  const OffersListScreen({super.key});

  @override
  State<OffersListScreen> createState() => _OffersListScreenState();
}

class _OffersListScreenState extends State<OffersListScreen> {
  List<Post> _posts = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  bool _hasMorePosts = true;
  int _currentPage = 1;
  final int _perPage = 50; // Charger plus d'offres dans la liste complète
  
  // Filtres
  String _searchQuery = '';
  String _selectedOfferType = "Appel d'offre";
  String _selectedLocation = 'Dakar';
  Category? _selectedCategory;
  bool _showCategories = false;
  
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMorePosts();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CategoryService.getAllCategories();
      final activeCategories = CategoryService.getActiveCategories(categories);
      setState(() {
        _categories = activeCategories;
      });
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
    }
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 1;
        _posts.clear();
      }
    });

    try {
      print('Chargement des offres - Page: $_currentPage, PerPage: $_perPage');
      final response = await PostService.getPosts(
        page: _currentPage,
        perPage: _perPage,
      );

      print('Réponse reçue: ${response.result.data.length} offres');
      setState(() {
        if (_currentPage == 1) {
          _posts = response.result.data;
        } else {
          _posts.addAll(response.result.data);
        }
        _hasMorePosts = response.result.links.next != null;
        _isLoading = false;
      });
      print('Total offres après chargement: ${_posts.length}');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erreur lors du chargement des offres: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadMorePosts() async {
    if (_hasMorePosts && !_isLoading) {
      _currentPage++;
      await _loadPosts();
    }
  }

  Future<void> _refreshPosts() async {
    await _loadPosts(refresh: true);
  }

  void _selectCategory(Category? category) {
    setState(() {
      _selectedCategory = category;
      _showCategories = false;
    });
    _performSearch(); // Relancer la recherche avec la nouvelle catégorie
  }

  Widget _buildCategoryDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
        child: Column(
          children: [
            // Option "Toutes les catégories"
            InkWell(
              onTap: () => _selectCategory(null),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.category, 
                      color: const Color(0xFF4CAF50), size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Toutes les catégories',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (_selectedCategory == null)
                      const Icon(Icons.check, 
                        color: Color(0xFF4CAF50), size: 20),
                  ],
                ),
              ),
            ),
            // Liste des catégories
            if (_categories.isNotEmpty)
              ...(_categories.take(5).map((category) => InkWell(
                onTap: () => _selectCategory(category),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.folder_outlined, 
                        color: const Color(0xFF4CAF50), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_selectedCategory?.id == category.id)
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
                  'Chargement des catégories...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _performSearch() {
    // Implémenter la recherche
    print('Recherche: $_searchQuery');
    _refreshPosts();
  }

  Widget _buildCompanyLogo(Post post) {
    // Gestion des logos avec conversion HTTPS->HTTP pour localhost
    String logoUrl = '';
    
    // Priorité: small -> medium -> full
    if (post.logoUrl.small.isNotEmpty && post.logoUrl.small != 'app/default/picture.jpg') {
      logoUrl = post.logoUrl.small;
    } else if (post.logoUrl.medium.isNotEmpty && post.logoUrl.medium != 'app/default/picture.jpg') {
      logoUrl = post.logoUrl.medium;
    } else if (post.logoUrl.full.isNotEmpty && post.logoUrl.full != 'app/default/picture.jpg') {
      logoUrl = post.logoUrl.full;
    }
    
    // Conversion HTTPS->HTTP pour localhost
    if (logoUrl.isNotEmpty && logoUrl.contains('https://localhost:8000')) {
      logoUrl = logoUrl.replaceAll('https://localhost:8000', 'http://localhost:8000');
    }
    
    // Si pas de logo_url, essayer le champ logo direct
    if (logoUrl.isEmpty && post.logo.isNotEmpty) {
      logoUrl = 'http://localhost:8000/storage/${post.logo}';
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

  Widget _buildOfferCard(Post post) {
    return Container(
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // Ajouter aux favoris
                },
                icon: const Icon(Icons.bookmark_border, color: Colors.grey),
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
              // Tag type d'offre
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
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
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
                          'M. Le Maire',
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
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.person_outline, color: Colors.white),
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
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Filtres
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          // Type d'offre et Localisation
                          Container(
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
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.shopping_bag_outlined, 
                                            color: const Color(0xFF4CAF50), size: 16),
                                          const SizedBox(width: 8),
                                          const Text(
                                            "Type d'offre",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const Spacer(),
                                          const Icon(Icons.keyboard_arrow_down, 
                                            color: Colors.grey, size: 16),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedOfferType,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.location_on_outlined, 
                                            color: const Color(0xFF4CAF50), size: 16),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Où',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const Spacer(),
                                          const Icon(Icons.keyboard_arrow_down, 
                                            color: Colors.grey, size: 16),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedLocation,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Barre de recherche et catégories
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Que cherchez vous ?',
                                      border: InputBorder.none,
                                      icon: Icon(Icons.search, color: Colors.grey),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                      });
                                    },
                                    onSubmitted: (value) => _performSearch(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showCategories = !_showCategories;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _selectedCategory?.name ?? 'Catégories',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        _showCategories 
                                          ? Icons.keyboard_arrow_up 
                                          : Icons.keyboard_arrow_down, 
                                        size: 16
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Bouton Trouver
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _performSearch,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.search, color: Colors.white),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Trouver',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Liste déroulante des catégories
                          if (_showCategories) _buildCategoryDropdown(),
                          const SizedBox(height: 16),
                          // Nombre d'offres trouvées
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${_posts.length} offres trouvées',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Liste des offres
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refreshPosts,
                        color: const Color(0xFF4CAF50),
                        child: _isLoading && _posts.isEmpty
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF4CAF50),
                                ),
                              )
                            : _posts.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Aucune offre disponible',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: _posts.length + (_isLoading ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == _posts.length) {
                                        return const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF4CAF50),
                                            ),
                                          ),
                                        );
                                      }
                                      return _buildOfferCard(_posts[index]);
                                    },
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

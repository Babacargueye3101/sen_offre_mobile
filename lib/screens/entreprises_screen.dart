import 'dart:async';
import 'package:flutter/material.dart';

import '../services/company_service.dart';
import '../models/company.dart';

class EntreprisesScreen extends StatefulWidget {
  const EntreprisesScreen({super.key});

  @override
  State<EntreprisesScreen> createState() => _EntreprisesScreenState();
}

class _EntreprisesScreenState extends State<EntreprisesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Company> _companies = [];
  bool _isLoading = false;
  String? _error;
  int _total = 0;
  Timer? _debounce;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;
  String? _currentQuery;

  @override
  void initState() {
    super.initState();
    _fetchCompanies(reset: true);
    _searchController.addListener(() {
      setState(() {}); // met à jour l'icône clear
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchCompanies({String? query, bool reset = false}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await CompanyService.getCompanies(
        page: 1,
        perPage: 20,
        query: query,
      );

      setState(() {
        _companies = response.result.data;
        _total = response.result.meta?.total ?? _companies.length;
        _currentPage = 1;
        _lastPage = response.result.meta?.lastPage ?? 1;
        _currentQuery = query;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _onSearchSubmit(String value) {
    final q = value.trim();
    _fetchCompanies(query: q.isEmpty ? null : q, reset: true);
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final q = value.trim();
      _fetchCompanies(query: q.isEmpty ? null : q, reset: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        !_isLoading &&
        _currentPage < _lastPage) {
      _loadMoreCompanies();
    }
  }

  Future<void> _loadMoreCompanies() async {
    if (_isLoadingMore || _currentPage >= _lastPage) return;
    try {
      setState(() {
        _isLoadingMore = true;
      });

      final nextPage = _currentPage + 1;
      final response = await CompanyService.getCompanies(
        page: nextPage,
        perPage: 20,
        query: _currentQuery,
      );

      setState(() {
        _companies.addAll(response.result.data);
        _currentPage = nextPage;
        _lastPage = response.result.meta?.lastPage ?? _lastPage;
        _total = response.result.meta?.total ?? _total;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
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
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF4CAF50)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour,',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'M. Le Maire',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications, color: Color(0xFF4CAF50)),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: "Nom de l'entreprise",
                          isCollapsed: true,
                          border: InputBorder.none,
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: _onSearchSubmit,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _onSearchSubmit('');
                        },
                        child: const Icon(Icons.close, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red),
                                  const SizedBox(height: 8),
                                  Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () => _fetchCompanies(query: _searchController.text.trim()),
                                    child: const Text('Réessayer'),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  '$_total entreprises trouvées',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _companies.length + 1 + (_isLoadingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index < _companies.length) {
                                      final c = _companies[index];
                                      return _buildEntrepriseCard(c);
                                    }
                                    if (_isLoadingMore && index == _companies.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16.0),
                                        child: Center(child: CircularProgressIndicator()),
                                      );
                                    }
                                    return const SizedBox(height: 80);
                                  },
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

  Widget _buildEntrepriseCard(Company company) {
    final initials = company.name.isNotEmpty
        ? company.name.trim().split(RegExp(r'\s+')).take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase()
        : '';
    final announcements = company.postsCount.toString().padLeft(2, '0');

    return Container(
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
                ),
                clipBehavior: Clip.antiAlias,
                child: (company.logoUrl?.small.isNotEmpty ?? false)
                    ? Image.network(
                        company.logoUrl!.small,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company.description ?? '',
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
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                "Nombre d'annonces",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  announcements,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Profil complet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

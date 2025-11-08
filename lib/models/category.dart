class Category {
  final int id;
  final int? parentId;
  final String name;
  final String slug;
  final String description;
  final String? hideDescription;
  final String picture;
  final String iconClass;
  final String seoTitle;
  final String seoDescription;
  final String seoKeywords;
  final int lft;
  final int rgt;
  final int depth;
  final int active;
  final String pictureUrl;
  final dynamic parentClosure;

  Category({
    required this.id,
    this.parentId,
    required this.name,
    required this.slug,
    required this.description,
    this.hideDescription,
    required this.picture,
    required this.iconClass,
    required this.seoTitle,
    required this.seoDescription,
    required this.seoKeywords,
    required this.lft,
    required this.rgt,
    required this.depth,
    required this.active,
    required this.pictureUrl,
    this.parentClosure,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      parentId: json['parent_id'] is int ? json['parent_id'] : (json['parent_id'] != null ? int.tryParse(json['parent_id'].toString()) : null),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      hideDescription: json['hide_description']?.toString(),
      picture: json['picture']?.toString() ?? '',
      iconClass: json['icon_class']?.toString() ?? '',
      seoTitle: json['seo_title']?.toString() ?? '',
      seoDescription: json['seo_description']?.toString() ?? '',
      seoKeywords: json['seo_keywords']?.toString() ?? '',
      lft: json['lft'] is int ? json['lft'] : int.tryParse(json['lft'].toString()) ?? 0,
      rgt: json['rgt'] is int ? json['rgt'] : int.tryParse(json['rgt'].toString()) ?? 0,
      depth: json['depth'] is int ? json['depth'] : int.tryParse(json['depth'].toString()) ?? 0,
      active: json['active'] is int ? json['active'] : int.tryParse(json['active'].toString()) ?? 0,
      pictureUrl: json['picture_url']?.toString() ?? '',
      parentClosure: json['parentClosure'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'name': name,
      'slug': slug,
      'description': description,
      'hide_description': hideDescription,
      'picture': picture,
      'icon_class': iconClass,
      'seo_title': seoTitle,
      'seo_description': seoDescription,
      'seo_keywords': seoKeywords,
      'lft': lft,
      'rgt': rgt,
      'depth': depth,
      'active': active,
      'picture_url': pictureUrl,
      'parentClosure': parentClosure,
    };
  }
}

class CategoryResponse {
  final bool success;
  final String? message;
  final CategoryResult result;

  CategoryResponse({
    required this.success,
    this.message,
    required this.result,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      success: json['success'] ?? false,
      message: json['message'],
      result: CategoryResult.fromJson(json['result'] ?? {}),
    );
  }
}

class CategoryResult {
  final List<Category> data;
  final CategoryLinks links;
  final CategoryMeta meta;

  CategoryResult({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory CategoryResult.fromJson(Map<String, dynamic> json) {
    return CategoryResult(
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      links: CategoryLinks.fromJson(json['links'] ?? {}),
      meta: CategoryMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class CategoryLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  CategoryLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory CategoryLinks.fromJson(Map<String, dynamic> json) {
    return CategoryLinks(
      first: json['first']?.toString(),
      last: json['last']?.toString(),
      prev: json['prev']?.toString(),
      next: json['next']?.toString(),
    );
  }
}

class CategoryMeta {
  final int currentPage;
  final int? from;
  final int lastPage;
  final List<CategoryMetaLink> links;
  final String path;
  final int perPage;
  final int? to;
  final int total;

  CategoryMeta({
    required this.currentPage,
    this.from,
    required this.lastPage,
    required this.links,
    required this.path,
    required this.perPage,
    this.to,
    required this.total,
  });

  factory CategoryMeta.fromJson(Map<String, dynamic> json) {
    return CategoryMeta(
      currentPage: json['current_page'] is int ? json['current_page'] : int.tryParse(json['current_page'].toString()) ?? 1,
      from: json['from'] is int ? json['from'] : (json['from'] != null ? int.tryParse(json['from'].toString()) : null),
      lastPage: json['last_page'] is int ? json['last_page'] : int.tryParse(json['last_page'].toString()) ?? 1,
      links: (json['links'] as List<dynamic>?)
          ?.map((item) => CategoryMetaLink.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      path: json['path']?.toString() ?? '',
      perPage: json['per_page'] is int ? json['per_page'] : int.tryParse(json['per_page'].toString()) ?? 12,
      to: json['to'] is int ? json['to'] : (json['to'] != null ? int.tryParse(json['to'].toString()) : null),
      total: json['total'] is int ? json['total'] : int.tryParse(json['total'].toString()) ?? 0,
    );
  }
}

class CategoryMetaLink {
  final String? url;
  final String label;
  final bool active;

  CategoryMetaLink({
    this.url,
    required this.label,
    required this.active,
  });

  factory CategoryMetaLink.fromJson(Map<String, dynamic> json) {
    return CategoryMetaLink(
      url: json['url']?.toString(),
      label: json['label']?.toString() ?? '',
      active: json['active'] is bool ? json['active'] : (json['active'].toString().toLowerCase() == 'true'),
    );
  }
}

import '../utils/url_helper.dart';

class Company {
  final int id;
  final int userId;
  final String countryCode;
  final String name;
  final String? logo;
  final String? description;
  final int cityId;
  final String? address;
  final String? phone;
  final String? fax;
  final String? email;
  final String? website;
  final String? facebook;
  final String? twitter;
  final String? linkedin;
  final String? pinterest;
  final CompanyLogoUrls? logoUrl;
  final int postsCount;
  final String? countryFlagUrl;

  Company({
    required this.id,
    required this.userId,
    required this.countryCode,
    required this.name,
    this.logo,
    this.description,
    required this.cityId,
    this.address,
    this.phone,
    this.fax,
    this.email,
    this.website,
    this.facebook,
    this.twitter,
    this.linkedin,
    this.pinterest,
    this.logoUrl,
    required this.postsCount,
    this.countryFlagUrl,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? 0,
      countryCode: json['country_code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
      description: json['description'] as String?,
      cityId: json['city_id'] as int? ?? 0,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      fax: json['fax'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      facebook: json['facebook'] as String?,
      twitter: json['twitter'] as String?,
      linkedin: json['linkedin'] as String?,
      pinterest: json['pinterest'] as String?,
      logoUrl: json['logo_url'] != null
          ? CompanyLogoUrls.fromJson(json['logo_url'] as Map<String, dynamic>)
          : null,
      postsCount: json['posts_count'] as int? ?? 0,
      countryFlagUrl: json['country_flag_url'] != null
          ? UrlHelper.fixImageUrl(json['country_flag_url'] as String)
          : null,
    );
  }
}

class CompanyLogoUrls {
  final String full;
  final String small;
  final String medium;
  final String large;

  CompanyLogoUrls({
    required this.full,
    required this.small,
    required this.medium,
    required this.large,
  });

  factory CompanyLogoUrls.fromJson(Map<String, dynamic> json) {
    return CompanyLogoUrls(
      full: UrlHelper.fixImageUrl(json['full'] as String? ?? ''),
      small: UrlHelper.fixImageUrl(json['small'] as String? ?? ''),
      medium: UrlHelper.fixImageUrl(json['medium'] as String? ?? ''),
      large: UrlHelper.fixImageUrl(json['large'] as String? ?? ''),
    );
  }
}

class CompaniesResponse {
  final bool success;
  final String? message;
  final CompaniesResult result;

  CompaniesResponse({
    required this.success,
    this.message,
    required this.result,
  });

  factory CompaniesResponse.fromJson(Map<String, dynamic> json) {
    return CompaniesResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      result: CompaniesResult.fromJson(json['result'] as Map<String, dynamic>? ?? json),
    );
  }
}

class CompaniesResult {
  final List<Company> data;
  final CompaniesLinks? links;
  final CompaniesMeta? meta;

  CompaniesResult({
    required this.data,
    this.links,
    this.meta,
  });

  factory CompaniesResult.fromJson(Map<String, dynamic> json) {
    return CompaniesResult(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Company.fromJson(e as Map<String, dynamic>))
          .toList(),
      links: json['links'] != null
          ? CompaniesLinks.fromJson(json['links'] as Map<String, dynamic>)
          : null,
      meta: json['meta'] != null
          ? CompaniesMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CompaniesLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  CompaniesLinks({this.first, this.last, this.prev, this.next});

  factory CompaniesLinks.fromJson(Map<String, dynamic> json) {
    return CompaniesLinks(
      first: json['first'] as String?,
      last: json['last'] as String?,
      prev: json['prev'] as String?,
      next: json['next'] as String?,
    );
  }
}

class CompaniesMeta {
  final int currentPage;
  final int? from;
  final int lastPage;
  final String path;
  final int perPage;
  final int? to;
  final int total;

  CompaniesMeta({
    required this.currentPage,
    this.from,
    required this.lastPage,
    required this.path,
    required this.perPage,
    this.to,
    required this.total,
  });

  factory CompaniesMeta.fromJson(Map<String, dynamic> json) {
    return CompaniesMeta(
      currentPage: json['current_page'] as int? ?? 1,
      from: json['from'] as int?,
      lastPage: json['last_page'] as int? ?? 1,
      path: json['path'] as String? ?? '',
      perPage: (json['per_page'] is int)
          ? json['per_page'] as int
          : int.tryParse(json['per_page']?.toString() ?? '20') ?? 20,
      to: json['to'] as int?,
      total: json['total'] is int
          ? json['total'] as int
          : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
    );
  }
}

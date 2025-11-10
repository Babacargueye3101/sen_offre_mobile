class PostResponse {
  final bool success;
  final String? message;
  final PostResult result;

  PostResponse({
    required this.success,
    this.message,
    required this.result,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      success: json['success'] ?? false,
      message: json['message'],
      result: PostResult.fromJson(json['result']),
    );
  }
}

class PostResult {
  final List<Post> data;
  final PostLinks links;

  PostResult({
    required this.data,
    required this.links,
  });

  factory PostResult.fromJson(Map<String, dynamic> json) {
    return PostResult(
      data: (json['data'] as List)
          .map((item) => Post.fromJson(item))
          .toList(),
      links: PostLinks.fromJson(json['links']),
    );
  }
}

class Post {
  final int id;
  final String countryCode;
  final int userId;
  final int paymentId;
  final int companyId;
  final String companyName;
  final String logo;
  final String companyDescription;
  final int categoryId;
  final int postTypeId;
  final String title;
  final String excerpt;
  final String description;
  final List<dynamic> tags;
  final dynamic salaryMin;
  final dynamic salaryMax;
  final int salaryTypeId;
  final String currencyCode;
  final dynamic negotiable;
  final String startDate;
  final String applicationUrl;
  final String contactName;
  final String authField;
  final String email;
  final String phone;
  final String phoneNational;
  final String phoneCountry;
  final dynamic phoneHidden;
  final int cityId;
  final double lat;
  final double lon;
  final dynamic address;
  final String createFromIp;
  final dynamic latestUpdateIp;
  final int visits;
  final String tmpToken;
  final String? emailToken;
  final dynamic phoneToken;
  final String? emailVerifiedAt;
  final String? phoneVerifiedAt;
  final int acceptTerms;
  final int acceptMarketingOffers;
  final String? reviewedAt;
  final int featured;
  final dynamic archived;
  final dynamic archivedAt;
  final dynamic archivedManuallyAt;
  final dynamic deletionMailSentAt;
  final dynamic partner;
  final String createdAt;
  final String updatedAt;
  final int reference;
  final String slug;
  final String url;
  final String phoneIntl;
  final String createdAtFormatted;
  final String userPhotoUrl;
  final String countryFlagUrl;
  final String salaryFormatted;
  final String visitsFormatted;
  final dynamic distanceInfo;
  final LogoUrl logoUrl;

  Post({
    required this.id,
    required this.countryCode,
    required this.userId,
    required this.paymentId,
    required this.companyId,
    required this.companyName,
    required this.logo,
    required this.companyDescription,
    required this.categoryId,
    required this.postTypeId,
    required this.title,
    required this.excerpt,
    required this.description,
    required this.tags,
    this.salaryMin,
    this.salaryMax,
    required this.salaryTypeId,
    required this.currencyCode,
    this.negotiable,
    required this.startDate,
    required this.applicationUrl,
    required this.contactName,
    required this.authField,
    required this.email,
    required this.phone,
    required this.phoneNational,
    required this.phoneCountry,
    this.phoneHidden,
    required this.cityId,
    required this.lat,
    required this.lon,
    this.address,
    required this.createFromIp,
    this.latestUpdateIp,
    required this.visits,
    required this.tmpToken,
    this.emailToken,
    this.phoneToken,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    required this.acceptTerms,
    required this.acceptMarketingOffers,
    this.reviewedAt,
    required this.featured,
    this.archived,
    this.archivedAt,
    this.archivedManuallyAt,
    this.deletionMailSentAt,
    this.partner,
    required this.createdAt,
    required this.updatedAt,
    required this.reference,
    required this.slug,
    required this.url,
    required this.phoneIntl,
    required this.createdAtFormatted,
    required this.userPhotoUrl,
    required this.countryFlagUrl,
    required this.salaryFormatted,
    required this.visitsFormatted,
    this.distanceInfo,
    required this.logoUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      countryCode: json['country_code'] ?? '',
      userId: json['user_id'] ?? 0,
      paymentId: json['payment_id'] ?? 0,
      companyId: json['company_id'] ?? 0,
      companyName: json['company_name'] ?? '',
      logo: json['logo'] ?? '',
      companyDescription: json['company_description'] ?? '',
      categoryId: json['category_id'] ?? 0,
      postTypeId: json['post_type_id'] ?? 0,
      title: json['title'] ?? '',
      excerpt: json['excerpt'] ?? '',
      description: json['description'] ?? '',
      tags: json['tags'] ?? [],
      salaryMin: json['salary_min'],
      salaryMax: json['salary_max'],
      salaryTypeId: json['salary_type_id'] ?? 0,
      currencyCode: json['currency_code'] ?? '',
      negotiable: json['negotiable'],
      startDate: json['start_date'] ?? '',
      applicationUrl: json['application_url'] ?? '',
      contactName: json['contact_name'] ?? '',
      authField: json['auth_field'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      phoneNational: json['phone_national'] ?? '',
      phoneCountry: json['phone_country'] ?? '',
      phoneHidden: json['phone_hidden'],
      cityId: json['city_id'] ?? 0,
      lat: json['lat']?.toDouble() ?? 0.0,
      lon: json['lon']?.toDouble() ?? 0.0,
      address: json['address'],
      createFromIp: json['create_from_ip'] ?? '',
      latestUpdateIp: json['latest_update_ip'],
      visits: json['visits'] ?? 0,
      tmpToken: json['tmp_token'] ?? '',
      emailToken: json['email_token'],
      phoneToken: json['phone_token'],
      emailVerifiedAt: json['email_verified_at'],
      phoneVerifiedAt: json['phone_verified_at'],
      acceptTerms: json['accept_terms'] ?? 0,
      acceptMarketingOffers: json['accept_marketing_offers'] ?? 0,
      reviewedAt: json['reviewed_at'],
      featured: json['featured'] ?? 0,
      archived: json['archived'],
      archivedAt: json['archived_at'],
      archivedManuallyAt: json['archived_manually_at'],
      deletionMailSentAt: json['deletion_mail_sent_at'],
      partner: json['partner'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      reference: json['reference'] ?? 0,
      slug: json['slug'] ?? '',
      url: json['url'] ?? '',
      phoneIntl: json['phone_intl'] ?? '',
      createdAtFormatted: json['created_at_formatted'] ?? '',
      userPhotoUrl: json['user_photo_url'] ?? '',
      countryFlagUrl: json['country_flag_url'] ?? '',
      salaryFormatted: json['salary_formatted'] ?? '',
      visitsFormatted: json['visits_formatted'] ?? '',
      distanceInfo: json['distance_info'],
      logoUrl: json['logo_url'] != null ? LogoUrl.fromJson(json['logo_url']) : LogoUrl.empty(),
    );
  }
}

class LogoUrl {
  final String full;
  final String small;
  final String medium;
  final String large;

  LogoUrl({
    required this.full,
    required this.small,
    required this.medium,
    required this.large,
  });

  factory LogoUrl.fromJson(Map<String, dynamic> json) {
    return LogoUrl(
      full: json['full'] ?? '',
      small: json['small'] ?? '',
      medium: json['medium'] ?? '',
      large: json['large'] ?? '',
    );
  }

  factory LogoUrl.empty() {
    return LogoUrl(
      full: '',
      small: '',
      medium: '',
      large: '',
    );
  }
}

class PostLinks {
  final String first;
  final String last;
  final String? prev;
  final String? next;

  PostLinks({
    required this.first,
    required this.last,
    this.prev,
    this.next,
  });

  factory PostLinks.fromJson(Map<String, dynamic> json) {
    return PostLinks(
      first: json['first'] ?? '',
      last: json['last'] ?? '',
      prev: json['prev'],
      next: json['next'],
    );
  }
}

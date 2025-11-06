class LoginResponse {
  final bool success;
  final String? message;
  final LoginUser? result;
  final LoginAuthData? extra;

  LoginResponse({
    required this.success,
    this.message,
    this.result,
    this.extra,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      result: json['result'] != null ? LoginUser.fromJson(json['result'] as Map<String, dynamic>) : null,
      extra: json['extra'] != null ? LoginAuthData.fromJson(json['extra'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'result': result?.toJson(),
      'extra': extra?.toJson(),
    };
  }
}

class LoginUser {
  final int id;
  final String name;
  final String? username;
  final String updatedAt;
  final String originalUpdatedAt;
  final String? originalLastActivity;
  final String createdAtFormatted;
  final String photoUrl;
  final bool pIsOnline;
  final String? countryFlagUrl;
  final String? countryCode;
  final String? languageCode;
  final int userTypeId;
  final int genderId;
  final String? photo;
  final String? about;
  final String authField;
  final String email;
  final String phone;
  final String phoneNational;
  final String phoneCountry;
  final int phoneHidden;
  final int disableComments;
  final String? createFromIp;
  final String? latestUpdateIp;
  final String? provider;
  final String? providerId;
  final String? emailToken;
  final String? phoneToken;
  final String? emailVerifiedAt;
  final String? phoneVerifiedAt;
  final int acceptTerms;
  final int acceptMarketingOffers;
  final int darkMode;
  final String timeZone;
  final int featured;
  final int blocked;
  final int closed;
  final String? lastActivity;
  final String phoneIntl;

  LoginUser({
    required this.id,
    required this.name,
    this.username,
    required this.updatedAt,
    required this.originalUpdatedAt,
    this.originalLastActivity,
    required this.createdAtFormatted,
    required this.photoUrl,
    required this.pIsOnline,
    this.countryFlagUrl,
    this.countryCode,
    this.languageCode,
    required this.userTypeId,
    required this.genderId,
    this.photo,
    this.about,
    required this.authField,
    required this.email,
    required this.phone,
    required this.phoneNational,
    required this.phoneCountry,
    required this.phoneHidden,
    required this.disableComments,
    this.createFromIp,
    this.latestUpdateIp,
    this.provider,
    this.providerId,
    this.emailToken,
    this.phoneToken,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    required this.acceptTerms,
    required this.acceptMarketingOffers,
    required this.darkMode,
    required this.timeZone,
    required this.featured,
    required this.blocked,
    required this.closed,
    this.lastActivity,
    required this.phoneIntl,
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String?,
      updatedAt: json['updated_at'] as String,
      originalUpdatedAt: json['original_updated_at'] as String,
      originalLastActivity: json['original_last_activity'] as String?,
      createdAtFormatted: json['created_at_formatted'] as String,
      photoUrl: json['photo_url'] as String,
      pIsOnline: json['p_is_online'] as bool,
      countryFlagUrl: json['country_flag_url'] as String?,
      countryCode: json['country_code'] as String?,
      languageCode: json['language_code'] as String?,
      userTypeId: json['user_type_id'] as int,
      genderId: json['gender_id'] as int,
      photo: json['photo'] as String?,
      about: json['about'] as String?,
      authField: json['auth_field'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      phoneNational: json['phone_national'] as String,
      phoneCountry: json['phone_country'] as String,
      phoneHidden: json['phone_hidden'] as int,
      disableComments: json['disable_comments'] as int,
      createFromIp: json['create_from_ip'] as String?,
      latestUpdateIp: json['latest_update_ip'] as String?,
      provider: json['provider'] as String?,
      providerId: json['provider_id'] as String?,
      emailToken: json['email_token'] as String?,
      phoneToken: json['phone_token'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      phoneVerifiedAt: json['phone_verified_at'] as String?,
      acceptTerms: json['accept_terms'] as int,
      acceptMarketingOffers: json['accept_marketing_offers'] as int,
      darkMode: json['dark_mode'] as int,
      timeZone: json['time_zone'] as String,
      featured: json['featured'] as int,
      blocked: json['blocked'] as int,
      closed: json['closed'] as int,
      lastActivity: json['last_activity'] as String?,
      phoneIntl: json['phone_intl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'updated_at': updatedAt,
      'original_updated_at': originalUpdatedAt,
      'original_last_activity': originalLastActivity,
      'created_at_formatted': createdAtFormatted,
      'photo_url': photoUrl,
      'p_is_online': pIsOnline,
      'country_flag_url': countryFlagUrl,
      'country_code': countryCode,
      'language_code': languageCode,
      'user_type_id': userTypeId,
      'gender_id': genderId,
      'photo': photo,
      'about': about,
      'auth_field': authField,
      'email': email,
      'phone': phone,
      'phone_national': phoneNational,
      'phone_country': phoneCountry,
      'phone_hidden': phoneHidden,
      'disable_comments': disableComments,
      'create_from_ip': createFromIp,
      'latest_update_ip': latestUpdateIp,
      'provider': provider,
      'provider_id': providerId,
      'email_token': emailToken,
      'phone_token': phoneToken,
      'email_verified_at': emailVerifiedAt,
      'phone_verified_at': phoneVerifiedAt,
      'accept_terms': acceptTerms,
      'accept_marketing_offers': acceptMarketingOffers,
      'dark_mode': darkMode,
      'time_zone': timeZone,
      'featured': featured,
      'blocked': blocked,
      'closed': closed,
      'last_activity': lastActivity,
      'phone_intl': phoneIntl,
    };
  }
}

class LoginAuthData {
  final String authToken;
  final String tokenType;
  final bool isAdmin;

  LoginAuthData({
    required this.authToken,
    required this.tokenType,
    required this.isAdmin,
  });

  factory LoginAuthData.fromJson(Map<String, dynamic> json) {
    return LoginAuthData(
      authToken: json['authToken'] as String,
      tokenType: json['tokenType'] as String,
      isAdmin: json['isAdmin'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authToken': authToken,
      'tokenType': tokenType,
      'isAdmin': isAdmin,
    };
  }
}

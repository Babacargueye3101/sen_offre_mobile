class User {
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

  User({
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
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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
    };
  }
}

class AuthExtra {
  final String authToken;
  final String tokenType;
  final EmailVerification sendEmailVerification;

  AuthExtra({
    required this.authToken,
    required this.tokenType,
    required this.sendEmailVerification,
  });

  factory AuthExtra.fromJson(Map<String, dynamic> json) {
    return AuthExtra(
      authToken: json['authToken'] as String,
      tokenType: json['tokenType'] as String,
      sendEmailVerification: EmailVerification.fromJson(json['sendEmailVerification'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authToken': authToken,
      'tokenType': tokenType,
      'sendEmailVerification': sendEmailVerification.toJson(),
    };
  }
}

class EmailVerification {
  final bool success;
  final bool emailVerificationSent;
  final String message;

  EmailVerification({
    required this.success,
    required this.emailVerificationSent,
    required this.message,
  });

  factory EmailVerification.fromJson(Map<String, dynamic> json) {
    return EmailVerification(
      success: json['success'] as bool,
      emailVerificationSent: json['emailVerificationSent'] as bool,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'emailVerificationSent': emailVerificationSent,
      'message': message,
    };
  }
}

class RegistrationResponse {
  final bool success;
  final String message;
  final User result;
  final AuthExtra extra;

  RegistrationResponse({
    required this.success,
    required this.message,
    required this.result,
    required this.extra,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      result: User.fromJson(json['result'] as Map<String, dynamic>),
      extra: AuthExtra.fromJson(json['extra'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'result': result.toJson(),
      'extra': extra.toJson(),
    };
  }
}

class ApiError {
  final String message;
  final Map<String, List<String>>? errors;

  ApiError({
    required this.message,
    this.errors,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>>? errors;
    if (json['errors'] != null) {
      errors = {};
      final errorsJson = json['errors'] as Map<String, dynamic>;
      errorsJson.forEach((key, value) {
        if (value is List) {
          errors![key] = value.cast<String>();
        }
      });
    }
    
    return ApiError(
      message: json['message'] as String,
      errors: errors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'errors': errors,
    };
  }
}

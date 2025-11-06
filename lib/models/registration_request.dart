class RegistrationRequest {
  final String name;
  final String email;
  final int userTypeId;
  final String password;
  final String passwordConfirmation;
  final String phone;
  final String phoneCountry;
  final int genderId;
  final bool acceptTerms;

  RegistrationRequest({
    required this.name,
    required this.email,
    required this.userTypeId,
    required this.password,
    required this.passwordConfirmation,
    required this.phone,
    required this.phoneCountry,
    required this.genderId,
    this.acceptTerms = true,
  });

  factory RegistrationRequest.fromJson(Map<String, dynamic> json) {
    return RegistrationRequest(
      name: json['name'] as String,
      email: json['email'] as String,
      userTypeId: json['user_type_id'] as int,
      password: json['password'] as String,
      passwordConfirmation: json['password_confirmation'] as String,
      phone: json['phone'] as String,
      phoneCountry: json['phone_country'] as String,
      genderId: json['gender_id'] as int,
      acceptTerms: json['accept_terms'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'user_type_id': userTypeId,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'phone': phone,
      'phone_country': phoneCountry,
      'gender_id': genderId,
      'accept_terms': acceptTerms,
    };
  }
}

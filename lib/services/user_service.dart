import '../models/login_response.dart';
import '../models/registration_response.dart';

class UserService {
  static LoginUser? _currentUser;
  static String? _authToken;
  static String? _tokenType;
  static bool _isAdmin = false;

  /// Sauvegarder les informations de l'utilisateur après connexion
  static void setUserFromLogin(LoginResponse response) {
    if (response.success && response.result != null) {
      _currentUser = response.result;
      if (response.extra != null) {
        _authToken = response.extra!.authToken;
        _tokenType = response.extra!.tokenType;
        _isAdmin = response.extra!.isAdmin;
      }
    }
  }

  /// Sauvegarder les informations de l'utilisateur après inscription
  static void setUserFromRegistration(RegistrationResponse response) {
    if (response.success) {
      // Convertir User en LoginUser pour la cohérence
      _currentUser = LoginUser(
        id: response.result.id,
        name: response.result.name,
        username: response.result.username,
        updatedAt: response.result.updatedAt,
        originalUpdatedAt: response.result.originalUpdatedAt,
        originalLastActivity: response.result.originalLastActivity,
        createdAtFormatted: response.result.createdAtFormatted,
        photoUrl: response.result.photoUrl,
        pIsOnline: response.result.pIsOnline,
        countryFlagUrl: response.result.countryFlagUrl,
        countryCode: null,
        languageCode: null,
        userTypeId: 2, // Par défaut demandeur d'emploi
        genderId: 1, // Par défaut
        photo: null,
        about: null,
        authField: 'email',
        email: '', // Sera rempli si disponible
        phone: '',
        phoneNational: '',
        phoneCountry: '',
        phoneHidden: 0,
        disableComments: 0,
        createFromIp: null,
        latestUpdateIp: null,
        provider: null,
        providerId: null,
        emailToken: null,
        phoneToken: null,
        emailVerifiedAt: null,
        phoneVerifiedAt: null,
        acceptTerms: 1,
        acceptMarketingOffers: 0,
        darkMode: 0,
        timeZone: 'Africa/Dakar',
        featured: 0,
        blocked: 0,
        closed: 0,
        lastActivity: null,
        phoneIntl: '',
      );
      
      _authToken = response.extra.authToken;
      _tokenType = response.extra.tokenType;
      _isAdmin = false; // Nouvel utilisateur n'est pas admin
    }
  }

  /// Obtenir l'utilisateur connecté
  static LoginUser? get currentUser => _currentUser;

  /// Obtenir le nom de l'utilisateur connecté
  static String get userName => _currentUser?.name ?? 'Utilisateur';

  /// Obtenir le nom d'utilisateur (username)
  static String get userUsername => _currentUser?.username ?? '';

  /// Obtenir l'email de l'utilisateur
  static String get userEmail => _currentUser?.email ?? '';

  /// Obtenir l'URL de la photo de profil
  static String get userPhotoUrl => _currentUser?.photoUrl ?? '';

  /// Vérifier si l'utilisateur est connecté
  static bool get isLoggedIn => _currentUser != null;

  /// Vérifier si l'utilisateur est admin
  static bool get isAdmin => _isAdmin;

  /// Obtenir le token d'authentification
  static String? get authToken => _authToken;

  /// Obtenir le type de token
  static String? get tokenType => _tokenType;

  /// Obtenir le header d'autorisation complet
  static String? get authorizationHeader {
    if (_authToken != null && _tokenType != null) {
      return '$_tokenType $_authToken';
    }
    return null;
  }

  /// Déconnecter l'utilisateur
  static void logout() {
    _currentUser = null;
    _authToken = null;
    _tokenType = null;
    _isAdmin = false;
  }

  /// Obtenir un message de bienvenue personnalisé
  static String getWelcomeMessage() {
    if (_currentUser != null) {
      final hour = DateTime.now().hour;
      String greeting;
      
      if (hour < 12) {
        greeting = 'Bonjour';
      } else if (hour < 17) {
        greeting = 'Bon après-midi';
      } else {
        greeting = 'Bonsoir';
      }
      
      return '$greeting ${_currentUser!.name}';
    }
    return 'Bonjour';
  }

  /// Obtenir les informations de l'utilisateur sous forme de Map
  static Map<String, dynamic>? getUserInfo() {
    if (_currentUser == null) return null;
    
    return {
      'id': _currentUser!.id,
      'name': _currentUser!.name,
      'username': _currentUser!.username,
      'email': _currentUser!.email,
      'photo_url': _currentUser!.photoUrl,
      'user_type_id': _currentUser!.userTypeId,
      'is_admin': _isAdmin,
      'auth_token': _authToken,
    };
  }
}

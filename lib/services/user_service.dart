import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_response.dart';
import '../models/registration_response.dart';
import '../config/api_config.dart';
import '../utils/url_helper.dart';

class UserService {
  static LoginUser? _currentUser;
  static String? _authToken;
  static String? _tokenType;
  static bool _isAdmin = false;

  /// Sauvegarder les informations de l'utilisateur après connexion
  static Future<void> setUserFromLogin(LoginResponse response) async {
    if (response.success && response.result != null) {
      _currentUser = response.result;
      if (response.extra != null) {
        _authToken = response.extra!.authToken;
        _tokenType = response.extra!.tokenType;
        _isAdmin = response.extra!.isAdmin;
      }
      
      // Sauvegarder dans SharedPreferences
      await _saveToPreferences();
    }
  }

  /// Sauvegarder les informations de l'utilisateur après inscription
  static Future<void> setUserFromRegistration(RegistrationResponse response) async {
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
      
      // Sauvegarder dans SharedPreferences
      await _saveToPreferences();
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
  static String get userPhotoUrl {
    final url = _currentUser?.photoUrl ?? '';
    return url.isNotEmpty ? UrlHelper.fixImageUrl(url) : url;
  }

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
  static Future<void> logout() async {
    _currentUser = null;
    _authToken = null;
    _tokenType = null;
    _isAdmin = false;
    
    // Supprimer de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('auth_token');
    await prefs.remove('token_type');
    await prefs.remove('is_admin');
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

  /// Sauvegarder les données dans SharedPreferences
  static Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_currentUser != null) {
        // Convertir l'utilisateur en JSON
        final userJson = jsonEncode({
          'id': _currentUser!.id,
          'name': _currentUser!.name,
          'username': _currentUser!.username,
          'email': _currentUser!.email,
          'photo_url': _currentUser!.photoUrl,
          'user_type_id': _currentUser!.userTypeId,
          'phone': _currentUser!.phone,
          'phone_intl': _currentUser!.phoneIntl,
          'updated_at': _currentUser!.updatedAt,
          'created_at_formatted': _currentUser!.createdAtFormatted,
        });
        
        await prefs.setString('user_data', userJson);
      }
      
      if (_authToken != null) {
        await prefs.setString('auth_token', _authToken!);
      }
      
      if (_tokenType != null) {
        await prefs.setString('token_type', _tokenType!);
      }
      
      await prefs.setBool('is_admin', _isAdmin);
      
      print('✅ User data saved to preferences successfully');
      print('   - User: ${_currentUser?.name}');
      print('   - Token: ${_authToken?.substring(0, 20)}...');
    } catch (e) {
      print('Error saving to preferences: $e');
    }
  }

  /// Charger les données depuis SharedPreferences
  static Future<bool> loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final userDataJson = prefs.getString('user_data');
      _authToken = prefs.getString('auth_token');
      _tokenType = prefs.getString('token_type');
      _isAdmin = prefs.getBool('is_admin') ?? false;
      
      if (userDataJson != null && _authToken != null) {
        final userData = jsonDecode(userDataJson);
        
        // Reconstruire l'objet LoginUser
        _currentUser = LoginUser(
          id: userData['id'],
          name: userData['name'],
          username: userData['username'],
          email: userData['email'] ?? '',
          photoUrl: userData['photo_url'] ?? '',
          userTypeId: userData['user_type_id'],
          phone: userData['phone'] ?? '',
          phoneIntl: userData['phone_intl'] ?? '',
          updatedAt: userData['updated_at'],
          createdAtFormatted: userData['created_at_formatted'],
          // Valeurs par défaut pour les champs requis
          originalUpdatedAt: userData['updated_at'],
          originalLastActivity: null,
          pIsOnline: false,
          countryFlagUrl: '',
          countryCode: null,
          languageCode: null,
          genderId: 1,
          photo: null,
          about: null,
          authField: 'email',
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
        );
        
        print('✅ User data loaded from preferences successfully');
        print('   - User: ${_currentUser!.name}');
        print('   - Token: ${_authToken?.substring(0, 20)}...');
        return true;
      }
      
      print('⚠️  No user data found in preferences');
      return false;
    } catch (e) {
      print('Error loading from preferences: $e');
      return false;
    }
  }

  /// Obtenir l'ID de l'utilisateur connecté
  static int get userId => _currentUser?.id ?? 0;

  /// Obtenir le téléphone de l'utilisateur
  static String get userPhone => _currentUser?.phone ?? '';

  /// Mettre à jour le profil de l'utilisateur
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? phoneCountry,
  }) async {
    try {
      if (!isLoggedIn) {
        throw Exception('Utilisateur non connecté');
      }

      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;

      final uri = Uri.parse('${ApiConfig.getBaseUrl()}/users/$userId');
      final httpRequest = await client.openUrl('PUT', uri);

      // Ajouter les headers
      httpRequest.headers.set('Content-Type', 'application/json');
      httpRequest.headers.set('Accept', 'application/json');
      
      final authHeader = authorizationHeader;
      if (authHeader != null) {
        httpRequest.headers.set('Authorization', authHeader);
      }

      // Préparer les données
      final data = {
        'name': name,
        'email': email,
        if (phone != null && phone.isNotEmpty) ...{
          'phone': phone,
          'phone_country': phoneCountry ?? 'SN', // Par défaut Sénégal
        },
      };

      // Envoyer les données
      httpRequest.write(json.encode(data));

      final httpResponse = await httpRequest.close();
      final responseBody = await httpResponse.transform(utf8.decoder).join();

      print('Update Profile Response Status: ${httpResponse.statusCode}');
      print('Update Profile Response: $responseBody');

      if (httpResponse.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        
        // Mettre à jour les données locales si la réponse contient les nouvelles données
        if (jsonResponse['success'] == true && jsonResponse['result'] != null) {
          final updatedUser = jsonResponse['result'];
          
          // Mettre à jour l'utilisateur local
          if (_currentUser != null) {
            _currentUser = LoginUser(
              id: _currentUser!.id,
              name: updatedUser['name'] ?? _currentUser!.name,
              username: _currentUser!.username,
              updatedAt: _currentUser!.updatedAt,
              originalUpdatedAt: _currentUser!.originalUpdatedAt,
              originalLastActivity: _currentUser!.originalLastActivity,
              createdAtFormatted: _currentUser!.createdAtFormatted,
              photoUrl: _currentUser!.photoUrl,
              pIsOnline: _currentUser!.pIsOnline,
              countryFlagUrl: _currentUser!.countryFlagUrl,
              countryCode: _currentUser!.countryCode,
              languageCode: _currentUser!.languageCode,
              userTypeId: _currentUser!.userTypeId,
              genderId: _currentUser!.genderId,
              photo: _currentUser!.photo,
              about: _currentUser!.about,
              authField: _currentUser!.authField,
              email: updatedUser['email'] ?? _currentUser!.email,
              phone: updatedUser['phone'] ?? _currentUser!.phone,
              phoneNational: _currentUser!.phoneNational,
              phoneCountry: _currentUser!.phoneCountry,
              phoneHidden: _currentUser!.phoneHidden,
              disableComments: _currentUser!.disableComments,
              createFromIp: _currentUser!.createFromIp,
              latestUpdateIp: _currentUser!.latestUpdateIp,
              provider: _currentUser!.provider,
              providerId: _currentUser!.providerId,
              emailVerifiedAt: _currentUser!.emailVerifiedAt,
              phoneVerifiedAt: _currentUser!.phoneVerifiedAt,
              acceptTerms: _currentUser!.acceptTerms,
              acceptMarketingOffers: _currentUser!.acceptMarketingOffers,
              darkMode: _currentUser!.darkMode,
              timeZone: _currentUser!.timeZone,
              featured: _currentUser!.featured,
              blocked: _currentUser!.blocked,
              closed: _currentUser!.closed,
              lastActivity: _currentUser!.lastActivity,
              phoneIntl: _currentUser!.phoneIntl,
            );
            
            // Sauvegarder dans SharedPreferences
            await _saveToPreferences();
          }
        }
        
        return jsonResponse;
      } else {
        final jsonResponse = json.decode(responseBody);
        throw Exception(jsonResponse['message'] ?? 'Erreur lors de la mise à jour du profil');
      }
    } catch (e) {
      print('Erreur updateProfile: $e');
      rethrow;
    }
  }

  /// Upload de la photo de profil
  static Future<Map<String, dynamic>> uploadProfilePhoto(File imageFile) async {
    try {
      if (!isLoggedIn) {
        throw Exception('Utilisateur non connecté');
      }

      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;

      final uri = Uri.parse('${ApiConfig.getBaseUrl()}/users/$userId/photo');
      final httpRequest = await client.openUrl('POST', uri);

      // Ajouter les headers
      httpRequest.headers.set('Accept', 'application/json');
      
      final authHeader = authorizationHeader;
      if (authHeader != null) {
        httpRequest.headers.set('Authorization', authHeader);
      }

      // Créer le multipart request
      final boundary = '----WebKitFormBoundary${DateTime.now().millisecondsSinceEpoch}';
      httpRequest.headers.set('Content-Type', 'multipart/form-data; boundary=$boundary');

      // Lire le fichier image
      final imageBytes = await imageFile.readAsBytes();
      final fileName = imageFile.path.split('/').last;

      // Construire le body multipart
      final List<int> body = [];
      
      // Ajouter le champ photo
      body.addAll(utf8.encode('--$boundary\r\n'));
      body.addAll(utf8.encode('Content-Disposition: form-data; name="photo"; filename="$fileName"\r\n'));
      body.addAll(utf8.encode('Content-Type: image/jpeg\r\n\r\n'));
      body.addAll(imageBytes);
      body.addAll(utf8.encode('\r\n'));
      
      // Fermer le boundary
      body.addAll(utf8.encode('--$boundary--\r\n'));

      // Envoyer les données
      httpRequest.add(body);

      final httpResponse = await httpRequest.close();
      final responseBody = await httpResponse.transform(utf8.decoder).join();

      print('Upload Photo Response Status: ${httpResponse.statusCode}');
      print('Upload Photo Response: $responseBody');

      if (httpResponse.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        
        // Mettre à jour la photo de profil localement
        if (jsonResponse['success'] == true && jsonResponse['result'] != null) {
          final updatedUser = jsonResponse['result'];
          
          if (_currentUser != null) {
            _currentUser = LoginUser(
              id: _currentUser!.id,
              name: _currentUser!.name,
              username: _currentUser!.username,
              updatedAt: _currentUser!.updatedAt,
              originalUpdatedAt: _currentUser!.originalUpdatedAt,
              originalLastActivity: _currentUser!.originalLastActivity,
              createdAtFormatted: _currentUser!.createdAtFormatted,
              photoUrl: updatedUser['photo_url'] != null 
                  ? UrlHelper.fixImageUrl(updatedUser['photo_url'])
                  : _currentUser!.photoUrl,
              pIsOnline: _currentUser!.pIsOnline,
              countryFlagUrl: _currentUser!.countryFlagUrl,
              countryCode: _currentUser!.countryCode,
              languageCode: _currentUser!.languageCode,
              userTypeId: _currentUser!.userTypeId,
              genderId: _currentUser!.genderId,
              photo: updatedUser['photo'] ?? _currentUser!.photo,
              about: _currentUser!.about,
              authField: _currentUser!.authField,
              email: _currentUser!.email,
              phone: _currentUser!.phone,
              phoneNational: _currentUser!.phoneNational,
              phoneCountry: _currentUser!.phoneCountry,
              phoneHidden: _currentUser!.phoneHidden,
              disableComments: _currentUser!.disableComments,
              createFromIp: _currentUser!.createFromIp,
              latestUpdateIp: _currentUser!.latestUpdateIp,
              provider: _currentUser!.provider,
              providerId: _currentUser!.providerId,
              emailVerifiedAt: _currentUser!.emailVerifiedAt,
              phoneVerifiedAt: _currentUser!.phoneVerifiedAt,
              acceptTerms: _currentUser!.acceptTerms,
              acceptMarketingOffers: _currentUser!.acceptMarketingOffers,
              darkMode: _currentUser!.darkMode,
              timeZone: _currentUser!.timeZone,
              featured: _currentUser!.featured,
              blocked: _currentUser!.blocked,
              closed: _currentUser!.closed,
              lastActivity: _currentUser!.lastActivity,
              phoneIntl: _currentUser!.phoneIntl,
            );
            
            // Sauvegarder dans SharedPreferences
            await _saveToPreferences();
          }
        }
        
        return jsonResponse;
      } else {
        final jsonResponse = json.decode(responseBody);
        throw Exception(jsonResponse['message'] ?? 'Erreur lors de l\'upload de la photo');
      }
    } catch (e) {
      print('Erreur uploadProfilePhoto: $e');
      rethrow;
    }
  }

  /// Changer le mot de passe de l'utilisateur
  static Future<Map<String, dynamic>> changePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (!isLoggedIn) {
        throw Exception('Utilisateur non connecté');
      }

      if (newPassword != confirmPassword) {
        throw Exception('Les mots de passe ne correspondent pas');
      }

      if (newPassword.length < 6) {
        throw Exception('Le mot de passe doit contenir au moins 6 caractères');
      }

      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;

      final uri = Uri.parse('${ApiConfig.getBaseUrl()}/users/$userId');
      final httpRequest = await client.openUrl('PUT', uri);

      // Ajouter les headers
      httpRequest.headers.set('Content-Type', 'application/json');
      httpRequest.headers.set('Accept', 'application/json');
      
      final authHeader = authorizationHeader;
      if (authHeader != null) {
        httpRequest.headers.set('Authorization', authHeader);
      }

      // Préparer les données (inclure name et email de l'utilisateur connecté)
      final data = {
        'name': userName,
        'email': userEmail,
        'password': newPassword,
        'password_confirmation': confirmPassword,
      };

      // Envoyer les données
      httpRequest.write(json.encode(data));

      final httpResponse = await httpRequest.close();
      final responseBody = await httpResponse.transform(utf8.decoder).join();

      print('Change Password Response Status: ${httpResponse.statusCode}');
      print('Change Password Response: $responseBody');

      if (httpResponse.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return jsonResponse;
      } else {
        final jsonResponse = json.decode(responseBody);
        throw Exception(jsonResponse['message'] ?? 'Erreur lors du changement de mot de passe');
      }
    } catch (e) {
      print('Erreur changePassword: $e');
      rethrow;
    }
  }
}

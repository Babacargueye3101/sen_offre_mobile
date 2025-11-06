class Validators {
  /// Valide un email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }
    
    return null;
  }

  /// Valide un mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    
    // Optionnel: Validation plus stricte
    // if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
    //   return 'Le mot de passe doit contenir au moins une minuscule, une majuscule et un chiffre';
    // }
    
    return null;
  }

  /// Valide la confirmation de mot de passe
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    
    return null;
  }

  /// Valide un nom
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre nom';
    }
    
    if (value.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    
    return null;
  }

  /// Valide un nom d'utilisateur
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre nom d\'utilisateur';
    }
    
    if (value.length < 3) {
      return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
    }
    
    if (value.length > 20) {
      return 'Le nom d\'utilisateur ne peut pas dépasser 20 caractères';
    }
    
    // Vérifier que le nom d'utilisateur ne contient que des caractères autorisés
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
      return 'Le nom d\'utilisateur ne peut contenir que des lettres, chiffres, _ et -';
    }
    
    return null;
  }

  /// Valide un numéro de téléphone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro de téléphone';
    }
    
    // Supprimer les espaces et tirets
    final cleanPhone = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Vérifier la longueur (pour le Sénégal, généralement 9 chiffres après l'indicatif)
    if (cleanPhone.length < 8 || cleanPhone.length > 15) {
      return 'Numéro de téléphone invalide';
    }
    
    // Vérifier que ce sont uniquement des chiffres
    if (!RegExp(r'^\d+$').hasMatch(cleanPhone)) {
      return 'Le numéro ne doit contenir que des chiffres';
    }
    
    return null;
  }

  /// Nettoie et formate un email
  static String cleanEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Nettoie un nom (supprime les espaces en trop)
  static String cleanName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Nettoie un nom d'utilisateur
  static String cleanUsername(String username) {
    return username.trim().toLowerCase();
  }
}

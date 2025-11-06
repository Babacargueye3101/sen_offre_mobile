# Intégration API - SenOffre Mobile

## 📋 Vue d'ensemble

Cette documentation décrit l'intégration de l'API d'inscription dans l'application Flutter SenOffre.

## 🏗️ Architecture

```
lib/
├── config/
│   └── api_config.dart          # Configuration API
├── models/
│   ├── registration_request.dart # Modèle requête inscription
│   └── registration_response.dart # Modèle réponse inscription
├── services/
│   └── api_service.dart         # Service API principal
└── screens/
    └── register_screen.dart     # Écran d'inscription avec intégration API
```

## 🔧 Configuration

### URL de l'API
- **Développement**: `http://localhost:8000/api`
- **Production**: À configurer dans `lib/config/api_config.dart`

### Endpoints utilisés
- `POST /api/users` - Inscription d'un nouvel utilisateur

## 📊 Modèles de données

### RegistrationRequest
```dart
{
  "name": "string",
  "email": "string", 
  "user_type_id": 1|2,  // 1=Employeur, 2=Demandeur d'emploi
  "password": "string",
  "password_confirmation": "string",
  "accept_terms": true
}
```

### RegistrationResponse
```dart
{
  "message": "string",
  "user": {
    "id": int,
    "name": "string",
    "email": "string",
    "user_type_id": int,
    "created_at": "string",
    "updated_at": "string"
  },
  "token": "string?" // Optionnel
}
```

## 🔄 Flux d'inscription

1. **Étape 1**: Saisie des informations de base (nom, civilité, téléphone, type de compte)
2. **Étape 2**: Saisie des informations de compte (nom d'utilisateur, email, mots de passe)
3. **Validation**: Vérification des champs et correspondance des mots de passe
4. **Appel API**: Envoi des données à l'endpoint `/api/users`
5. **Gestion de la réponse**: 
   - Succès → Message de bienvenue + navigation vers l'écran principal
   - Erreur → Affichage du message d'erreur approprié

## 🛠️ Utilisation

### Prérequis
```bash
# Installer les dépendances
flutter pub get
```

### Démarrage
1. Démarrer votre API Laravel sur `http://localhost:8000`
2. Lancer l'application Flutter
3. Tester l'inscription avec des données valides

### Exemple d'utilisation du service
```dart
// Créer une requête d'inscription
final request = RegistrationRequest(
  name: 'John Doe',
  email: 'john@example.com',
  userTypeId: 2, // Demandeur d'emploi
  password: 'password123',
  passwordConfirmation: 'password123',
);

// Appeler l'API
try {
  final response = await ApiService.registerUser(request);
  print('Inscription réussie: ${response.user.name}');
} catch (e) {
  print('Erreur: $e');
}
```

## 🚨 Gestion des erreurs

### Types d'erreurs gérées
- **Erreurs de validation** (400) - Champs manquants ou invalides
- **Erreurs serveur** (500) - Problème côté backend
- **Erreurs réseau** - Pas de connexion internet
- **Timeout** - Délai d'attente dépassé

### Messages d'erreur
- Les erreurs de validation affichent le premier message d'erreur retourné par l'API
- Les erreurs réseau affichent un message générique
- Tous les messages sont en français

## 🔐 Sécurité

### Bonnes pratiques implémentées
- ✅ Validation côté client avant envoi
- ✅ Nettoyage des données (trim, toLowerCase pour email)
- ✅ Vérification de correspondance des mots de passe
- ✅ Gestion sécurisée des erreurs (pas d'exposition d'informations sensibles)

### À implémenter en production
- [ ] Authentification par token
- [ ] Chiffrement HTTPS
- [ ] Validation renforcée des mots de passe
- [ ] Rate limiting côté client

## 📱 Interface utilisateur

### États de l'interface
- **Normal**: Bouton vert "Continuer" actif
- **Loading**: Indicateur de chargement + bouton désactivé
- **Erreur**: Message d'erreur en rouge (SnackBar)
- **Succès**: Message de succès en vert + navigation automatique

### Responsive design
- Interface adaptée aux différentes tailles d'écran
- Validation en temps réel des champs
- Messages d'erreur contextuels

## 🧪 Tests

### Tests à effectuer
1. **Inscription valide** - Tous les champs correctement remplis
2. **Validation des champs** - Champs vides, email invalide, mots de passe différents
3. **Gestion des erreurs** - Email déjà utilisé, erreur serveur
4. **Connectivité** - Pas de connexion internet
5. **Types de compte** - Consultant vs Société

### Données de test
```dart
// Consultant (Demandeur d'emploi)
{
  "name": "Jean Dupont",
  "email": "jean.dupont@example.com",
  "user_type_id": 2,
  "password": "password123",
  "password_confirmation": "password123"
}

// Société (Employeur)  
{
  "name": "Entreprise SARL",
  "email": "contact@entreprise.com", 
  "user_type_id": 1,
  "password": "password123",
  "password_confirmation": "password123"
}
```

## 🔄 Prochaines étapes

### Fonctionnalités à ajouter
1. **Authentification** - Login/logout avec tokens
2. **Profil utilisateur** - Modification des informations
3. **Récupération de mot de passe** - Reset password
4. **Validation email** - Confirmation par email
5. **OAuth** - Connexion avec Google/Facebook

### Améliorations techniques
1. **Cache** - Mise en cache des réponses API
2. **Offline** - Fonctionnement hors ligne
3. **Analytics** - Suivi des événements d'inscription
4. **Performance** - Optimisation des appels API
5. **Tests unitaires** - Couverture complète du code

## 📞 Support

Pour toute question ou problème concernant l'intégration API, consultez :
- Documentation de l'API Laravel
- Logs de l'application Flutter
- Messages d'erreur dans la console de debug

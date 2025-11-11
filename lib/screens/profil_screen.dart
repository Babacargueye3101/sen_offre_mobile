import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'onboarding_screen.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      body: SafeArea(
        child: Column(
          children: [
            // Header avec titre
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Contenu blanc
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Général
                        const Text(
                          'Général',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Modifier Profil',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.lock_outline,
                          title: 'Changer Mot de passe',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.history,
                          title: 'Historique',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.language,
                          title: 'Langue',
                          trailing: const Text(
                            'Français',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                          onTap: () {},
                        ),
                        const SizedBox(height: 32),
                        // Section Autres
                        const Text(
                          'Autres',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: 'FAQ & Support',
                          onTap: () {},
                        ),
                        const SizedBox(height: 32),
                        // Bouton Déconnexion
                        _buildMenuItem(
                          icon: Icons.logout,
                          title: 'Déconnexion',
                          isDestructive: true,
                          onTap: () async {
                            // Afficher une boîte de dialogue de confirmation
                            final shouldLogout = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Déconnexion'),
                                content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Déconnecter'),
                                  ),
                                ],
                              ),
                            );

                            if (shouldLogout == true) {
                              // Déconnecter l'utilisateur
                              await UserService.logout();
                              
                              // Rediriger vers l'écran d'onboarding
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const OnboardingScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDestructive ? Colors.red : Colors.black,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : Colors.black,
                    ),
                  ),
                ),
                if (trailing != null)
                  trailing
                else if (!isDestructive)
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

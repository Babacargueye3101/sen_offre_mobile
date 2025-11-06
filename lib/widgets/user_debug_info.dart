import 'package:flutter/material.dart';
import '../services/user_service.dart';

class UserDebugInfo extends StatelessWidget {
  const UserDebugInfo({super.key});

  @override
  Widget build(BuildContext context) {
    if (!UserService.isLoggedIn) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Aucun utilisateur connecté',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final userInfo = UserService.getUserInfo();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations utilisateur connecté:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Nom: ${UserService.userName}'),
            Text('Username: ${UserService.userUsername}'),
            Text('Email: ${UserService.userEmail}'),
            Text('Admin: ${UserService.isAdmin ? "Oui" : "Non"}'),
            Text('Token: ${UserService.authToken?.substring(0, 20) ?? "N/A"}...'),
            const SizedBox(height: 8),
            Text(
              UserService.getWelcomeMessage(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

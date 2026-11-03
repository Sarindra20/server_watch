import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres & Profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section Profil
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.primary,
                  child: const Icon(Icons.person, size: 36, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Administrateur',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Connecté à ServerWatch',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section Préférences
          const Text(
            'Préférences',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),

          // Option Thème (Clair / Sombre)
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.mode,
            builder: (context, mode, _) {
              final isDark = mode == ThemeMode.dark;
              return SwitchListTile(
                title: const Text('Mode sombre'),
                subtitle: Text(isDark ? 'Activé' : 'Désactivé'),
                secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                value: isDark,
                onChanged: (value) {
                  ThemeController.toggle();
                },
              );
            },
          ),

          const Divider(),

          // Section Application
          const Text(
            'À propos',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),

          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version de l\'application'),
            subtitle: Text('1.0.0 (ServerWatch)'),
          ),
          const ListTile(
            leading: Icon(Icons.dns),
            title: Text('Fréquence de rafraîchissement'),
            subtitle: Text('Toutes les 5 secondes'),
          ),

          const SizedBox(height: 24),

          // Bouton de déconnexion rapide depuis les paramètres
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // Ferme les paramètres
              ApiService.logout();     // Déconnecte l'utilisateur
            },
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
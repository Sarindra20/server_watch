import 'dart:async';

import 'screens/login_screen.dart';

import 'package:flutter/material.dart';

import 'screens/stats_screen.dart';
import 'models/server.dart';
import 'screens/add_server_screen.dart';
import 'screens/server_detail_screen.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'theme.dart';
import 'widgets/app_logo.dart';
import 'widgets/server_card.dart';
import 'theme_controller.dart';
import 'screens/settings_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation du service de notification en arrière-plan
  await NotificationService.init();

  ApiService.authenticated.addListener(() {
    if (!ApiService.authenticated.value) {
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
  });
  await ThemeController.load();
  runApp(const ServerWatchApp());
}

class ServerWatchApp extends StatelessWidget {
  const ServerWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'ServerWatch',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: mode,
          home: ValueListenableBuilder<bool>(
            valueListenable: ApiService.authenticated,
            builder: (context, loggedIn, _) =>
                loggedIn ? const HomeScreen() : const LoginScreen(),
          ),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Server> _servers = []; // Liste complète récupérée de l'API
  List<Server> _filteredServers = []; // Liste affichée après filtre/tri

  // Nouveaux états pour la recherche et le tri
  String _searchQuery = '';
  String _sortBy = 'name'; // 'name', 'status', 'cpu'

  bool _loading = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadServers();
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadServers(silent: true),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Fonction pour appliquer le filtre et le tri sur _servers vers _filteredServers
  void _updateFilterAndSort() {
    // 1. Filtrage par nom ou IP
    List<Server> temp = _servers.where((server) {
      final nameLower = server.name.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();

    // 2. Tri des résultats
    temp.sort((a, b) {
      if (_sortBy == 'name') {
        return a.name.compareTo(b.name);
      } else if (_sortBy == 'status') {
        // En ligne en premier (true > false)
        return b.online.toString().compareTo(a.online.toString());
      } else if (_sortBy == 'cpu') {
        // Tri par CPU décroissant (le plus fort en haut)
        return b.cpu.compareTo(a.cpu);
      }
      return 0;
    });

    setState(() {
      _filteredServers = temp;
    });
  }

  Future<void> _loadServers({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final servers = await ApiService.fetchServers();

      // --- VÉRIFICATION DES ALERTES EN ARRIÈRE-PLAN ---
      for (var server in servers) {
        // Si le serveur est hors ligne ou dépasse 90% de CPU
        if (!server.online) {
          NotificationService.showServerAlert(
            server.name,
            'Le serveur est actuellement HORS LIGNE !',
          );
        } else if (server.cpu >= 90.0) {
          NotificationService.showServerAlert(
            server.name,
            'Surchauffe critique du CPU : ${server.cpu.toStringAsFixed(1)}%',
          );
        }
      }
      // ------------------------------------------------

      if (!mounted) return;
      setState(() {
        _servers = servers;
        _loading = false;
        _error = null;
      });
      _updateFilterAndSort();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Impossible de joindre l'API.\nVérifie qu'elle est lancée.";
        _loading = false;
      });
    }
  }

  Widget _summaryItem(String label, int count, Color color, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int total = _servers.length;
    final int online = _servers.where((s) => s.online).length;
    final int offline = total - online;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo(size: 34),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: 'Server',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const TextSpan(
                    text: 'Watch',
                    style: TextStyle(color: kAccent),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Bouton Statistiques Globales
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatsScreen(servers: _servers),
                ),
              );
            },
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Statistiques globales',
          ),

          // Bouton Paramètres
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Paramètres',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final Server? newServer = await Navigator.push<Server>(
            context,
            MaterialPageRoute(builder: (context) => const AddServerScreen()),
          );
          if (!mounted) return;
          if (newServer != null) {
            try {
              await ApiService.addServer(newServer.name, newServer.ip);
              await _loadServers(silent: true);
            } catch (e) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text("Impossible d'ajouter le serveur"),
                ),
              );
            }
          }
        },
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 48),
                  const SizedBox(height: 12),
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _loadServers(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Cartes de résumé (Total, En ligne, Hors ligne)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _summaryItem(
                          'Total',
                          total,
                          Colors.blue,
                          Icons.dns_rounded,
                        ),
                      ),
                      Expanded(
                        child: _summaryItem(
                          'En ligne',
                          online,
                          Colors.green,
                          Icons.check_circle_rounded,
                        ),
                      ),
                      Expanded(
                        child: _summaryItem(
                          'Hors ligne',
                          offline,
                          Colors.red,
                          Icons.error_rounded,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- BARRE DE RECHERCHE ET MENU DE TRI ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Rechercher un serveur...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            _searchQuery = value;
                            _updateFilterAndSort();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: DropdownButton<String>(
                          value: _sortBy,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'name', child: Text('Nom')),
                            DropdownMenuItem(
                              value: 'status',
                              child: Text('Statut'),
                            ),
                            DropdownMenuItem(value: 'cpu', child: Text('CPU')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _sortBy = value;
                                _updateFilterAndSort();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // --- LISTE DES SERVEURS FILTRÉS (AVEC PULL-TO-REFRESH) ---
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await _loadServers(silent: true);
                    },
                    child: _filteredServers.isEmpty
                        ? ListView(
                            // Permet au RefreshIndicator de fonctionner même si la liste est vide
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 100),
                              Center(
                                child: Text(
                                  'Aucun serveur trouvé',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(12),
                            itemCount: _filteredServers.length,
                            itemBuilder: (context, index) {
                              final server = _filteredServers[index];
                              return Dismissible(
                                key: ValueKey(server.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  padding: const EdgeInsets.only(right: 20),
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (direction) async {
                                  setState(() {
                                    _servers.removeWhere(
                                      (s) => s.id == server.id,
                                    );
                                    _filteredServers.removeAt(index);
                                  });
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('${server.name} supprimé'),
                                    ),
                                  );
                                  try {
                                    await ApiService.deleteServer(server.id!);
                                  } catch (e) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Suppression impossible'),
                                      ),
                                    );
                                    await _loadServers(silent: true);
                                  }
                                },
                                child: ServerCard(
                                  server: server,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ServerDetailScreen(server: server),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}

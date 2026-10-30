import 'dart:async';

import 'package:flutter/material.dart';

import 'models/server.dart';
import 'screens/add_server_screen.dart';
import 'screens/server_detail_screen.dart';
import 'services/api_service.dart';
import 'theme.dart';
import 'widgets/app_logo.dart';
import 'widgets/server_card.dart';

void main() {
  runApp(const ServerWatchApp());
}

class ServerWatchApp extends StatelessWidget {
  const ServerWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServerWatch',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Server> _servers = [];
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

  Future<void> _loadServers({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final servers = await ApiService.fetchServers();
      if (!mounted) return;
      setState(() {
        _servers = servers;
        _loading = false;
        _error = null;
      });
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
              style: const TextStyle(fontSize: 12, color: Colors.white70),
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
              text: const TextSpan(
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'Server',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: 'Watch',
                    style: TextStyle(color: kAccent),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _loadServers(),
            icon: const Icon(Icons.refresh),
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
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _servers.length,
                        itemBuilder: (context, index) {
                          final server = _servers[index];
                          return Dismissible(
                            key: ValueKey(server.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
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
                                _servers.removeAt(index);
                              });
                              final messenger = ScaffoldMessenger.of(context);
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
                  ],
                ),
    );
  }
}
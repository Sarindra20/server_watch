import 'package:flutter/material.dart';
import 'widgets/server_card.dart';
import 'screens/server_detail_screen.dart';
import 'models/server.dart';
import 'screens/add_server_screen.dart';

const List<Server> mockServers = [
  Server(
    name: 'srv-web-01',
    ip: '192.168.1.10',
    online: true,
    cpu: 42,
    ram: 61,
    disk: 55,
  ),
  Server(
    name: 'srv-db-01',
    ip: '192.168.1.11',
    online: true,
    cpu: 78,
    ram: 83,
    disk: 70,
  ),
  Server(
    name: 'srv-backup',
    ip: '192.168.1.12',
    online: false,
    cpu: 0,
    ram: 0,
    disk: 90,
  ),
];
void main() {
  runApp(const ServerWatchApp());
}

class ServerWatchApp extends StatelessWidget {
  const ServerWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Server Watch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 21, 10, 41),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
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
  final List<Server> _servers = List.of(mockServers);

  Widget _summaryItem(String label, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold, color: color),
            ),
            Text(label),
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
        title: const Text('🖥️ Server Watch'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Server? newServer = await Navigator.push<Server>(
            context,
            MaterialPageRoute(builder: (context) => const AddServerScreen()),
          );
          if (newServer != null) {
            setState(() {
              _servers.add(newServer);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(child: _summaryItem('Total', total, Colors.blue)),
                Expanded(child: _summaryItem('En ligne', online, Colors.green)),
                Expanded(child: _summaryItem('Hors ligne', offline, Colors.red)),
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
                  key: ValueKey('${server.name}-${server.ip}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      _servers.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${server.name} supprimé')),
                    );
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
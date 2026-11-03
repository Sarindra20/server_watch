import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/server.dart';

class StatsScreen extends StatelessWidget {
  final List<Server> servers;

  const StatsScreen({super.key, required this.servers});

  @override
  Widget build(BuildContext context) {
    // Calculs globaux sur l'ensemble des serveurs
    final int total = servers.length;
    final int online = servers.where((s) => s.online).length;
    final int offline = total - online;

    // Calcul de la moyenne du CPU et de la RAM sur les serveurs en ligne
    double avgCpu = 0;
    double avgRam = 0;
    final onlineServers = servers.where((s) => s.online).toList();

    if (onlineServers.isNotEmpty) {
      double totalCpu = onlineServers.fold(0, (sum, s) => sum + s.cpu);
      double totalRam = onlineServers.fold(0, (sum, s) => sum + s.ram);
      avgCpu = totalCpu / onlineServers.length;
      avgRam = totalRam / onlineServers.length;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques Globales'),
      ),
      body: total == 0
          ? const Center(
              child: Text(
                'Aucun serveur disponible pour les statistiques.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Section Cartes de résumé
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Serveurs Actifs',
                        '$online / $total',
                        Icons.dns,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Moyenne CPU',
                        '${avgCpu.toStringAsFixed(1)} %',
                        Icons.speed,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Moyenne RAM',
                        '${avgRam.toStringAsFixed(1)} %',
                        Icons.memory,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Hors Ligne',
                        '$offline',
                        Icons.error_outline,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Section Graphique en camembert (Répartition En ligne / Hors ligne)
                const Text(
                  'État de l\'infrastructure',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.green,
                          value: online.toDouble(),
                          title: 'En ligne\n($online)',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.red,
                          value: offline.toDouble(),
                          title: 'Hors ligne\n($offline)',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Section Top 5 des serveurs les plus gourmands en CPU
                const Text(
                  'Charge CPU par serveur',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...servers.map((server) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(server.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            Text('${server.cpu.toStringAsFixed(1)} %'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: server.cpu / 100,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          color: server.cpu >= 90
                              ? Colors.red
                              : server.cpu >= 80
                                  ? Colors.orange
                                  : Colors.blue,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }

  // Widget utilitaire pour les cartes de statistiques
  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
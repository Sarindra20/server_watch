import 'package:flutter/material.dart';
import '../models/server.dart';

class ServerDetailScreen extends StatelessWidget {
  final Server server;

  const ServerDetailScreen({super.key, required this.server});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(server.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 16,
                  color: server.online ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  server.online ? 'En ligne' : 'Hors ligne',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(server.ip),
            const SizedBox(height: 24),
            MetricBar(label: 'CPU', value: server.cpu),
            MetricBar(label: 'RAM', value: server.ram),
            MetricBar(label: 'Disque', value: server.disk),
          ],
        ),
      ),
    );
  }
}

class MetricBar extends StatelessWidget {
  final String label;
  final double value;

  const MetricBar({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final Color color = value >= 80
        ? Colors.red
        : value >= 60
            ? Colors.orange
            : Colors.green;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              Text('${value.toStringAsFixed(0)} %'),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: value / 100,
            minHeight: 10,
            color: color,
          ),
        ],
      ),
    );
  }
}
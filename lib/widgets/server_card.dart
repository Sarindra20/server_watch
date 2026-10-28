import 'package:flutter/material.dart';
import '../models/server.dart';

class ServerCard extends StatelessWidget {
  final Server server;
  final VoidCallback onTap;

  const ServerCard({super.key, required this.server, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color statusColor =
        server.online ? Colors.green.shade600 : Colors.red.shade600;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.dns, color: statusColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          server.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(server.ip),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      server.online ? 'En ligne' : 'Hors ligne',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              if (server.online) ...[
                const SizedBox(height: 14),
                _MiniBar(label: 'CPU', value: server.cpu),
                _MiniBar(label: 'RAM', value: server.ram),
                _MiniBar(label: 'Disque', value: server.disk),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  final String label;
  final double value;

  const _MiniBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final Color color = value >= 80
        ? Colors.red
        : value >= 60
            ? Colors.orange
            : Colors.green;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 56, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 6,
              color: color,
            ),
          ),
          SizedBox(
            width: 48,
            child: Text('${value.toStringAsFixed(0)} %',
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
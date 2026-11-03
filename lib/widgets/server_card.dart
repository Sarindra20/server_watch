import 'package:flutter/material.dart';

import '../models/server.dart';

class ServerCard extends StatelessWidget {
  final Server server;
  final VoidCallback onTap;

  const ServerCard({super.key, required this.server, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Détermination de la couleur selon le CPU ou le statut en ligne/hors-ligne
    final bool isCritical = server.online && server.cpu >= 90.0;
    final bool isWarning = server.online && server.cpu >= 80.0 && server.cpu < 90.0;

    final Color statusColor = !server.online
        ? Colors.red.shade600
        : isCritical
        ? Colors.red.shade600
        : isWarning
        ? Colors.orange.shade600
        : Colors.green.shade600;

    final String statusLabel = !server.online
        ? 'Hors ligne'
        : isCritical
        ? 'Critique'
        : isWarning
        ? 'Alerte'
        : 'En ligne';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor, 
          width: (isCritical || isWarning) ? 2.0 : 1.0, // Bordure plus épaisse en cas d'alerte
        ),
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(server.ip),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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
    final Color color = value >= 90
        ? Colors.red
        : value >= 80
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
            child: Text(
              '${value.toStringAsFixed(0)} %',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
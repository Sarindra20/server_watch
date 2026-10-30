import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/metric.dart';
import '../models/server.dart';
import '../services/api_service.dart';

class ServerDetailScreen extends StatefulWidget {
  final Server server;

  const ServerDetailScreen({super.key, required this.server});

  @override
  State<ServerDetailScreen> createState() => _ServerDetailScreenState();
}

class _ServerDetailScreenState extends State<ServerDetailScreen> {
  late Server _server;
  List<Metric> _metrics = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _server = widget.server;
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final id = widget.server.id;
    if (id == null) return;
    try {
      final server = await ApiService.fetchServer(id);
      final metrics = await ApiService.fetchMetrics(id);
      if (!mounted) return;
      setState(() {
        _server = server;
        _metrics = metrics;
      });
    } catch (_) {
      // on garde les dernières données affichées
    }
  }

  LineChartBarData _line(List<double> values, Color color) {
    return LineChartBarData(
      spots: [
        for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
      ],
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: const FlDotData(show: false),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(label),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final server = _server;

    return Scaffold(
      appBar: AppBar(
        title: Text(server.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
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
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(server.ip),
            const SizedBox(height: 24),
            MetricBar(label: 'CPU', value: server.cpu),
            MetricBar(label: 'RAM', value: server.ram),
            MetricBar(label: 'Disque', value: server.disk),
            const SizedBox(height: 8),
            const Text(
              'Historique (30 dernières minutes)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _legend('CPU', Colors.blue),
                _legend('RAM', Colors.orange),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: _metrics.length < 2
                  ? const Center(
                      child: Text('Pas assez de mesures pour un graphique.'),
                    )
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 100,
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineBarsData: [
                          _line(_metrics.map((m) => m.cpu).toList(), Colors.blue),
                          _line(_metrics.map((m) => m.ram).toList(), Colors.orange),
                        ],
                      ),
                    ),
            ),
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
class Metric {
  final double cpu;
  final double ram;
  final double disk;

  const Metric({required this.cpu, required this.ram, required this.disk});

  factory Metric.fromJson(Map<String, dynamic> json) {
    return Metric(
      cpu: (json['cpu'] as num).toDouble(),
      ram: (json['ram'] as num).toDouble(),
      disk: (json['disk'] as num).toDouble(),
    );
  }
}
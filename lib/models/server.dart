class Server {
  final int? id;
  final String name;
  final String ip;
  final bool online;
  final double cpu;
  final double ram;
  final double disk;
  final List<String> alerts;

  const Server({
    this.id,
    required this.name,
    required this.ip,
    required this.online,
    required this.cpu,
    required this.ram,
    required this.disk,
    this.alerts = const [],
  });

  bool get inAlert => online && alerts.isNotEmpty;

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      id: json['id'] as int?,
      name: json['name'] as String,
      ip: json['ip'] as String,
      online: json['online'] as bool,
      cpu: (json['cpu'] as num).toDouble(),
      ram: (json['ram'] as num).toDouble(),
      disk: (json['disk'] as num).toDouble(),
      alerts: (json['alerts'] as List<dynamic>? ?? [])
          .map((a) => a as String)
          .toList(),
    );
  }
}
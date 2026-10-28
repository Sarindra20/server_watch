class Server {
  final String name;
  final String ip;
  final bool online;
  final double cpu;
  final double ram;
  final double disk;

  const Server({
    required this.name,
    required this.ip,
    required this.online,
    required this.cpu,
    required this.ram,
    required this.disk,
  });

    factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      name: json['name'] as String,
      ip: json['ip'] as String,
      online: json['online'] as bool,
      cpu: (json['cpu'] as num).toDouble(),
      ram: (json['ram'] as num).toDouble(),
      disk: (json['disk'] as num).toDouble(),
    );
  }
}
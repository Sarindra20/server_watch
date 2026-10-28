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
}
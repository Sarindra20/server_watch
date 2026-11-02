class Incident {
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSeconds;

  const Incident({
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
  });

  bool get ongoing => endedAt == null;

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] == null
          ? null
          : DateTime.parse(json['ended_at'] as String),
      durationSeconds: (json['duration_seconds'] as num).toInt(),
    );
  }
}
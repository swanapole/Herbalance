class AlertItem {
  final String id;
  final String userId;
  final String type;
  final DateTime scheduleAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;

  const AlertItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.scheduleAt,
    required this.createdAt,
    this.deliveredAt,
  });

  factory AlertItem.fromJson(Map<String, dynamic> json) => AlertItem(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        type: json['type'] as String,
        scheduleAt: DateTime.parse(json['schedule_at'] as String),
        deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at'] as String) : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

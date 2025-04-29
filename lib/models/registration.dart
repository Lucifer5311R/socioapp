// lib/models/registration.dart


class Registration {
  final String id; // UUID stored as String
  final String userId; // Foreign Key UUID stored as String
  final String eventId; // Foreign Key UUID stored as String
  final DateTime registeredAt;

  Registration({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.registeredAt,
  });

  factory Registration.fromJson(Map<String, dynamic> json) {
    return Registration(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      eventId: json['event_id'] as String,
      registeredAt: DateTime.parse(json['registered_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    // Typically only need user_id and event_id for creating a registration
    return {
      'user_id': userId,
      'event_id': eventId,
      // id and registeredAt handled by DB
    };
  }
}

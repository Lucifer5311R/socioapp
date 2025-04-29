// lib/models/user_badge.dart


class UserBadge {
  final String id; // UUID stored as String
  final String userId; // Foreign Key UUID stored as String
  final String badgeId; // Foreign Key UUID stored as String
  final DateTime awardedAt;

  UserBadge({
    required this.id,
    required this.userId,
    required this.badgeId,
    required this.awardedAt,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      badgeId: json['badge_id'] as String,
      awardedAt: DateTime.parse(json['awarded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    // Usually for awarding a badge (likely admin/organizer only)
    return {
      'user_id': userId,
      'badge_id': badgeId,
      // id and awardedAt handled by DB
    };
  }
}

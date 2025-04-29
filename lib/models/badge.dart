// lib/models/badge.dart

class Badge {
  final String id; // UUID stored as String
  final String name;
  final String? description;
  final String imageUrl;
  final String? criteria;

  Badge({
    required this.id,
    required this.name,
    this.description,
    required this.imageUrl,
    this.criteria,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String,
      criteria: json['criteria'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    // Usually for creating/updating badges (likely admin/organizer only)
    return {
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'criteria': criteria,
    };
  }
}

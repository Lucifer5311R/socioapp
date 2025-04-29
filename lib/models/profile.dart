// lib/models/profile.dart

class Profile {
  final String registerNo;
  final String userId;
  final String? fullName;
  final String? email;
  final String? phoneNo;
  final String? department;
  final String? avatarUrl;
  final DateTime? updatedAt;
  final String? campus; // <-- NEW FIELD

  Profile({
    required this.registerNo,
    required this.userId,
    this.fullName,
    this.email,
    this.phoneNo,
    this.department,
    this.avatarUrl,
    this.updatedAt,
    this.campus, // <-- Add to constructor
  });

  // Factory constructor from JSON
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      registerNo: json['register_no'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phoneNo: json['phone_no'] as String?,
      department: json['department'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      updatedAt:
          json['updated_at'] == null
              ? null
              : DateTime.tryParse(json['updated_at'] as String),
      campus: json['campus'] as String?, // <-- Read campus from JSON
    );
  }

  // Method to convert Profile object to JSON
  Map<String, dynamic> toJson() {
    return {
      'register_no': registerNo,
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone_no': phoneNo,
      'department': department,
      'avatar_url': avatarUrl,
      'campus': campus, // <-- Add campus to JSON
      // 'updated_at' handled by DB
    };
  }

  // copyWith method for immutable updates
  Profile copyWith({
    String? registerNo,
    String? userId,
    String? fullName,
    String? email,
    String? phoneNo,
    String? department,
    String? avatarUrl,
    DateTime? updatedAt,
    String? campus, // <-- Add campus to copyWith
  }) {
    return Profile(
      registerNo: registerNo ?? this.registerNo,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
      department: department ?? this.department,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      campus: campus ?? this.campus, // <-- Update campus in copyWith
    );
  }
}

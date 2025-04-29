// lib/models/event.dart
// ... (other fields and imports remain the same) ...
import 'package:flutter/foundation.dart'; // Import for UniqueKey

class Event {
  final String id;
  final DateTime createdAt;
  final String? organizerId;
  final String eventName;
  final String? description;
  final DateTime eventDate;
  final String? location;
  final double? registrationFee;
  final String? bannerUrl; // This field will hold the image URL
  final bool isPublic;
  final List<String>? tags;
  final String? department;
  final int? maxRegistrations;
  final int? currentRegistrations;
  final String? rules;
  final String? schedule;
  final String? prizes;
  final String? organizerInfo;

  Event({
    required this.id,
    required this.createdAt,
    this.organizerId,
    required this.eventName,
    this.description,
    required this.eventDate,
    this.location,
    this.registrationFee,
    this.bannerUrl, // Keep bannerUrl
    required this.isPublic,
    this.tags,
    this.department,
    this.maxRegistrations,
    this.currentRegistrations,
    this.rules,
    this.schedule,
    this.prizes,
    this.organizerInfo,
  });

  // --- Add copyWith method ---
  Event copyWith({
    String? id,
    DateTime? createdAt,
    String? organizerId,
    String? eventName,
    String? description,
    DateTime? eventDate,
    String? location,
    double? registrationFee,
    String? bannerUrl, // Allow updating bannerUrl
    bool? isPublic,
    List<String>? tags,
    String? department,
    int? maxRegistrations,
    int? currentRegistrations,
    String? rules,
    String? schedule,
    String? prizes,
    String? organizerInfo,
  }) {
    return Event(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      organizerId: organizerId ?? this.organizerId,
      eventName: eventName ?? this.eventName,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      location: location ?? this.location,
      registrationFee: registrationFee ?? this.registrationFee,
      bannerUrl: bannerUrl ?? this.bannerUrl, // Use new value or existing
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
      department: department ?? this.department,
      maxRegistrations: maxRegistrations ?? this.maxRegistrations,
      currentRegistrations: currentRegistrations ?? this.currentRegistrations,
      rules: rules ?? this.rules,
      schedule: schedule ?? this.schedule,
      prizes: prizes ?? this.prizes,
      organizerInfo: organizerInfo ?? this.organizerInfo,
    );
  }

  // --- fromJson factory ---
  factory Event.fromJson(Map<String, dynamic> json) {
    List<String>? parseTags(dynamic tagData) {
      if (tagData is List) {
        return tagData.map((tag) => tag.toString()).toList();
      } else if (tagData is String) {
        return tagData
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return null;
    }

    return Event(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      organizerId: json['organizer_id'] as String?,
      eventName: json['event_name'] as String? ?? 'Unnamed Event',
      description: json['description'] as String?,
      eventDate:
          json['event_date'] != null
              ? DateTime.parse(json['event_date'] as String)
              : DateTime.now().add(const Duration(days: 7)),
      location: json['location'] as String?,
      registrationFee: (json['registration_fee'] as num?)?.toDouble(),
      bannerUrl: json['banner_url'] as String?, // Keep bannerUrl reading
      isPublic: json['is_public'] as bool? ?? false,
      tags: parseTags(json['tags']),
      department: json['department'] as String?,
      maxRegistrations: (json['max_registrations'] as num?)?.toInt(),
      currentRegistrations: (json['current_registrations'] as num?)?.toInt(),
      rules: json['rules'] as String?,
      schedule: json['schedule'] as String?,
      prizes: json['prizes'] as String?,
      organizerInfo: json['organizer_info'] as String?,
    );
  }

  // --- toJson method --- (remains the same)
  Map<String, dynamic> toJson() {
    return {
      'organizer_id': organizerId,
      'event_name': eventName,
      'description': description,
      'event_date': eventDate.toIso8601String(),
      'location': location,
      'registration_fee': registrationFee,
      'banner_url': bannerUrl,
      'is_public': isPublic,
    };
  }

  // --- fromMap factory (Simplified to use fromJson) ---
  // Assumes placeholder keys match DB keys
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event.fromJson(map);
  }
}

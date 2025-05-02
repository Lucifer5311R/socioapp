// lib/models/event.dart
import 'package:flutter/foundation.dart';

class Event {
  final String id;
  final DateTime createdAt;
  final String? organizerId;
  final String eventName;
  final String? description;
  final DateTime eventDate;
  final String? location;
  final double? registrationFee;
  final String? bannerUrl;
  final bool isPublic;
  final List<String>? tags;
  final String? department;
  final int? maxRegistrations; // Can be max individuals OR max teams
  final int? currentRegistrations; // Current individuals OR teams registered
  final String? rules;
  final String? schedule;
  final String? prizes;
  final String? organizerInfo;

  // --- NEW FIELDS ---
  final int minTeamSize; // Minimum members per team (1 for individual)
  final int maxTeamSize; // Maximum members per team (1 for individual)
  // --- END NEW FIELDS ---

  Event({
    required this.id,
    required this.createdAt,
    this.organizerId,
    required this.eventName,
    this.description,
    required this.eventDate,
    this.location,
    this.registrationFee,
    this.bannerUrl,
    required this.isPublic,
    this.tags,
    this.department,
    this.maxRegistrations,
    this.currentRegistrations,
    this.rules,
    this.schedule,
    this.prizes,
    this.organizerInfo,
    this.minTeamSize = 1, // Default to 1 (individual)
    this.maxTeamSize = 1, // Default to 1 (individual)
  });

  // --- Add copyWith method ---
  Event copyWith({
    // ... include all existing fields ...
    String? id,
    DateTime? createdAt,
    String? organizerId,
    String? eventName,
    String? description,
    DateTime? eventDate,
    String? location,
    double? registrationFee,
    String? bannerUrl,
    bool? isPublic,
    List<String>? tags,
    String? department,
    int? maxRegistrations,
    int? currentRegistrations,
    String? rules,
    String? schedule,
    String? prizes,
    String? organizerInfo,
    // --- Add new fields ---
    int? minTeamSize,
    int? maxTeamSize,
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
      bannerUrl: bannerUrl ?? this.bannerUrl,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
      department: department ?? this.department,
      maxRegistrations: maxRegistrations ?? this.maxRegistrations,
      currentRegistrations: currentRegistrations ?? this.currentRegistrations,
      rules: rules ?? this.rules,
      schedule: schedule ?? this.schedule,
      prizes: prizes ?? this.prizes,
      organizerInfo: organizerInfo ?? this.organizerInfo,
      // --- Update new fields ---
      minTeamSize: minTeamSize ?? this.minTeamSize,
      maxTeamSize: maxTeamSize ?? this.maxTeamSize,
    );
  }

  // --- fromJson factory ---
  factory Event.fromJson(Map<String, dynamic> json) {
    // ... (existing tag parsing logic) ...
    List<String>? parseTags(dynamic tagData) {
      /* ... */
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
      bannerUrl: json['banner_url'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      tags: parseTags(json['tags']),
      department: json['department'] as String?,
      maxRegistrations: (json['max_registrations'] as num?)?.toInt(),
      currentRegistrations: (json['current_registrations'] as num?)?.toInt(),
      rules: json['rules'] as String?,
      schedule: json['schedule'] as String?,
      prizes: json['prizes'] as String?,
      organizerInfo: json['organizer_info'] as String?,
      // --- Read new fields from JSON (provide defaults if null) ---
      minTeamSize: (json['min_team_size'] as num?)?.toInt() ?? 1,
      maxTeamSize: (json['max_team_size'] as num?)?.toInt() ?? 1,
    );
  }

  // --- toJson method ---
  Map<String, dynamic> toJson() {
    // Include new fields if needed when *creating* events via API
    return {
      'organizer_id': organizerId,
      'event_name': eventName,
      'description': description,
      'event_date': eventDate.toIso8601String(),
      'location': location,
      'registration_fee': registrationFee,
      'banner_url': bannerUrl,
      'is_public': isPublic,
      'tags':
          tags, // Ensure tags are handled correctly (e.g., as array or comma-separated string)
      'department': department,
      'max_registrations': maxRegistrations,
      'rules': rules,
      'schedule': schedule,
      'prizes': prizes,
      'organizer_info': organizerInfo,
      // --- Add new fields ---
      'min_team_size': minTeamSize,
      'max_team_size': maxTeamSize,
      // currentRegistrations is usually managed by backend triggers/logic
    };
  }

  // Helper to check if it's a team event
  bool get isTeamEvent => maxTeamSize > 1;

  // ... (fromMap factory remains the same) ...
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event.fromJson(map);
  }
}

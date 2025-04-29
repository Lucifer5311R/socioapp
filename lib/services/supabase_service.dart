// lib/services/supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
// Import your data models
import '../models/profile.dart';
import '../models/event.dart';
import '../models/registration.dart';
import '../models/badge.dart';
import '../models/user_badge.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // --- Profile Functions ---

  // Fetch user profile based on user_id from auth
  Future<Profile?> getUserProfile(String userId) async {
    try {
      print('--- Service: Fetching profile for user $userId ---');
      final data =
          await _client
              .from('profiles')
              .select()
              .eq('user_id', userId)
              .maybeSingle(); // Use maybeSingle as profile might not exist yet

      if (data == null) {
        print('--- Service: Profile not found for user $userId ---');
        return null;
      }
      print('--- Service: Profile fetched successfully ---');
      return Profile.fromJson(data);
    } catch (e) {
      print('--- Service ERROR fetching profile: $e ---');
      // Rethrow or handle error as needed in UI layer
      rethrow;
    }
  }

  // Create a new user profile (used during profile completion)
  Future<void> createProfile(Profile profile) async {
    try {
      print(
        '--- Service: Creating profile for user ${profile.userId} with regNo ${profile.registerNo} ---',
      );
      // Ensure user_id is in the map being sent
      final Map<String, dynamic> profileJson = profile.toJson();
      if (!profileJson.containsKey('user_id')) {
        profileJson['user_id'] = profile.userId;
      }
      // Ensure register_no is in the map
      if (!profileJson.containsKey('register_no')) {
        profileJson['register_no'] = profile.registerNo;
      }

      await _client.from('profiles').insert(profileJson);
      print('--- Service: Profile created successfully ---');
    } catch (e) {
      print('--- Service ERROR creating profile: $e ---');
      rethrow;
    }
  }

  // Update an existing user profile
  Future<void> updateProfile(Profile profile) async {
    try {
      print(
        '--- Service: Updating profile for user ${profile.userId} / regNo ${profile.registerNo} ---',
      );
      final updateData = profile.toJson();
      // Remove primary key and potentially user_id from update map if needed, depending on RLS
      // updateData.remove('register_no'); // PK shouldn't be updated
      // updateData.remove('user_id'); // FK shouldn't be updated

      await _client
          .from('profiles')
          .update(updateData)
          // Use user_id for matching as it's the stable link to auth
          .eq('user_id', profile.userId);
      print('--- Service: Profile updated successfully ---');
    } catch (e) {
      print('--- Service ERROR updating profile: $e ---');
      rethrow;
    }
  }

  // --- Event Functions ---

  // Fetch events marked as public (for discover screens)
  Future<List<Event>> fetchPublicEvents() async {
    try {
      print('--- Service: Fetching public events ---');
      final data = await _client
          .from('events')
          .select()
          .eq('is_public', true)
          .order('event_date', ascending: true); // Order by date

      final events = data.map((item) => Event.fromJson(item)).toList();
      print('--- Service: Fetched ${events.length} public events ---');
      return events;
    } catch (e) {
      print('--- Service ERROR fetching public events: $e ---');
      rethrow;
    }
  }

  // Fetch featured/upcoming events (example - adjust filter logic as needed)
  Future<List<Event>> fetchFeaturedEvents() async {
    // Placeholder: Same as public events for now.
    // Later, add criteria like a specific tag, date range, etc.
    print('--- Service: Fetching featured events (using public for now) ---');
    return fetchPublicEvents();
  }

  Future<List<Event>> fetchUpcomingEvents() async {
    // Placeholder: Fetch public events happening today or later
    print('--- Service: Fetching upcoming events ---');
    try {
      final data = await _client
          .from('events')
          .select()
          .eq(
            'is_public',
            true,
          ) // Or maybe fetch non-public if user is logged in?
          .gte(
            'event_date',
            DateTime.now().toIso8601String(),
          ) // Greater than or equal to now
          .order('event_date', ascending: true);

      final events = data.map((item) => Event.fromJson(item)).toList();
      print('--- Service: Fetched ${events.length} upcoming events ---');
      return events;
    } catch (e) {
      print('--- Service ERROR fetching upcoming events: $e ---');
      rethrow;
    }
  }

  // Fetch details for a single event
  Future<Event?> fetchEventDetails(String eventId) async {
    try {
      print('--- Service: Fetching details for event $eventId ---');
      final data =
          await _client
              .from('events')
              .select()
              .eq('id', eventId)
              .maybeSingle(); // Use maybeSingle in case ID is invalid

      if (data == null) {
        print('--- Service: Event $eventId not found ---');
        return null;
      }
      print('--- Service: Event details fetched successfully ---');
      return Event.fromJson(data);
    } catch (e) {
      print('--- Service ERROR fetching event details: $e ---');
      rethrow;
    }
  }

  // --- Registration Functions ---

  // Check if a user is registered for a specific event
  Future<bool> isRegistered(String userId, String eventId) async {
    try {
      print(
        '--- Service: Checking registration for user $userId, event $eventId ---',
      );
      final data =
          await _client
              .from('registrations')
              .select('id') // Just need to check existence
              .eq('user_id', userId)
              .eq('event_id', eventId)
              .maybeSingle();
      final bool registered = data != null;
      print('--- Service: User registered = $registered ---');
      return registered;
    } catch (e) {
      print('--- Service ERROR checking registration: $e ---');
      // Assume not registered on error? Or rethrow?
      return false;
    }
  }

  // Register the current user for an event
  Future<void> registerForEvent(String userId, String eventId) async {
    try {
      print(
        '--- Service: Attempting registration for user $userId, event $eventId ---',
      );
      await _client.from('registrations').insert({
        'user_id': userId,
        'event_id': eventId,
      });
      print('--- Service: Registration successful ---');
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Handle unique constraint violation (already registered)
        print('--- Service INFO: User already registered for this event.');
        // Optionally rethrow a specific error or just log it
        throw Exception('Already registered for this event.');
      } else {
        print(
          '--- Service ERROR registering for event (Postgrest): ${e.message} ---',
        );
        rethrow; // Rethrow other database errors
      }
    } catch (e) {
      print('--- Service ERROR registering for event (Generic): $e ---');
      rethrow;
    }
  }

  // Fetch all events a user is registered for
  Future<List<Registration>> fetchUserRegistrations(String userId) async {
    try {
      print('--- Service: Fetching registrations for user $userId ---');
      final data = await _client
          .from('registrations')
          .select() // Could select specific columns or join with events later
          .eq('user_id', userId)
          .order('registered_at', ascending: false);

      final registrations =
          data.map((item) => Registration.fromJson(item)).toList();
      print('--- Service: Fetched ${registrations.length} registrations ---');
      return registrations;
    } catch (e) {
      print('--- Service ERROR fetching user registrations: $e ---');
      rethrow;
    }
  }

  // --- Badge Functions (Basic - Add more as needed) ---

  // Fetch badges awarded to a specific user
  Future<List<UserBadge>> fetchUserBadges(String userId) async {
    try {
      print('--- Service: Fetching badges for user $userId ---');
      final data = await _client
          .from('user_badges')
          .select() // Select all needed columns
          .eq('user_id', userId)
          .order('awarded_at', ascending: false);

      final userBadges = data.map((item) => UserBadge.fromJson(item)).toList();
      print('--- Service: Fetched ${userBadges.length} user badges ---');
      return userBadges;
    } catch (e) {
      print('--- Service ERROR fetching user badges: $e ---');
      rethrow;
    }
  }

  // Fetch details of specific badges by their IDs
  Future<List<Badge>> fetchBadgeDetails(List<String> badgeIds) async {
    if (badgeIds.isEmpty) return []; // Return empty if no IDs provided
    try {
      print('--- Service: Fetching details for badge IDs: $badgeIds ---');
      final data = await _client
          .from('badges')
          .select()
          .inFilter('id', badgeIds); // Use 'inFilter' to get multiple badges

      final badges = data.map((item) => Badge.fromJson(item)).toList();
      print('--- Service: Fetched details for ${badges.length} badges ---');
      return badges;
    } catch (e) {
      print('--- Service ERROR fetching badge details: $e ---');
      rethrow;
    }
  }
}

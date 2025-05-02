// lib/notifiers/home_screen_notifier.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/event.dart';
// Import your event generation utility (for placeholder logic)
// Ensure this path is correct based on your project structure
import '../utils/random_event_generator.dart';
// Import Category model if needed here, or keep static in HomeScreen
// import '../models/category.dart';

// Enum for Loading State
enum LoadingStatus { idle, loading, loaded, error }

class HomeScreenNotifier extends ChangeNotifier {
  final Logger log = Logger();
  final _random = Random();

  // --- State Variables ---

  // Profile Info
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? get userProfile => _userProfile;
  LoadingStatus _profileLoadingStatus = LoadingStatus.idle;
  LoadingStatus get profileLoadingStatus => _profileLoadingStatus;

  // Filters
  String? _selectedCampusFilter;
  String? get selectedCampusFilter => _selectedCampusFilter;
  // Initialize with defaults, will be updated after profile load
  List<String> _campusOptions = [
    'All Campuses',
    'Delhi NCR',
    'Bangalore Central',
    'Bangalore Kengeri',
    'Bangalore Bannerghatta',
    'Pune Lavasa',
    'Yeshwanthpur Campus',
    'Hosur Road Campus',
  ];
  List<String> get campusOptions => List.unmodifiable(_campusOptions);

  String? _selectedUpcomingFilter;
  String? get selectedUpcomingFilter => _selectedUpcomingFilter;
  final List<String> _upcomingFilters = [
    "All",
    "Today",
    "This Week",
    "Free",
    "Online",
  ];
  List<String> get upcomingFilters => List.unmodifiable(_upcomingFilters);

  // Event Futures & Loading Status
  Future<List<Event>> _topEventsFuture = Future.value([]);
  Future<List<Event>> get topEventsFuture => _topEventsFuture;
  LoadingStatus _topEventsLoadingStatus = LoadingStatus.idle;
  LoadingStatus get topEventsLoadingStatus => _topEventsLoadingStatus;

  Future<List<Event>> _featuredEventsFuture = Future.value([]);
  Future<List<Event>> get featuredEventsFuture => _featuredEventsFuture;
  LoadingStatus _featuredEventsLoadingStatus = LoadingStatus.idle;
  LoadingStatus get featuredEventsLoadingStatus => _featuredEventsLoadingStatus;

  Future<List<Event>> _upcomingFestsFuture = Future.value([]);
  Future<List<Event>> get upcomingFestsFuture => _upcomingFestsFuture;
  LoadingStatus _upcomingFestsLoadingStatus = LoadingStatus.idle;
  LoadingStatus get upcomingFestsLoadingStatus => _upcomingFestsLoadingStatus;

  Future<List<Event>> _allUpcomingEventsFuture = Future.value([]);
  Future<List<Event>> get allUpcomingEventsFuture => _allUpcomingEventsFuture;
  LoadingStatus _allUpcomingEventsLoadingStatus = LoadingStatus.idle;
  LoadingStatus get allUpcomingEventsLoadingStatus =>
      _allUpcomingEventsLoadingStatus;

  Future<List<Event>> _teamEventsFuture = Future.value([]);
  Future<List<Event>> get teamEventsFuture => _teamEventsFuture;
  LoadingStatus _teamEventsLoadingStatus = LoadingStatus.idle;
  LoadingStatus get teamEventsLoadingStatus => _teamEventsLoadingStatus;

  bool
  get isLoadingOverall => // Use this if you need a general loading flag for the whole screen
      _profileLoadingStatus == LoadingStatus.loading;
  // Individual sections will handle their own loading states based on FutureBuilders

  // --- Initialization and Data Loading ---

  HomeScreenNotifier() {
    _initializeAndLoadData();
  }

  Future<void> _initializeAndLoadData() async {
    log.d("Notifier: Initializing and loading data...");
    await _loadProfile();
    if (_userProfile?['campus'] != null) {
      final userCampus = _userProfile!['campus'].toString();
      if (!_campusOptions.contains(userCampus)) {
        _campusOptions = [..._campusOptions, userCampus];
      }
      _selectedCampusFilter = userCampus;
    } else {
      _selectedCampusFilter = _campusOptions.first;
    }
    _selectedUpcomingFilter = _upcomingFilters.first;
    _loadAllEvents(); // Load all event sections
    notifyListeners(); // Notify once after all changes
  }

  Future<void> refreshData() async {
    log.d("Notifier: Refreshing data...");
    // Option 1: Reload everything
    await _loadProfile(); // Reload profile in case campus changed elsewhere
    // Re-determine filters based on potentially updated profile
    final currentCampusFilter =
        _userProfile?['campus']?.toString() ?? _campusOptions.first;
    final currentUpcomingFilter =
        _selectedUpcomingFilter ?? _upcomingFilters.first;
    if (_userProfile?['campus'] != null &&
        !_campusOptions.contains(_userProfile!['campus'])) {
      List<String> updatedOptions = List.from(_campusOptions);
      if (!updatedOptions.contains(_userProfile!['campus'])) {
        updatedOptions.insert(1, _userProfile!['campus']);
        _campusOptions = updatedOptions;
      }
    }
    _selectedCampusFilter = currentCampusFilter;
    _selectedUpcomingFilter = currentUpcomingFilter;
    notifyListeners(); // Update filters in UI if they changed
    _loadAllEvents(); // Reload all events

    // Option 2 (More granular): Only reload event futures if needed
    // _loadAllEvents(); // Just reload events using current filters
  }

  Future<void> _loadProfile() async {
    _profileLoadingStatus = LoadingStatus.loading;
    notifyListeners();

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      _userProfile = null;
      _profileLoadingStatus = LoadingStatus.idle;
      log.w("Notifier: User not logged in during profile fetch.");
      notifyListeners();
      return;
    }
    try {
      // TODO: Replace with SupabaseService call
      final data =
          await Supabase.instance.client
              .from('profiles')
              .select('*, campus')
              .eq('user_id', userId)
              .maybeSingle();
      _userProfile = data;
      _profileLoadingStatus = LoadingStatus.loaded;
      log.i("Notifier: Profile loaded successfully.");
    } catch (e) {
      log.e("Notifier: Error loading profile: $e");
      _userProfile = null;
      _profileLoadingStatus = LoadingStatus.error;
    } finally {
      notifyListeners();
    }
  }

  // --- Placeholder Event Fetching Logic ---
  Future<List<Event>> _fetchEventsPlaceholder(
    String section,
    int limit, {
    String? campus,
    String? upcomingFilter,
    bool onlyTeamEvents = false,
  }) async {
    final delay = Duration(milliseconds: 400 + _random.nextInt(300));
    await Future.delayed(delay);
    log.d(
      "Notifier: Simulating fetch for $section (Campus: $campus, Filter: $upcomingFilter, Limit: $limit, TeamOnly: $onlyTeamEvents)",
    );
    List<Event> events = generateRandomEvents(
      limit * 5,
    ); // Generate more for filtering

    // Placeholder Campus Filtering
    if (campus != null && campus != 'All Campuses') {
      events.removeWhere(
        (e) => _random.nextDouble() < 0.6,
      ); // Simple random removal
    }

    if (onlyTeamEvents) {
      events =
          events
              .where((e) => e.isTeamEvent)
              .toList(); // Filter using the model's getter
    }

    // Placeholder Upcoming Filter Filtering
    if (section == 'allUpcoming' &&
        upcomingFilter != null &&
        upcomingFilter != "All") {
      if (upcomingFilter == "Today") {
        events =
            events
                .where((e) => DateUtils.isSameDay(e.eventDate, DateTime.now()))
                .toList();
      } else if (upcomingFilter == "This Week")
        events =
            events
                .where(
                  (e) =>
                      e.eventDate.isAfter(
                        DateTime.now().subtract(Duration(days: 1)),
                      ) &&
                      e.eventDate.isBefore(
                        DateTime.now().add(const Duration(days: 7)),
                      ),
                )
                .toList();
      else if (upcomingFilter == "Free")
        events = events.where((e) => e.registrationFee == 0.0).toList();
      else if (upcomingFilter == "Online")
        events =
            events
                .where((e) => e.location?.toLowerCase() == 'online (virtual)')
                .toList();
    }

    if (section == 'upcomingFests') {
      events =
          events
              .where(
                (e) =>
                    e.tags?.any(
                      (t) =>
                          t.toLowerCase() == 'fest' ||
                          t.toLowerCase() == 'gala',
                    ) ??
                    false,
              )
              .toList();
    }
    if (section == 'featured') {
      // Simulate featured - maybe take events with specific tags or just random subset
      events.removeWhere((e) => _random.nextDouble() < 0.5);
    }
    if (section == 'top') {
      // Simulate top picks - maybe based on registration count or random
      events.sort(
        (a, b) => (b.currentRegistrations ?? 0).compareTo(
          a.currentRegistrations ?? 0,
        ),
      );
    }

    return events.take(limit).toList();
  }

  // --- Load Specific Event Sections ---
  // These now manage their own loading status and update the future

  Future<void> _loadTopEvents() async {
    _updateSectionLoadingStatus(
      '_topEventsLoadingStatus',
      LoadingStatus.loading,
    );
    try {
      // Assign the Future immediately, let FutureBuilder handle intermediate states
      _topEventsFuture = _fetchEventsPlaceholder(
        'top',
        7,
        campus: _selectedCampusFilter,
      );
      await _topEventsFuture; // Await completion to set final status
      _updateSectionLoadingStatus(
        '_topEventsLoadingStatus',
        LoadingStatus.loaded,
      );
    } catch (e) {
      log.e("Notifier: Error loading top events: $e");
      _updateSectionLoadingStatus(
        '_topEventsLoadingStatus',
        LoadingStatus.error,
      );
      _topEventsFuture = Future.value([]); // Provide empty list on error
    }
  }

  Future<void> _loadFeaturedEvents() async {
    _updateSectionLoadingStatus(
      '_featuredEventsLoadingStatus',
      LoadingStatus.loading,
    );
    try {
      _featuredEventsFuture = _fetchEventsPlaceholder(
        'featured',
        7,
        campus: _selectedCampusFilter,
      );
      await _featuredEventsFuture;
      _updateSectionLoadingStatus(
        '_featuredEventsLoadingStatus',
        LoadingStatus.loaded,
      );
    } catch (e) {
      log.e("Notifier: Error loading featured events: $e");
      _updateSectionLoadingStatus(
        '_featuredEventsLoadingStatus',
        LoadingStatus.error,
      );
      _featuredEventsFuture = Future.value([]);
    }
  }

  Future<void> _loadUpcomingFests() async {
    _updateSectionLoadingStatus(
      '_upcomingFestsLoadingStatus',
      LoadingStatus.loading,
    );
    try {
      _upcomingFestsFuture = _fetchEventsPlaceholder(
        'upcomingFests',
        7,
        campus: _selectedCampusFilter,
      );
      await _upcomingFestsFuture;
      _updateSectionLoadingStatus(
        '_upcomingFestsLoadingStatus',
        LoadingStatus.loaded,
      );
    } catch (e) {
      log.e("Notifier: Error loading upcoming fests: $e");
      _updateSectionLoadingStatus(
        '_upcomingFestsLoadingStatus',
        LoadingStatus.error,
      );
      _upcomingFestsFuture = Future.value([]);
    }
  }

  Future<void> _loadTeamEvents() async {
    _updateSectionLoadingStatus(
      '_teamEventsLoadingStatus',
      LoadingStatus.loading,
    );
    try {
      _teamEventsFuture = _fetchEventsPlaceholder(
        'teamEvents', // Section identifier
        7, // Limit number of events shown in carousel
        campus: _selectedCampusFilter, // Apply campus filter
        onlyTeamEvents: true, // <<-- Specify to fetch only team events
      );
      await _teamEventsFuture; // Await completion to set final status
      _updateSectionLoadingStatus(
        '_teamEventsLoadingStatus',
        LoadingStatus.loaded,
      );
    } catch (e) {
      log.e("Notifier: Error loading team events: $e");
      _updateSectionLoadingStatus(
        '_teamEventsLoadingStatus',
        LoadingStatus.error,
      );
      _teamEventsFuture = Future.value([]); // Provide empty list on error
    }
  }

  Future<void> _loadAllUpcomingEvents() async {
    _updateSectionLoadingStatus(
      '_allUpcomingEventsLoadingStatus',
      LoadingStatus.loading,
    );
    try {
      _allUpcomingEventsFuture = _fetchEventsPlaceholder(
        'allUpcoming',
        20,
        campus: _selectedCampusFilter,
        upcomingFilter: _selectedUpcomingFilter,
      );
      await _allUpcomingEventsFuture;
      _updateSectionLoadingStatus(
        '_allUpcomingEventsLoadingStatus',
        LoadingStatus.loaded,
      );
    } catch (e) {
      log.e("Notifier: Error loading all upcoming events: $e");
      _updateSectionLoadingStatus(
        '_allUpcomingEventsLoadingStatus',
        LoadingStatus.error,
      );
      _allUpcomingEventsFuture = Future.value([]);
    }
  }

  // Helper to safely update loading status and notify listeners
  void _updateSectionLoadingStatus(String statusVarName, LoadingStatus status) {
    bool changed = false;
    switch (statusVarName) {
      case '_topEventsLoadingStatus':
        if (_topEventsLoadingStatus != status) {
          _topEventsLoadingStatus = status;
          changed = true;
        }
        break;
      case '_featuredEventsLoadingStatus':
        if (_featuredEventsLoadingStatus != status) {
          _featuredEventsLoadingStatus = status;
          changed = true;
        }
        break;
      case '_upcomingFestsLoadingStatus':
        if (_upcomingFestsLoadingStatus != status) {
          _upcomingFestsLoadingStatus = status;
          changed = true;
        }
        break;
      case '_allUpcomingEventsLoadingStatus':
        if (_allUpcomingEventsLoadingStatus != status) {
          _allUpcomingEventsLoadingStatus = status;
          changed = true;
        }
        break;
      case '_teamEventsLoadingStatus':
        if (_teamEventsLoadingStatus != status) {
          _teamEventsLoadingStatus = status;
          changed = true;
        }
        break;
    }
    if (changed) {
      notifyListeners();
    }
  }

  // Load all sections concurrently
  void _loadAllEvents() {
    log.d("Notifier: Loading all event sections...");
    // Trigger all loads, they update their state individually
    _loadTopEvents();
    _loadFeaturedEvents();
    _loadUpcomingFests();
    _loadTeamEvents();
    _loadAllUpcomingEvents();
  }

  // --- Filter Update Methods ---

  Timer? _debounce;

  void setCampusFilter(String? newFilter) {
    final effectiveFilter = newFilter ?? _campusOptions.first;
    if (effectiveFilter != _selectedCampusFilter) {
      log.i("Notifier: Setting Campus Filter to $effectiveFilter");
      _selectedCampusFilter = effectiveFilter;
      notifyListeners();
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        _loadAllEvents(); // Reload after debounce
      });
    }
  }

  void setUpcomingFilter(String? newFilter) {
    final effectiveFilter =
        newFilter ?? _upcomingFilters.first; // Default to "All"
    if (effectiveFilter != _selectedUpcomingFilter) {
      log.i("Notifier: Setting Upcoming Filter to $effectiveFilter");
      _selectedUpcomingFilter = effectiveFilter;
      notifyListeners(); // Update UI showing the selected filter
      // ONLY reload the list affected by this filter
      _loadAllUpcomingEvents();
    }
  }
}

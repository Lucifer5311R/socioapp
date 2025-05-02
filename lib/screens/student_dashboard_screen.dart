// lib/screens/student_dashboard_screen.dart
// REVISED V3 - Based on Image Reference, User Feedback, and Color Tuning (Full Code)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // Keep for random placeholders if needed
import 'package:flutter_animate/flutter_animate.dart'; // Keep for animations
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// Import models and widgets (adjust if needed)
import '../models/event.dart'; // Assuming Event model is needed
// Import badge model if you create one for _userBadges structure
// import '../models/badge.dart';
import '../utils/random_event_generator.dart'; // Might still use for calendar events initially

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

// Add SingleTickerProviderStateMixin for TabController
class _StudentDashboardScreenState extends State<StudentDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;

  // Calendar state
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Event> _selectedDayEvents = []; // Keep for calendar interaction

  // --- State Variables for NEW Design ---
  // TODO: Replace with actual fetched data later
  int _upcomingEventCount = 12; // Placeholder
  int _completedEventCount = 8; // Placeholder
  int _badgeCount = 3; // Placeholder
  List<Map<String, dynamic>> _userBadges = [
    // Placeholder Badge Data Map Structure
    {'name': 'Tech Club', 'icon': Icons.computer_outlined},
    {'name': 'Event MVP', 'icon': Icons.emoji_events_outlined},
    {'name': 'Volunteer', 'icon': Icons.volunteer_activism_outlined},
    // Add more placeholder badges if needed
  ];
  // Use specific Event type for lists
  List<Event> _upcomingRegisteredEvents =
      []; // Placeholder list - Populate with actual data
  List<Event> _completedRegisteredEvents =
      []; // Placeholder list - Populate with actual data
  List<Event> _calendarEvents = []; // Store events for calendar marking

  // Tab Controller for Registered Events
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with 2 tabs (Upcoming, Completed)
    _tabController = TabController(length: 2, vsync: this);
    _fetchProfileAndDashboardData(); // Fetch profile and potentially other data
    _selectedDay = _focusedDay;
    // TODO: Load calendar events based on registered/relevant events
    _calendarEvents = _generateEventsForCalendar(
      50,
    ); // Keep placeholder for now
    if (mounted) {
      // Check if mounted before calling setState related method
      _loadEventsForSelectedDay(_selectedDay!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose TabController
    super.dispose();
  }

  // --- Data Generation / Fetching ---

  // Generates events specifically for marking the calendar
  // TODO: Replace or supplement with real registered event data for calendar markers
  List<Event> _generateEventsForCalendar(int count) {
    List<Event> events = generateRandomEvents(count);
    DateTime now = DateTime.now();
    // Generate events within a wider range around today for better demo
    DateTime startDate = now.subtract(const Duration(days: 30));
    DateTime endDate = now.add(const Duration(days: 60));
    return events
        .where(
          (e) =>
              e.eventDate.isAfter(startDate) && e.eventDate.isBefore(endDate),
        )
        .toList();
  }

  Future<void> _fetchProfileAndDashboardData() async {
    // TODO: Refactor this significantly to fetch real dashboard data
    // - Fetch Profile (Keep existing logic)
    // - Fetch User Registrations (Upcoming & Completed) -> SupabaseService
    // - Fetch Event Details for registered events -> SupabaseService
    // - Fetch User Badges (IDs) -> SupabaseService
    // - Fetch Badge Details (Icons/Names) -> SupabaseService
    // - Calculate Counts
    // - Update state variables (_upcomingEventCount, _completedEventCount, _badgeCount, _userBadges, _upcomingRegisteredEvents, _completedRegisteredEvents)

    if (!mounted) return; // Check if widget is still mounted
    setState(() {
      _isLoading = true;
    });

    final userId = _supabase.auth.currentUser?.id;
    Map<String, dynamic>? fetchedProfile;

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User not logged in."),
            backgroundColor: Colors.orange,
          ),
        );
        // Use maybePop to avoid errors if cannot pop, or use goNamed to ensure navigation
        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed(
            'login',
          ); // Redirect to login if not authenticated and cannot pop
        }
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      fetchedProfile =
          await _supabase
              .from('profiles')
              .select('*, campus') // Ensure all needed fields are selected
              .eq('user_id', userId)
              .single(); // Use single as profile should exist for logged-in user on dashboard

      // --- MOCK DATA LOADING (Replace with real fetches using SupabaseService) ---
      // Simulate fetching counts and lists
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate network delay

      // Example: Replace placeholders with fetched data if available
      // _upcomingEventCount = await SupabaseService().fetchUpcomingEventCount(userId);
      // _completedEventCount = await SupabaseService().fetchCompletedEventCount(userId);
      // _badgeCount = await SupabaseService().fetchBadgeCount(userId);
      // _userBadges = await SupabaseService().fetchUserBadgeDetails(userId); // This service method would fetch user_badges and join with badges table
      // final allRegistrations = await SupabaseService().fetchUserRegisteredEvents(userId); // Assume this returns List<Event>
      // _upcomingRegisteredEvents = allRegistrations.where((e) => e.eventDate.isAfter(DateTime.now())).toList();
      // _completedRegisteredEvents = allRegistrations.where((e) => !e.eventDate.isAfter(DateTime.now())).toList();

      // Using generated data for UI demonstration:
      _upcomingRegisteredEvents =
          generateRandomEvents(
            5,
          ).where((e) => e.eventDate.isAfter(DateTime.now())).toList();
      _completedRegisteredEvents =
          generateRandomEvents(
            3,
          ).where((e) => !e.eventDate.isAfter(DateTime.now())).toList();

      // You might want to update _calendarEvents based on fetched events here
      // _calendarEvents = [..._upcomingRegisteredEvents, ..._completedRegisteredEvents, ..._generateEventsForCalendar(20)]; // Example combination

      // --- END MOCK DATA LOADING ---
    } catch (e) {
      print("Error fetching dashboard data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading dashboard data: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Decide how to handle error - show error widget, keep placeholders?
      // Set profile to null or an empty map if fetch fails?
      fetchedProfile = null;
    } finally {
      if (mounted) {
        setState(() {
          _profileData =
              fetchedProfile; // Store fetched profile data (could be null on error)
          _isLoading = false; // Set loading to false
          _loadEventsForSelectedDay(_selectedDay ?? DateTime.now());
        });
      }
    }
  }

  // --- Calendar Event Loader & Selection Handler ---
  List<Event> _getEventsForDay(DateTime day) {
    // This function provides events to the TableCalendar for marking days.
    // TODO: Update _calendarEvents to include actual registered events for accurate markers.
    return _calendarEvents
        .where((event) => isSameDay(event.eventDate, day))
        .toList();
  }

  void _loadEventsForSelectedDay(DateTime day) {
    // This loads events specifically for the list displayed *below* the calendar when a day is tapped.
    // TODO: This list should ideally also show the user's registered events for that day.
    if (!mounted) return;
    setState(() {
      _selectedDayEvents = _getEventsForDay(day);
    });
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor:
          theme.brightness == Brightness.light
              ? Colors.grey[100] // Lighter background for light mode
              : colorScheme
                  .surfaceContainerLowest, // Darker background for dark mode
      appBar: AppBar(
        title: Text(
          'SOCIO.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed:
                _fetchProfileAndDashboardData, // Call the updated fetch method
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await _supabase.auth.signOut();
              // GoRouter redirect logic should handle navigation after sign out
            },
          ),
        ],
        backgroundColor: colorScheme.surface, // Theme surface color for AppBar
        elevation: 1.0,
        shadowColor: colorScheme.shadow.withOpacity(0.1),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              // Handle error state where profile fetch failed but loading is done
              : _profileData == null && !_isLoading
              ? _buildErrorState() // Show an error state if profile is null after load attempt
              : LayoutBuilder(
                // Use LayoutBuilder once loading/error is handled
                builder: (context, constraints) {
                  bool useColumns =
                      constraints.maxWidth <
                      1000; // Adjust breakpoint if needed
                  return SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      physics:
                          const BouncingScrollPhysics(), // Nicer scroll feel
                      child:
                          useColumns
                              ? _buildStackedLayoutNew(theme)
                              : _buildSideBySideLayoutNew(theme),
                    ),
                  );
                },
              ),
    );
  }

  // --- Error State Widget ---
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 50,
            ),
            const SizedBox(height: 10),
            const Text(
              "Could not load dashboard data.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              "Please check your connection and try again.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text("Retry"),
              onPressed: _fetchProfileAndDashboardData,
            ),
          ],
        ),
      ),
    );
  }

  // --- NEW Layout Builders ---
  Widget _buildSideBySideLayoutNew(ThemeData theme) {
    // Layout based on reference image for wider screens
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Profile, Badges)
        SizedBox(
          width: 300, // Fixed or max width for left column
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildUserInfoCardNew(theme)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.1, duration: 300.ms),
              const SizedBox(height: 20),
              _buildUserBadgesCard(theme)
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.1, duration: 300.ms),
            ],
          ),
        ),
        const SizedBox(width: 24),

        // Right Column (Summary, Registered Events, Calendar)
        Expanded(
          child: Column(
            children: [
              _buildSummaryNumbersRow(theme)
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.1, duration: 300.ms),
              const SizedBox(height: 20),
              _buildRegisteredEventsSection(theme)
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms)
                  .slideY(begin: 0.1, duration: 300.ms),
              const SizedBox(height: 20),
              _buildEventsCalendar(theme)
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 400.ms)
                  .slideY(begin: 0.1, duration: 300.ms),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStackedLayoutNew(ThemeData theme) {
    // Stack elements vertically for narrower screens
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildUserInfoCardNew(theme)
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideY(begin: 0.1, duration: 300.ms),
        const SizedBox(height: 20),
        _buildUserBadgesCard(theme)
            .animate()
            .fadeIn(delay: 300.ms, duration: 400.ms)
            .slideY(begin: 0.1, duration: 300.ms),
        const SizedBox(height: 20),
        _buildSummaryNumbersRow(theme)
            .animate()
            .fadeIn(delay: 400.ms, duration: 400.ms)
            .slideY(begin: 0.1, duration: 300.ms),
        const SizedBox(height: 20),
        _buildRegisteredEventsSection(theme)
            .animate()
            .fadeIn(delay: 500.ms, duration: 400.ms)
            .slideY(begin: 0.1, duration: 300.ms),
        const SizedBox(height: 20),
        _buildEventsCalendar(theme)
            .animate()
            .fadeIn(delay: 600.ms, duration: 400.ms)
            .slideY(begin: 0.1, duration: 300.ms),
      ],
    );
  }

  // --- NEW Section Widgets ---

  // 1. Redesigned User Info Card - Tuned Colors
  Widget _buildUserInfoCardNew(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    // Use profileData which is fetched, handle null case gracefully
    String? avatarUrl = _profileData?['avatar_url']?.toString();
    String name = _profileData?['full_name']?.toString() ?? 'Student Name';
    String regNo = _profileData?['register_no']?.toString() ?? 'N/A';
    String dept = _profileData?['department']?.toString() ?? 'Department N/A';
    String campus = _profileData?['campus']?.toString() ?? 'Campus N/A';
    String email =
        _profileData?['email']?.toString() ??
        _supabase.auth.currentUser?.email ??
        'Email N/A';
    String course =
        _profileData?['course']?.toString() ??
        'Course Not Available'; // Placeholder
    String joinedDate = 'Joined: N/A'; // Placeholder

    const double avatarRadius = 50;
    const cardBorderRadius = Radius.circular(12);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(cardBorderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Top Primary Color Section ---
          Container(
            color: colorScheme.primary, // Use theme primary
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
            child: Column(
              children: [
                CircleAvatar(
                  // Outer circle (the "border")
                  radius: avatarRadius,
                  backgroundColor:
                      colorScheme
                          .surfaceContainerHighest, // Theme-aware white/light grey
                  child: CircleAvatar(
                    // Inner circle for image/icon
                    radius: avatarRadius - 3,
                    backgroundColor: colorScheme.surfaceVariant, // Fallback bg
                    backgroundImage:
                        (avatarUrl != null && avatarUrl.isNotEmpty)
                            ? CachedNetworkImageProvider(avatarUrl)
                            : null,
                    child:
                        (avatarUrl == null || avatarUrl.isEmpty)
                            ? Icon(
                              Icons.person_outline,
                              size: avatarRadius * 0.8,
                              color: colorScheme.onSurfaceVariant,
                            )
                            : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary, // Text on primary
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  regNo,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(
                      0.85,
                    ), // Text on primary
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // --- Bottom Surface Color Section ---
          Container(
            color: colorScheme.surface, // Use theme surface
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pass flag to use text colors appropriate for surface background
                _buildProfileDetailRow(
                  'Course',
                  course,
                  theme,
                  onWhiteBg: true,
                ),
                _buildProfileDetailRow(
                  'Department',
                  dept,
                  theme,
                  onWhiteBg: true,
                ),
                _buildProfileDetailRow(
                  'Campus',
                  campus,
                  theme,
                  onWhiteBg: true,
                ),
                _buildProfileDetailRow('Email', email, theme, onWhiteBg: true),
                _buildProfileDetailRow(
                  'Joined',
                  joinedDate,
                  theme,
                  onWhiteBg: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for profile detail rows - Uses theme colors based on flag
  Widget _buildProfileDetailRow(
    String label,
    String value,
    ThemeData theme, {
    bool onWhiteBg = false,
  }) {
    final colorScheme = theme.colorScheme;
    final labelColor =
        onWhiteBg
            ? colorScheme
                .onSurfaceVariant // Greyish for label on surface
            : colorScheme.onPrimary.withOpacity(
              0.7,
            ); // Lighter label on primary
    final valueColor =
        onWhiteBg
            ? colorScheme
                .onSurface // Black/Dark grey for value on surface
            : colorScheme.onPrimary; // White for value on primary

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 2. User Badges Card - With Yellow Accent
  Widget _buildUserBadgesCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return _buildDashboardCard(
      title: "Badges",
      icon: Icons.shield_outlined, // Or Icons.emoji_events_outlined
      theme: theme,
      child:
          _userBadges.isEmpty
              ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "No badges earned yet.",
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              )
              : Wrap(
                spacing: 12.0,
                runSpacing: 10.0,
                alignment: WrapAlignment.center, // Center badges if few
                children:
                    _userBadges.map((badge) {
                      IconData badgeIcon =
                          badge['icon'] as IconData? ?? Icons.star_border;
                      String badgeName = badge['name'] as String? ?? 'Badge';

                      // TODO: Replace this Column with actual Badge widget using Image.network if available
                      return SizedBox(
                        // Constrain width for each badge item
                        width: 60, // Adjust width as needed
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  colorScheme
                                      .tertiaryContainer, // Yellow accent bg
                              child: Icon(
                                badgeIcon,
                                size: 24,
                                color:
                                    colorScheme
                                        .onTertiaryContainer, // Contrast on yellow
                              ),
                              // child: Image.network(badgeImageUrl, fit: BoxFit.cover), // Use when available
                            ),
                            const SizedBox(height: 5),
                            Text(
                              badgeName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color:
                                    colorScheme
                                        .onSurfaceVariant, // Text color on card background
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
    );
  }

  // 3. Summary Numbers Row
  Widget _buildSummaryNumbersRow(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Use Expanded to ensure items take available space evenly
          Expanded(
            child: _buildSummaryItem(
              theme,
              Icons.event_note_outlined,
              _upcomingEventCount,
              "Upcoming",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryItem(
              theme,
              Icons.event_available_outlined,
              _completedEventCount,
              "Completed",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryItem(
              theme,
              Icons.shield_outlined,
              _badgeCount,
              "Badges",
            ),
          ),
        ],
      ),
    );
  }

  // Helper for individual summary items
  Widget _buildSummaryItem(
    ThemeData theme,
    IconData icon,
    int count,
    String label,
  ) {
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 1.5,
      color: colorScheme.surface, // Use theme surface color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Fit content
          children: [
            Row(
              mainAxisSize: MainAxisSize.min, // Center row content horizontally
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  count.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface, // Use default text color
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant, // Subdued color for label
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Registered Events Section with Tabs
  Widget _buildRegisteredEventsSection(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    // Use the state lists (currently placeholders)
    List<Event> upcoming = _upcomingRegisteredEvents;
    List<Event> completed = _completedRegisteredEvents;

    return _buildDashboardCard(
      title: "Registered Events",
      icon: Icons.list_alt_outlined,
      theme: theme,
      padding: EdgeInsets.zero, // Remove default card padding
      child: Column(
        mainAxisSize: MainAxisSize.min, // Make column wrap content
        children: [
          // TabBar Container for styling
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer, // Tab bar background
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 2.5,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: theme.textTheme.bodyMedium,
              tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Completed')],
            ),
          ),
          // TabBarView
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 350, // Adjust this max height as needed for list view
            ),
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                // Upcoming Events List
                _buildEventList(
                  theme,
                  upcoming,
                  "No upcoming registered events.",
                ),
                // Completed Events List
                _buildEventList(
                  theme,
                  completed,
                  "No completed registered events.",
                ),
              ],
            ),
          ),
          // Optional "View All" Link
          if (upcoming.isNotEmpty ||
              completed.isNotEmpty) // Only show if there are events
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to a screen showing ALL registered events
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Navigate to All Events (Not Implemented)"),
                    ),
                  );
                },
                child: Text(
                  "View all registered events >",
                  style: TextStyle(color: colorScheme.primary, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper to build the event list for tabs (with animations and tuned chip colors)
  Widget _buildEventList(
    ThemeData theme,
    List<Event> events,
    String emptyMessage,
  ) {
    final colorScheme = theme.colorScheme;
    final bool isDarkMode = theme.brightness == Brightness.dark;

    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
          child: Text(
            emptyMessage,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }
    return AnimationLimiter(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        itemCount: events.length,
        shrinkWrap: true, // Important if inside ConstrainedBox or Column
        physics: const BouncingScrollPhysics(),
        separatorBuilder:
            (context, index) => const Divider(
              height: 1,
              thickness: 0.5,
              indent: 56,
              endIndent: 16,
            ),
        itemBuilder: (context, index) {
          final event = events[index];
          bool isUpcoming = event.eventDate.isAfter(DateTime.now());

          // Define chip colors based on status and theme brightness
          final Color upcomingChipBg =
              isDarkMode
                  ? Colors.green.shade900.withOpacity(0.5)
                  : Colors.green.shade100;
          final Color upcomingChipText =
              isDarkMode ? Colors.green.shade200 : Colors.green.shade800;
          final Color completedChipBg =
              isDarkMode
                  ? Colors.grey.shade800.withOpacity(0.7)
                  : Colors.grey.shade300;
          final Color completedChipText =
              isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        isUpcoming
                            ? colorScheme.primaryContainer.withOpacity(0.7)
                            : colorScheme.surfaceContainerHighest,
                    child: Icon(
                      isUpcoming
                          ? Icons.timer_outlined
                          : Icons.check_circle_outline,
                      size: 20,
                      color:
                          isUpcoming
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  title: Text(
                    event.eventName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    "${DateFormat.yMMMd().format(event.eventDate)} • ${event.department ?? 'University Event'}",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  trailing: Chip(
                    // Status indicator - Tuned Colors
                    label: Text(
                      isUpcoming ? 'Upcoming' : 'Completed',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color:
                            isUpcoming ? upcomingChipText : completedChipText,
                      ),
                    ),
                    backgroundColor:
                        isUpcoming ? upcomingChipBg : completedChipBg,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 0,
                    ),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 0,
                  ), // Reduce horizontal padding for more space
                  onTap:
                      () => context.pushNamed(
                        'eventDetail',
                        pathParameters: {
                          'eventId': event.id,
                        }, // Ensure event.id is valid
                        extra: event,
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 5. Events Calendar (Keep structure, link data source later)
  Widget _buildEventsCalendar(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return _buildDashboardCard(
      title: "Events Calendar",
      icon: Icons.calendar_month_outlined,
      theme: theme,
      padding: const EdgeInsets.fromLTRB(
        8,
        8,
        8,
        0,
      ), // No bottom padding inside card for calendar
      child: Column(
        mainAxisSize: MainAxisSize.min, // Make column wrap content
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.now().subtract(
              const Duration(days: 365),
            ), // Example range
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                if (mounted) {
                  // Check mount status before setState
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _loadEventsForSelectedDay(selectedDay);
                  });
                }
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                if (mounted) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              }
            },
            onPageChanged: (focusedDay) {
              // focusedDay is updated automatically, no setState needed unless reacting to page change
              _focusedDay = focusedDay;
            },
            eventLoader:
                _getEventsForDay, // IMPORTANT: This uses _calendarEvents
            // --- Calendar Styling using ColorScheme ---
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withOpacity(
                  0.5,
                ), // Subdued today highlight
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: colorScheme.onPrimary),
              todayTextStyle: TextStyle(
                color: colorScheme.onSecondaryContainer,
              ),
              defaultTextStyle: TextStyle(color: colorScheme.onSurface),
              weekendTextStyle: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              outsideTextStyle: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
              markerDecoration: BoxDecoration(
                // Use tertiary for event markers (yellow accent)
                color: colorScheme.tertiary,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1,
              cellMargin: const EdgeInsets.all(4.0), // Adjust cell margin
              canMarkersOverflow: false, // Prevent markers going outside cell
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              formatButtonTextStyle: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 12,
              ),
              formatButtonDecoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
              ),
              titleCentered: true,
              titleTextStyle:
                  theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600, // Bolder header title
                    color: colorScheme.onSurface, // Theme-aware title color
                  ) ??
                  const TextStyle(),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: colorScheme.primary,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: colorScheme.primary,
              ),
            ),
          ),
          // AnimatedSwitcher for displaying events of the selected day
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(sizeFactor: animation, child: child),
              ); // Combine Fade & Size
            },
            layoutBuilder: (currentChild, previousChildren) {
              // Default layout builder works well for simple fades/slides
              return Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            child:
                _selectedDayEvents.isEmpty
                    ? Padding(
                      // Use a key to help AnimatedSwitcher differentiate states
                      key: ValueKey(
                        'no_events_${_selectedDay?.toIso8601String()}',
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        _selectedDay == null
                            ? ""
                            : "No events scheduled for this day.",
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : Column(
                      // Use a key to help AnimatedSwitcher differentiate states
                      key: ValueKey(
                        'events_list_${_selectedDay?.toIso8601String()}',
                      ),
                      mainAxisSize:
                          MainAxisSize.min, // Important for Column height
                      children: [
                        const Divider(
                          height: 20,
                          thickness: 0.5,
                          indent: 16,
                          endIndent: 16,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Events on ${DateFormat.yMMMd().format(_selectedDay!)}:",
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Make this internal list scrollable if many events per day expected
                        ListView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(), // Disable scrolling if parent scrolls
                          itemCount: _selectedDayEvents.length,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ), // Padding for list items
                          itemBuilder: (context, index) {
                            final event = _selectedDayEvents[index];
                            return Padding(
                              // Add padding around each item
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: ListTile(
                                dense: true,
                                leading: Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: colorScheme.secondary,
                                ),
                                title: Text(
                                  event.eventName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  DateFormat.jm().format(event.eventDate),
                                ),
                                onTap:
                                    () => context.pushNamed(
                                      'eventDetail',
                                      pathParameters: {'eventId': event.id},
                                      extra: event,
                                    ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16), // Padding at the bottom
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  // --- Reusable Dashboard Card Widget ---
  Widget _buildDashboardCard({
    required String title,
    required Widget child,
    required ThemeData theme,
    IconData? icon,
    EdgeInsetsGeometry? padding,
  }) {
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 1.5, // Subtle elevation
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surface, // Use theme surface color for card background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Consistent radius
        // Optional: Add subtle border matching theme in dark mode
        side:
            theme.brightness == Brightness.dark
                ? BorderSide(
                  color: colorScheme.outlineVariant.withOpacity(0.3),
                  width: 0.5,
                )
                : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Make card wrap content vertically
        children: [
          // Card Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            // Use a slightly different background for the header for visual separation
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh.withOpacity(
                0.5,
              ), // Adjusted surface container color
              // Apply radius only to top corners to match card shape
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                if (icon != null)
                  Icon(icon, size: 20, color: colorScheme.primary),
                if (icon != null) const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          colorScheme
                              .onSurface, // Ensure good contrast on header bg
                    ),
                  ),
                ),
                // Can add optional actions here if needed (e.g., filter icon)
              ],
            ),
          ),
          // Card Content
          Padding(
            // Use provided padding or default. EdgeInsets.zero allows full control (used for events section)
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child, // The main content of the card
          ),
        ],
      ),
    );
  }
} // End of _StudentDashboardScreenState

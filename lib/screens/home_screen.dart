// lib/screens/home_screen.dart
// NOW WITH BOTTOM NAVIGATION BAR

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

// Import models and widgets
import '../models/event.dart';
import '../models/category.dart';
import '../widgets/event_card.dart';
import '../widgets/category_card.dart';
import '../widgets/notifications_tab.dart';
// Import the random event generator
import '../utils/random_event_generator.dart';
// Import main.dart to access themeNotifier
import '../main.dart';
// Import StudentDashboardScreen to potentially use for Profile tab
import 'student_dashboard_screen.dart'; // Import dashboard screen

// Make HomeScreen StatefulWidget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Logger log = Logger();

  // --- State for Bottom Navigation ---
  int _selectedIndex = 0; // Default to Home tab

  // --- State variables moved from build method ---
  late Future<List<Event>> _featuredEventsFuture;
  late Future<List<Event>> _upcomingEventsFuture;
  late Future<List<Event>> _festEventsFuture;
  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = true;
  String? _selectedQuickFilter;
  List<Event> _registeredPreviewEvents = [];
  final List<String> _quickFilters = [
    "All",
    "Today",
    "This Week",
    "Free",
    "Online",
    "Offline",
    "Workshop",
  ];
  final List<Category> _placeholderCategories = [
    Category(
      title: 'Academic',
      subtitle: 'Events',
      icon: Icons.school_outlined,
    ),
    Category(
      title: 'Cultural',
      subtitle: 'Events',
      icon: Icons.festival_outlined,
    ),
    Category(
      title: 'Technical',
      subtitle: 'Events',
      icon: Icons.computer_outlined,
    ),
    Category(
      title: 'Sports',
      subtitle: 'Events',
      icon: Icons.sports_soccer_outlined,
    ),
    Category(
      title: 'Workshops',
      subtitle: 'Events',
      icon: Icons.build_outlined,
    ),
    Category(
      title: 'Seminars',
      subtitle: 'Events',
      icon: Icons.record_voice_over_outlined,
    ),
    Category(
      title: 'Fest',
      subtitle: 'Campus Fests',
      icon: Icons.celebration_outlined,
    ),
  ];
  final Map<String, IconData> _eventIcons = {
    'academic': Icons.school_outlined,
    'cultural': Icons.palette_outlined,
    'technical': Icons.computer_outlined,
    'workshop': Icons.build_outlined,
    'seminar': Icons.record_voice_over_outlined,
    'sports': Icons.sports_soccer_outlined,
    'fest': Icons.celebration_outlined,
    'gala': Icons.celebration_outlined,
    'online': Icons.public_outlined,
    'paid': Icons.attach_money_outlined,
    'free': Icons.money_off_csred_outlined,
  };

  @override
  void initState() {
    super.initState();
    _selectedQuickFilter = _quickFilters.first;
    _loadInitialData(); // Load initial data needed for the Home tab content
  }

  Future<void> _loadInitialData() async {
    // Trigger both fetches, start event loading immediately
    _loadEvents();
    await _loadProfile(); // Wait for profile if needed by initial UI elements
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoadingProfile = true;
    });
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() => _isLoadingProfile = false);
      return;
    }

    try {
      final data =
          await Supabase.instance.client
              .from('profiles')
              .select('*, campus') // Ensure campus is selected
              .eq('user_id', userId)
              .maybeSingle(); // Use maybeSingle in case profile doesn't exist yet

      if (mounted) {
        setState(() {
          _userProfile = data;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      print("Error loading profile in HomeScreen: $e");
      if (mounted) {
        setState(() => _isLoadingProfile = false);
        // Optionally show a snackbar error
      }
    }
  }

  // --- Data Loading Logic (Remains the same) ---
  void _loadEvents() {
    log.i("Loading RANDOM event data for HomeScreen...");
    if (!mounted) return;

    // Generate fresh sets of random events
    final List<Event> featured = generateRandomEvents(5);
    final List<Event> upcoming = generateRandomEvents(15);
    final List<Event> fests =
        upcoming
            .where(
              (e) =>
                  e.tags?.any(
                    (t) =>
                        t.toLowerCase() == 'fest' || t.toLowerCase() == 'gala',
                  ) ??
                  false,
            )
            .toList();
    List<Event> preview = [];
    if (upcoming.isNotEmpty) {
      List<Event> upcomingOnlyForPreview =
          upcoming
              .where(
                (e) => e.eventDate.isAfter(
                  DateTime.now().subtract(const Duration(days: 1)),
                ),
              )
              .toList();
      upcomingOnlyForPreview.shuffle();
      preview = upcomingOnlyForPreview.take(2).toList();
    }

    // Use mounted check before setState if async operation might complete after dispose
    if (mounted) {
      setState(() {
        _featuredEventsFuture = Future.delayed(
          const Duration(milliseconds: 500),
          () => featured,
        );
        _upcomingEventsFuture = Future.delayed(
          const Duration(milliseconds: 700),
          () => upcoming,
        );
        _festEventsFuture = Future.delayed(
          const Duration(milliseconds: 600),
          () => fests,
        );
        _registeredPreviewEvents = preview;
      });
    }
    log.i("Loaded random events for futures and preview.");
  }

  // --- Navigation Item Tap Handler ---
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final currentMode = themeNotifier.value;
    final isCurrentlyDark =
        currentMode == ThemeMode.dark ||
        (currentMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    // --- Define Widgets for each Tab ---
    // Use IndexedStack to preserve state of each tab
    final List<Widget> widgetOptions = <Widget>[
      _buildHomeTabContent(context), // Index 0: Home
      _buildPlaceholderTab('My Events'), // Index 1: My Events
      const NotificationsTabFrontend(), // Index 2: Notifications (Moved)
      const StudentDashboardScreen(), // Index 3: Profile (Moved)
    ];

    return Scaffold(
      appBar: AppBar(
        // Simplified AppBar
        title: Text(
          _getAppBarTitle(_selectedIndex), // Title changes based on tab
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 1,
        shadowColor: colorScheme.shadow.withOpacity(0.2),
        actions: [
          // Keep theme toggle
          IconButton(
            icon: Icon(
              isCurrentlyDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              switch (themeNotifier.value) {
                case ThemeMode.system:
                  themeNotifier.value = ThemeMode.light;
                  break;
                case ThemeMode.light:
                  themeNotifier.value = ThemeMode.dark;
                  break;
                case ThemeMode.dark:
                  themeNotifier.value = ThemeMode.system;
                  break;
              }
              log.i("Theme mode changed to: ${themeNotifier.value}");
            },
          ),
          // Keep refresh if relevant for the current tab (e.g., Home)
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reload Events',
              onPressed: _loadEvents, // Reloads data for Home tab
            ),
          // Logout button moved (perhaps to Profile tab's AppBar or content)
        ],
      ),
      // Body now displays the widget based on selected index
      body: IndexedStack(
        // Use IndexedStack to keep tab state
        index: _selectedIndex,
        children: widgetOptions,
      ),
      // --- Add BottomNavigationBar ---
      bottomNavigationBar: BottomNavigationBar(
        // UPDATED ORDER: Home, My Events, Notifications, Profile
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'My Events',
          ),
          // --- Notifications Moved to Index 2 ---
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          // --- Profile Moved to Index 3 ---
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant.withOpacity(0.7),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surfaceContainer,
        elevation: 3.0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        showUnselectedLabels: true,
      ),
    );
  }

  // --- Helper to get AppBar Title based on Index ---
  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'SOCIO.'; // Or 'Home'
      case 1:
        return 'My Events';
      // --- UPDATED Indices ---
      case 2:
        return 'Notifications'; // Was Profile
      case 3:
        return 'Profile'; // Was Notifications
      default:
        return 'SOCIO.';
    }
  }

  // --- Helper to build placeholder content for new tabs ---
  Widget _buildPlaceholderTab(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 50, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(
            '$title Tab',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const Text(
            '(Content coming soon)',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // --- Extracted Content for the Home Tab (Index 0) ---
  Widget _buildHomeTabContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Get user name and campus from the fetched profile state
    // Provide defaults while loading or if data is missing
    final String userName =
        (_userProfile?['full_name'] ?? 'Student').toString();
    final String campusName = (_userProfile?['campus'] ?? '').toString();

    // Display a simple loading indicator if the profile is still loading
    if (_isLoadingProfile) {
      return const Center(child: CircularProgressIndicator());
    }

    // Build the main content once profile is loaded (or loading finished)
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh both events and profile on pull-to-refresh
        await _loadInitialData();
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 16.0),
        children: [
          // --- Welcome Header with Campus ---
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: 8.0,
            ),
            child: Row(
              // Use Row to display name and campus
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic, // Aligns text nicely
              children: [
                Flexible(
                  // Allow name to wrap if needed
                  child: Text(
                    "Hi, $userName!", // Display fetched name
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis, // Handle long names
                  ),
                ),
                if (campusName.isNotEmpty) // Show campus tag only if available
                  Row(
                    mainAxisSize: MainAxisSize.min, // Keep Row compact
                    children: [
                      Icon(
                        Icons.location_pin,
                        size: 16,
                        color: colorScheme.secondary,
                      ), // Location icon
                      const SizedBox(width: 4),
                      Text(
                        campusName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.secondary,
                        ), // Style for campus
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // --- End Welcome Header ---

          // Search Bar Placeholder
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerLowest,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onTap:
                  () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Search functionality not implemented (Demo).",
                      ),
                    ),
                  ),
            ),
          ),
          // Quick Filter Chips
          _buildQuickFilters(), // Uses state variable _selectedQuickFilter
          const SizedBox(height: 16),

          // My Registrations Preview
          if (_registeredPreviewEvents.isNotEmpty) ...[
            // Uses state variable _registeredPreviewEvents
            _buildMyRegistrationsPreview(),
            const SizedBox(height: 24),
          ],

          // Featured Events
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSectionHeader(
              "Featured events",
              showViewAll: false,
              context: context,
            ),
          ),
          FutureBuilder<List<Event>>(
            future: _featuredEventsFuture, // Uses state variable
            builder:
                (context, snapshot) =>
                    _buildEventListFromSnapshot(snapshot, isHorizontal: true),
          ),
          const SizedBox(height: 24),

          // Upcoming Fests
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSectionHeader(
              "Upcoming Fests",
              onViewAllTap:
                  () => context.pushNamed(
                    'publicDiscover',
                    queryParameters: {'category': 'Fest'},
                  ),
              context: context,
            ),
          ),
          FutureBuilder<List<Event>>(
            future: _festEventsFuture, // Uses state variable
            builder:
                (context, snapshot) =>
                    _buildEventListFromSnapshot(snapshot, isHorizontal: true),
          ),
          const SizedBox(height: 24),

          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSectionHeader(
              "Browse by category",
              onViewAllTap: () => context.pushNamed('publicDiscover'),
              context: context,
            ),
          ),
          _buildCategoryGrid(
            _placeholderCategories,
          ), // Uses constant _placeholderCategories
          const SizedBox(height: 24),

          // Upcoming Events
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSectionHeader(
              "Upcoming events",
              onViewAllTap: () => context.pushNamed('publicDiscover'),
              context: context,
            ),
          ),
          FutureBuilder<List<Event>>(
            future: _upcomingEventsFuture, // Uses state variable
            builder:
                (context, snapshot) => _buildGroupedVerticalEventList(snapshot),
          ),
          const SizedBox(height: 30), // Bottom padding
        ],
      ),
    );
  }

  // --- All the helper methods (_buildQuickFilters, _buildMyRegistrationsPreview, etc.) should be moved here ---
  // --- Make sure they use instance variables like _selectedQuickFilter, _registeredPreviewEvents, etc. ---

  // Builds the static quick filter chips row (Uses Theme Colors)
  Widget _buildQuickFilters() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              _quickFilters.map((filter) {
                final bool isSelected = _selectedQuickFilter == filter;
                final theme = Theme.of(context);
                final colorScheme = theme.colorScheme;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        // Ensure setState is called here
                        _selectedQuickFilter = selected ? filter : null;
                      });
                      log.i("Quick Filter tapped: $filter (Visual Only)");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Filter '$filter' tapped (Visual Demo).",
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    showCheckmark: false,
                    selectedColor: colorScheme.primaryContainer.withOpacity(
                      0.6,
                    ),
                    backgroundColor: colorScheme.surfaceContainerLowest,
                    labelStyle: TextStyle(
                      color:
                          isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color:
                          isSelected
                              ? colorScheme.primary.withOpacity(0.5)
                              : colorScheme.outline.withOpacity(0.5),
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 0,
                    ),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  // Builds the "My Registrations" preview section (Uses Theme Colors)
  Widget _buildMyRegistrationsPreview() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 1.5,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your Upcoming Events",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed:
                        () => _onItemTapped(1), // Navigate to My Events tab
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      foregroundColor: colorScheme.primary,
                    ),
                    child: const Text("View All"),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_registeredPreviewEvents.isEmpty)
                Text(
                  "Loading preview...",
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ..._registeredPreviewEvents.map(
                (event) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: colorScheme.secondaryContainer.withOpacity(
                      0.5,
                    ),
                    child: Icon(
                      _getIconForEvent(event) ?? Icons.event_note_outlined,
                      size: 18,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  title: Text(
                    event.eventName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    DateFormat('MMM d, h:mm a').format(event.eventDate),
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  onTap: () {
                    if (event.id.isNotEmpty) {
                      context.pushNamed(
                        'eventDetail',
                        pathParameters: {'eventId': event.id},
                        extra: event,
                      );
                    } else {
                      log.e("Cannot navigate preview: Event ID empty");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Error: Invalid event ID."),
                          backgroundColor: colorScheme.error,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds event lists from snapshot
  Widget _buildEventListFromSnapshot(
    AsyncSnapshot<List<Event>> snapshot, {
    required bool isHorizontal,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return isHorizontal
          ? _buildHorizontalLoadingPlaceholder()
          : _buildVerticalLoadingPlaceholder();
    } else if (snapshot.hasError) {
      log.e("Error building event list snapshot: ${snapshot.error}");
      return _buildErrorWidget("Could not display events.");
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return _buildEmptyWidget(
        isHorizontal ? "No events found." : "No upcoming events found.",
      );
    } else {
      return isHorizontal
          ? _buildHorizontalEventList(snapshot.data!, context)
          : _buildVerticalEventListWithIcons(snapshot.data!);
    }
  }

  // Builds horizontal SHIMMER placeholders
  Widget _buildHorizontalLoadingPlaceholder() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: 3,
        itemBuilder:
            (context, index) => Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: _buildPlaceholderEventCard(context),
            ),
      ),
    );
  }

  // Builds vertical SHIMMER placeholders
  Widget _buildVerticalLoadingPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildPlaceholderEventCard(context),
          ),
        ),
      ),
    );
  }

  // Defines a single SHIMMER placeholder card (Uses Theme Colors) - CORRECTED
  Widget _buildPlaceholderEventCard(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor =
        (theme.brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[300]) ??
        Colors.grey[300]!;
    final highlightColor =
        (theme.brightness == Brightness.dark
            ? Colors.grey[700]
            : Colors.grey[100]) ??
        Colors.grey[100]!;
    final containerColor =
        theme.brightness == Brightness.dark
            ? ((Colors.grey[750]) ?? Colors.grey[800]!)
            : Colors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: theme.cardColor,
        child: SizedBox(
          width: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                color: containerColor,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 10,
                      width: 80,
                      color: containerColor,
                      margin: const EdgeInsets.only(bottom: 8),
                    ),
                    Container(
                      height: 12,
                      width: 200,
                      color: containerColor,
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    Container(
                      height: 10,
                      width: 150,
                      color: containerColor,
                      margin: const EdgeInsets.only(bottom: 4),
                    ),
                    Container(height: 10, width: 180, color: containerColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for error state (Uses Theme Colors)
  Widget _buildErrorWidget(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 30),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Widget for empty state (Uses Theme Colors)
  Widget _buildEmptyWidget(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Builds the section header (Uses Theme Colors)
  Widget _buildSectionHeader(
    String title, {
    bool showViewAll = true,
    VoidCallback? onViewAllTap,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showViewAll && onViewAllTap != null)
            TextButton(
              onPressed: onViewAllTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                foregroundColor: colorScheme.primary,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("View all"),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Builds the horizontal event list (Uses Theme Colors)
  Widget _buildHorizontalEventList(List<Event> events, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final currentEvent = events[index];
          final iconData = _getIconForEvent(currentEvent);
          return Padding(
            padding: EdgeInsets.only(
              right: index == events.length - 1 ? 0 : 12.0,
            ),
            child: EventCard(
              event: currentEvent,
              leadingIconData: iconData,
              leadingIconColor: colorScheme.secondary,
              onTap: () {
                if (currentEvent.id.isNotEmpty) {
                  context.pushNamed(
                    'eventDetail',
                    pathParameters: {'eventId': currentEvent.id},
                    extra: currentEvent,
                  );
                } else {
                  log.e(
                    "Nav Error: Event ID empty for ${currentEvent.eventName}",
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Error: Invalid event ID."),
                      backgroundColor: colorScheme.error,
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  // Builds the category grid (Uses Theme Colors)
  Widget _buildCategoryGrid(List<Category> categories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 1.0,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          categoryData: category,
          onTap: () => _handleCategoryTap(category),
        );
      },
    );
  }

  // Builds vertical event list with icons (Non-Grouped - Uses Theme Colors)
  Widget _buildVerticalEventListWithIcons(List<Event> events) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children:
            events.map((currentEvent) {
              final iconData = _getIconForEvent(currentEvent);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: EventCard(
                  event: currentEvent,
                  leadingIconData: iconData,
                  leadingIconColor: colorScheme.secondary,
                  onTap: () {
                    if (currentEvent.id.isNotEmpty) {
                      context.pushNamed(
                        'eventDetail',
                        pathParameters: {'eventId': currentEvent.id},
                        extra: currentEvent,
                      );
                    } else {
                      log.e(
                        "Nav Error: Event ID empty for ${currentEvent.eventName}",
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Error: Invalid event ID."),
                          backgroundColor: colorScheme.error,
                        ),
                      );
                    }
                  },
                ),
              );
            }).toList(),
      ),
    );
  }

  // Builds grouped vertical event list (Uses Theme Colors)
  Widget _buildGroupedVerticalEventList(AsyncSnapshot<List<Event>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildVerticalLoadingPlaceholder();
    }
    if (snapshot.hasError) {
      log.e("Error building grouped event list: ${snapshot.error}");
      return _buildErrorWidget("Could not load upcoming events.");
    }
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return _buildEmptyWidget("No upcoming events found.");
    }

    final events = snapshot.data!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    events.sort((a, b) => a.eventDate.compareTo(b.eventDate));

    final Map<String, List<Event>> groupedEvents = {};
    for (var event in events) {
      final group = _getDateGroup(event.eventDate);
      if (groupedEvents[group] == null) groupedEvents[group] = [];
      groupedEvents[group]!.add(event);
    }

    final groupOrder = ["Today", "Tomorrow", "This Week", "Upcoming", "Past"];
    List<Widget> listItems = [];
    if (groupedEvents.isEmpty) {
      return _buildEmptyWidget("No upcoming events found.");
    }

    for (String groupKey in groupOrder) {
      final eventsInGroup = groupedEvents[groupKey];
      if (eventsInGroup != null && eventsInGroup.isNotEmpty) {
        listItems.add(
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 8.0,
              left: 16.0,
              right: 16.0,
            ),
            child: Text(
              groupKey.startsWith("This Week") ? "This Week" : groupKey,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        for (var event in eventsInGroup) {
          final iconData = _getIconForEvent(event);
          listItems.add(
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16.0,
                left: 16.0,
                right: 16.0,
              ),
              child: EventCard(
                event: event,
                leadingIconData: iconData,
                leadingIconColor: colorScheme.secondary,
                onTap: () {
                  if (event.id.isNotEmpty) {
                    context.pushNamed(
                      'eventDetail',
                      pathParameters: {'eventId': event.id},
                      extra: event,
                    );
                  } else {
                    log.e(
                      "Cannot navigate: Event ID empty for ${event.eventName}",
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Error: Invalid event ID."),
                        backgroundColor: colorScheme.error,
                      ),
                    );
                  }
                },
              ),
            ),
          );
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listItems,
    );
  }

  // --- Helper methods for grouping, icons etc. (Keep as is) ---
  String _getDateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final eventDateOnly = DateTime(date.year, date.month, date.day);

    if (eventDateOnly.isAtSameMomentAs(today)) return 'Today';
    if (eventDateOnly.isAtSameMomentAs(tomorrow)) return 'Tomorrow';
    if (eventDateOnly.isAfter(tomorrow) &&
        eventDateOnly.isBefore(today.add(const Duration(days: 7)))) {
      return 'This Week (${DateFormat('EEEE').format(eventDateOnly)})';
    }
    if (eventDateOnly.isAfter(today)) {
      return 'Upcoming (${DateFormat('MMM d').format(eventDateOnly)})';
    }
    return 'Past (${DateFormat('MMM d').format(eventDateOnly)})';
  }

  IconData? _getIconForEvent(Event event) {
    if (event.tags == null) return Icons.event_note_outlined;
    for (String tag in event.tags!) {
      final lowerTag = tag.toLowerCase();
      if (_eventIcons.containsKey(lowerTag)) return _eventIcons[lowerTag];
    }
    return Icons.event_note_outlined;
  }

  void _handleCategoryTap(Category category) {
    log.i("Category tapped: ${category.title}");
    context.pushNamed(
      'publicDiscover',
      queryParameters: {'category': category.title},
    );
  }
} // End of _HomeScreenState

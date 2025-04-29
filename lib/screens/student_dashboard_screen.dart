// lib/screens/student_dashboard_screen.dart
// UI Revamp - Frontend Focus + Generated Data + Interactivity

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // Import Random

// Import the random event generator to potentially reuse for timeline
import '../utils/random_event_generator.dart';
import '../models/event.dart'; // Import Event model

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;

  // Calendar state
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // --- State Variables for Generated Data ---
  List<Map<String, dynamic>> _generatedBatches = [];
  List<Map<String, dynamic>> _generatedTimeline = [];
  List<Map<String, dynamic>> _generatedAnnouncements = [];
  List<Event> _calendarEvents = []; // Store all generated events for calendar

  // --- State for Interactivity ---
  List<Event> _selectedDayEvents = []; // Events for the selected calendar day

  final Random _random = Random(); // Random instance

  @override
  void initState() {
    super.initState();
    _fetchProfileAndGenerateData(); // Fetch profile and then generate UI data
    _selectedDay = _focusedDay;
    // Initially load events for the default selected day (today)
    _loadEventsForSelectedDay(_selectedDay!);
  }

  // --- Data Generation Functions ---

  List<Map<String, dynamic>> _generateRandomBatches(int count) {
    // ... (implementation remains the same)
    final List<Map<String, dynamic>> batches = [];
    final icons = [
      Icons.wb_sunny_outlined,
      Icons.computer_outlined,
      Icons.music_note_outlined,
      Icons.campaign_outlined,
      Icons.camera_alt_outlined,
      Icons.science_outlined,
      Icons.edit_note_outlined,
      Icons.sports_basketball_outlined,
    ];
    final names = [
      'Tech Innovators',
      'Creative Coders',
      'Music Maestros',
      'Debate Club',
      'Shutterbugs',
      'Science Geeks',
      'Writers Guild',
      'Sports Enthusiasts',
      'Morning Study Group',
      'Evening Project Team',
    ];
    names.shuffle(_random);
    for (int i = 0; i < min(count, names.length); i++) {
      batches.add({
        'name': names[i],
        'icon': icons[_random.nextInt(icons.length)],
      });
    }
    return batches;
  }

  List<Map<String, dynamic>> _generateRandomTimeline(int count) {
    // ... (implementation remains the same)
    List<Event> randomEvents = generateRandomEvents(count);
    randomEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return randomEvents.map((event) {
      String title = event.eventName;
      if (title.length > 30) {
        title = "${title.substring(0, 27)}...";
      }
      final colors = [
        Colors.orangeAccent[700],
        Colors.blueAccent[700],
        Colors.green[600],
        Colors.redAccent[700],
        Colors.purple[400],
        Colors.teal[400],
      ];
      final color = colors[_random.nextInt(colors.length)];
      IconData icon = Icons.event_note_outlined;
      if (event.tags != null) {
        if (event.tags!.contains("Workshop")) {
          icon = Icons.build_outlined;
        } else if (event.tags!.contains("Seminar") ||
            event.tags!.contains("Lecture"))
          icon = Icons.school_outlined;
        else if (event.tags!.contains("Competition"))
          icon = Icons.emoji_events_outlined;
        else if (event.tags!.contains("Deadline"))
          icon = Icons.assignment_late_outlined;
        else if (event.tags!.contains("Quiz"))
          icon = Icons.quiz_outlined;
      }
      return {
        'title': title,
        'date': DateFormat('MMM dd').format(event.eventDate),
        'time': DateFormat('hh:mm a').format(event.eventDate),
        'icon': icon,
        'color': color,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _generateRandomAnnouncements(int count) {
    // ... (implementation remains the same)
    final List<Map<String, dynamic>> announcements = [];
    final icons = [
      Icons.warning_amber_rounded,
      Icons.info_outline,
      Icons.event_note,
      Icons.campaign_outlined,
      Icons.celebration_outlined,
      Icons.school_outlined,
    ];
    final colors = [
      Colors.redAccent[700],
      Colors.blueAccent[700],
      Colors.green[600],
      Colors.orangeAccent[700],
      Colors.purple[400],
      Colors.teal[400],
    ];
    final texts = [
      "Exam schedules for Semester 4 released. Check notice board.",
      "Library timings extended during exam period.",
      "Registrations open for the Annual Tech Fest 'Innovate 2025'.",
      "Guest lecture on 'AI in Healthcare' scheduled for next Friday.",
      "Cultural Fest 'Spectrum' postponed due to unforeseen circumstances.",
      "Submit project proposals by the end of this week.",
      "Maintenance work in Hostel Block C scheduled for Saturday.",
      "Results for the coding competition are out.",
      "Blood donation camp organized by NSS next Tuesday.",
    ];
    texts.shuffle(_random);
    for (int i = 0; i < min(count, texts.length); i++) {
      announcements.add({
        'text': texts[i],
        'icon': icons[_random.nextInt(icons.length)],
        'color': colors[_random.nextInt(colors.length)],
      });
    }
    return announcements;
  }

  // Generates events specifically for marking the calendar AND for selection display
  List<Event> _generateEventsForCalendar(int count) {
    // Generate events around the current month for relevance
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

  // --- Fetch Profile and Generate Placeholder Data ---
  Future<void> _fetchProfileAndGenerateData() async {
    setState(() {
      _isLoading = true;
    });
    final userId = _supabase.auth.currentUser?.id;
    Map<String, dynamic>? fetchedProfile;

    // Generate UI data first so it's available even if profile fetch fails
    _generateUIData();

    if (userId == null) {
      if (mounted) context.goNamed('login');
      setState(() {
        _isLoading = false;
      });
      // Load events for today initially even if not logged in
      _loadEventsForSelectedDay(DateTime.now());
      return;
    }

    try {
      // Make sure 'campus' is selected if not using select()
      fetchedProfile =
          await _supabase
              .from('profiles')
              .select('*, campus') // Explicitly select campus if needed
              .eq('user_id', userId)
              .single();
      // ...
    } catch (e) {
      print("Error fetching dashboard profile data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error loading profile data: ${e.toString()}",
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _profileData = fetchedProfile;
          _isLoading = false;
          // Load events for the initially selected day after data generation
          _loadEventsForSelectedDay(_selectedDay ?? DateTime.now());
        });
      }
    }
  }

  // Helper to generate all UI data
  void _generateUIData() {
    _generatedBatches = _generateRandomBatches(5);
    _generatedTimeline = _generateRandomTimeline(4);
    _generatedAnnouncements = _generateRandomAnnouncements(4);
    // Generate a larger pool of events for calendar interactions
    _calendarEvents = _generateEventsForCalendar(50);
  }

  // --- Calendar Event Loader & Selection Handler ---
  // Returns a list of events associated with a specific day for calendar markers
  List<Event> _getEventsForDay(DateTime day) {
    // Filter the stored _calendarEvents list
    return _calendarEvents
        .where((event) => isSameDay(event.eventDate, day))
        .toList();
  }

  // Updates the state with events for the newly selected day
  void _loadEventsForSelectedDay(DateTime day) {
    setState(() {
      _selectedDayEvents = _getEventsForDay(day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
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
            onPressed: _fetchProfileAndGenerateData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await _supabase.auth.signOut();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                builder: (context, constraints) {
                  bool useColumns = constraints.maxWidth < 900;
                  return SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child:
                          useColumns
                              ? _buildStackedLayout(theme)
                              : _buildSideBySideLayout(theme),
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
              "Could not load profile data.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchProfileAndGenerateData,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  // --- Layout Builders ---
  Widget _buildSideBySideLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildLeftColumn(theme)),
        const SizedBox(width: 24),
        Expanded(flex: 4, child: _buildRightColumn(theme)),
      ],
    );
  }

  Widget _buildStackedLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLeftColumn(theme),
        const SizedBox(height: 24),
        _buildRightColumn(theme),
      ],
    );
  }

  // --- Column Widgets ---
  Widget _buildLeftColumn(ThemeData theme) {
    return Column(
      children: [
        _buildUserInfoCard(theme),
        const SizedBox(height: 20),
        _buildBatchesSection(theme),
        const SizedBox(height: 20),
        _buildTimelineSection(theme),
      ],
    );
  }

  Widget _buildRightColumn(ThemeData theme) {
    return Column(
      children: [
        _buildEventsCalendar(theme),
        const SizedBox(height: 20),
        _buildAnnouncements(theme),
        const SizedBox(height: 20),
        _buildReportButtons(theme),
      ],
    );
  }

  // --- Section Widgets (Modified for Interactivity) ---

  // User Info Card - Uses _profileData (fetched)
  Widget _buildUserInfoCard(ThemeData theme) {
    /* ... Keep implementation ... */
    final colorScheme = theme.colorScheme;
    String? avatarUrl = _profileData?['avatar_url']?.toString();
    String name = (_profileData?['full_name'] ?? 'Student Name').toString();
    String regNo = (_profileData?['register_no'] ?? 'RegNo: N/A').toString();
    String dept = (_profileData?['department'] ?? 'Department: N/A').toString();
    String campus = (_profileData?['campus'] ?? 'Campus: N/A').toString();

    const double avatarRadius = 60;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: colorScheme.secondaryContainer,
              backgroundImage:
                  (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? NetworkImage(avatarUrl)
                      : null,
              child:
                  (avatarUrl == null || avatarUrl.isEmpty)
                      ? Icon(
                        Icons.person_outline,
                        size: avatarRadius,
                        color: colorScheme.onSecondaryContainer,
                      )
                      : null,
            ),
            const SizedBox(height: 18),
            Text(
              name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Wrap(
              // Use Wrap for better wrapping on small screens
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8.0, // Horizontal space between items
              runSpacing: 4.0, // Vertical space if items wrap
              children: [
                if (regNo != 'RegNo: N/A')
                  Text(
                    regNo,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                if (dept != 'Dept: N/A') ...[
                  if (regNo !=
                      'RegNo: N/A') // Show separator only if previous item exists
                    Icon(Icons.circle, size: 6, color: colorScheme.outline),
                  Text(
                    dept,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],

                if (campus != 'Campus: N/A') ...[
                  // <-- DISPLAY Campus
                  if (regNo != 'RegNo: N/A' ||
                      dept !=
                          'Dept: N/A') // Show separator only if previous item exists
                    Icon(Icons.circle, size: 6, color: colorScheme.outline),
                  Row(
                    // Icon and Text for Campus
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_city_outlined,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ), // Campus Icon
                      const SizedBox(width: 4),
                      Text(
                        campus,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () => context.pushNamed('profileEdit'),
            ),
          ],
        ),
      ),
    );
  }

  // Batches Section - Uses _generatedBatches - NOW TAPPABLE
  Widget _buildBatchesSection(ThemeData theme) {
    if (_generatedBatches.isEmpty) {
      return _buildDashboardCard(
        title: "My Batches / Clubs",
        icon: Icons.group_work_outlined,
        theme: theme,
        child: const Text(
          "No batches or clubs found.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return _buildDashboardCard(
      title: "My Batches / Clubs",
      icon: Icons.group_work_outlined,
      theme: theme,
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        alignment: WrapAlignment.start,
        children:
            _generatedBatches.map((batch) {
              // Use ActionChip for built-in onPressed
              return ActionChip(
                avatar: Icon(
                  batch['icon'],
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                label: Text(batch['name'], style: theme.textTheme.labelMedium),
                backgroundColor: theme.colorScheme.secondaryContainer
                    .withOpacity(0.4),
                side: BorderSide(color: theme.colorScheme.secondaryContainer),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                pressElevation: 2.0, // Elevation on press
                onPressed: () {
                  // --- INTERACTION ---
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Tapped on '${batch['name']}' (Demo Action)",
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
      ),
    );
  }

  // Timeline Section - Uses _generatedTimeline
  Widget _buildTimelineSection(ThemeData theme) {
    /* ... Keep previous implementation ... */
    if (_generatedTimeline.isEmpty) {
      return _buildDashboardCard(
        title: "Upcoming Deadlines",
        icon: Icons.timeline_outlined,
        theme: theme,
        child: const Text(
          "No upcoming deadlines.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return _buildDashboardCard(
      title: "Upcoming Deadlines",
      icon: Icons.timeline_outlined,
      theme: theme,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _generatedTimeline.length,
        itemBuilder: (context, index) {
          final item = _generatedTimeline[index];
          final itemColor =
              item['color'] as Color? ?? theme.colorScheme.secondary;
          return ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: itemColor.withOpacity(0.15),
              child: Icon(
                item['icon'] as IconData? ?? Icons.event,
                size: 20,
                color: itemColor,
              ),
            ),
            title: Text(
              item['title'] as String? ?? 'Event',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              "${item['date']} at ${item['time']}",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
            dense: false,
          );
        },
        separatorBuilder:
            (context, index) =>
                const Divider(height: 1, thickness: 0.5, indent: 60),
      ),
    );
  }

  // Events Calendar Section - Shows selected day's events below
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
        // Wrap Calendar and event list in a Column
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _loadEventsForSelectedDay(
                    selectedDay,
                  ); // --- INTERACTION --- Load events for the tapped day
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              /* ... Keep styling ... */ todayDecoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
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
                color: colorScheme.tertiary,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1,
            ),
            headerStyle: HeaderStyle(
              /* ... Keep styling ... */ formatButtonVisible: true,
              formatButtonTextStyle: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 12,
              ),
              formatButtonDecoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
              ),
              titleCentered: true,
              titleTextStyle: theme.textTheme.titleMedium ?? const TextStyle(),
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
          // --- INTERACTION: Display Events for Selected Day ---
          if (_selectedDayEvents.isNotEmpty) ...[
            const Divider(height: 20, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Events on ${DateFormat.yMMMd().format(_selectedDay!)}:",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedDayEvents.length,
              itemBuilder: (context, index) {
                final event = _selectedDayEvents[index];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.event,
                    color: theme.colorScheme.secondary,
                    size: 18,
                  ),
                  title: Text(
                    event.eventName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    DateFormat.jm().format(event.eventDate),
                  ), // Show time
                  onTap:
                      () => context.pushNamed(
                        'eventDetail',
                        pathParameters: {'eventId': event.id},
                        extra: event,
                      ), // Navigate to detail
                );
              },
            ),
            const SizedBox(height: 16), // Padding at the bottom
          ] else if (_selectedDay != null) ...[
            // Show message if a day is selected but has no events
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Center(
                child: Text(
                  "No events scheduled for this day.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
          // --- End Selected Day Events ---
        ],
      ),
    );
  }

  // Announcements Section - Uses _generatedAnnouncements - NOW TAPPABLE
  Widget _buildAnnouncements(ThemeData theme) {
    if (_generatedAnnouncements.isEmpty) {
      return _buildDashboardCard(
        title: "Important Announcements",
        icon: Icons.campaign_outlined,
        theme: theme,
        child: const Text(
          "No announcements available.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return _buildDashboardCard(
      title: "Important Announcements",
      icon: Icons.campaign_outlined,
      theme: theme,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _generatedAnnouncements.length,
        itemBuilder: (context, index) {
          final item = _generatedAnnouncements[index];
          final itemColor =
              item['color'] as Color? ?? theme.colorScheme.secondary;
          return ListTile(
            leading: Icon(
              item['icon'] as IconData? ?? Icons.info_outline,
              color: itemColor,
              size: 24,
            ),
            title: Text(
              item['text'] as String? ?? 'Announcement',
              style: theme.textTheme.bodyLarge,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 6.0),
            dense: false,
            onTap: () {
              // --- INTERACTION ---
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text("Announcement"),
                      content: Text(item['text'] as String? ?? 'No details.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
              );
            },
          );
        },
        separatorBuilder:
            (context, index) =>
                const Divider(height: 1, thickness: 0.5, indent: 50),
      ),
    );
  }

  // Report Buttons Section (Keep as is - visual only)
  Widget _buildReportButtons(ThemeData theme) {
    /* ... Keep implementation ... */
    final colorScheme = theme.colorScheme;
    return _buildDashboardCard(
      title: "Reports",
      icon: Icons.assessment_outlined,
      theme: theme,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.event_available_outlined, size: 18),
            label: const Text("Participation"),
            style: ElevatedButton.styleFrom(
              foregroundColor: colorScheme.onSecondaryContainer,
              backgroundColor: colorScheme.secondaryContainer.withOpacity(0.7),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              print("Participation Report Tapped");
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.summarize_outlined, size: 18),
            label: const Text("Summary"),
            style: ElevatedButton.styleFrom(
              foregroundColor: colorScheme.onSecondaryContainer,
              backgroundColor: colorScheme.secondaryContainer.withOpacity(0.7),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              print("Yearly Report Tapped");
            },
          ),
        ],
      ),
    );
  }

  // --- Reusable Dashboard Card Widget (Keep as is) ---
  Widget _buildDashboardCard({
    required String title,
    required Widget child,
    required ThemeData theme,
    IconData? icon,
    EdgeInsetsGeometry? padding,
  }) {
    /* ... Keep implementation ... */
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            color: colorScheme.surfaceContainer.withOpacity(0.5),
            child: Row(
              children: [
                if (icon != null)
                  Icon(icon, size: 20, color: colorScheme.primary),
                if (icon != null) const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: padding ?? const EdgeInsets.all(16.0), child: child),
        ],
      ),
    );
  }
} // End of _StudentDashboardScreenState

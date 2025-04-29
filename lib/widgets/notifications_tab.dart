// lib/widgets/notifications_tab.dart

import 'dart:math'; // For Random

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // For navigation
import 'package:intl/intl.dart'; // For date formatting
import 'package:logger/logger.dart'; // For logging

// Import necessary models and utils
import '../models/event.dart';
import '../utils/random_event_generator.dart'; // For frontend data

// StatefulWidget for Notifications Tab (FRONTEND-ONLY VERSION)
class NotificationsTabFrontend extends StatefulWidget {
  const NotificationsTabFrontend({super.key});

  @override
  State<NotificationsTabFrontend> createState() =>
      _NotificationsTabFrontendState();
}

class _NotificationsTabFrontendState extends State<NotificationsTabFrontend> {
  // No SupabaseService needed
  final Logger log = Logger();
  List<Event> _notifications = []; // Store the generated notifications directly
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // Simulates loading and generates notifications
  void _loadNotifications() {
    log.i("NotificationsTabFrontend: Generating frontend notifications...");
    // Ensure widget is mounted before starting async operation setState
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 400), () {
      // Step 1: Generate a pool of random events
      final allEvents = generateRandomEvents(
        30,
      ); // Generate 30 potential events

      // Step 2: Simulate 'registration' - randomly pick some events
      final random = Random();
      final registeredEvents =
          allEvents.where((_) => random.nextBool()).toList();
      log.i(
        "NotificationsTabFrontend: Simulated registration for ${registeredEvents.length} events.",
      );

      // Step 3: Filter 'registered' events for the next 10 days
      final now = DateTime.now();
      final startDate = DateTime(
        now.year,
        now.month,
        now.day,
      ); // Start of today
      final endDate = startDate.add(
        const Duration(days: 11),
      ); // Start of the day *after* 10 days

      final upcomingRegistered =
          registeredEvents.where((event) {
            final eventDate = event.eventDate;
            // Ensure eventDate is not null before comparison
            return eventDate.isAfter(
                  startDate.subtract(const Duration(microseconds: 1)),
                ) && // >= Start of today
                eventDate.isBefore(endDate); // < Start of day 11
          }).toList();

      // Step 4: Sort by date
      upcomingRegistered.sort((a, b) => a.eventDate.compareTo(b.eventDate));

      log.i(
        "NotificationsTabFrontend: Found ${upcomingRegistered.length} upcoming 'registered' events.",
      );

      // Update state only if the widget is still mounted
      if (mounted) {
        setState(() {
          _notifications = upcomingRegistered;
          _isLoading = false;
        });
      }
    });
  }

  // Helper to calculate days left or return formatted date
  String _formatEventTime(DateTime eventDate, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
    final difference = eventDay.difference(today).inDays;

    if (difference == 0) {
      return 'Today at ${DateFormat.jm().format(eventDate)}';
    } else if (difference == 1) {
      return 'Tomorrow at ${DateFormat.jm().format(eventDate)}';
    } else if (difference > 1 && difference <= 10) {
      String dayFormat = (difference < 7) ? 'EEEE' : 'MMM d';
      // Corrected logic for 'In X days' phrasing might be complex, using 'On X' is clearer
      return 'On ${DateFormat(dayFormat).format(eventDate)} (${difference} ${difference == 1 ? 'day' : 'days'} left)';
    } else {
      // Fallback for events more than 10 days away (shouldn't happen with current filter)
      return DateFormat('MMM d, yyyy').format(eventDate);
    }
  }

  // Helper to get icon
  IconData? _getIconForEvent(Event event) {
    // Can keep the map here or move it to a central utility file
    final Map<String, IconData> eventIcons = {
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
    if (event.tags == null) return Icons.event_note_outlined;
    for (String tag in event.tags!) {
      final lowerTag = tag.toLowerCase();
      if (eventIcons.containsKey(lowerTag)) return eventIcons[lowerTag];
    }
    return Icons.event_note_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: 50,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 10),
              Text(
                "No upcoming event notifications",
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                "Simulated events you 'registered' for within 10 days would appear here.",
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                // Added refresh button for demo
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Generate Again"),
                onPressed: _loadNotifications,
              ),
            ],
          ),
        ),
      );
    }

    // Display the list of notifications
    return RefreshIndicator(
      onRefresh:
          () async => _loadNotifications(), // Use async for RefreshIndicator
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        itemCount: _notifications.length,
        separatorBuilder:
            (context, index) => Divider(
              thickness: 0.5,
              indent: 16,
              endIndent: 16,
              color: colorScheme.outlineVariant,
            ),
        itemBuilder: (context, index) {
          final event = _notifications[index];
          final timeString = _formatEventTime(event.eventDate, context);
          final IconData icon =
              _getIconForEvent(event) ?? Icons.event_available;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              child: Icon(icon, size: 20),
            ),
            title: Text(
              event.eventName,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              timeString,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () {
              // Navigate to event detail using the generated event data
              context.pushNamed(
                'eventDetail',
                pathParameters: {
                  'eventId': event.id,
                }, // ID might be less relevant now
                extra: event, // Pass the full event object
              );
            },
          );
        },
      ),
    );
  }
} // End of _NotificationsTabFrontendState

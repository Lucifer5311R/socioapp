// lib/widgets/my_events_tab.dart
// REVISED - Reads from MyEventsNotifier

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // <-- Import Provider

// Import models and widgets
import '../models/event.dart';
import '../widgets/event_card.dart';
import '../notifiers/my_events_notifier.dart'; // <-- Import Notifier

// Changed to StatelessWidget as state is managed by the Notifier
class MyEventsTab extends StatelessWidget {
  const MyEventsTab({super.key});

  // No state variables or loading methods needed here anymore

  void _navigateToEventDetail(BuildContext context, Event event) {
    context.pushNamed(
      'eventDetail',
      pathParameters: {'eventId': event.id},
      extra: event,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // --- Watch the MyEventsNotifier ---
    // context.watch ensures this widget rebuilds when the notifier changes
    final myEventsNotifier = context.watch<MyEventsNotifier>();
    // Get the current list of registered events directly from the notifier
    final events = myEventsNotifier.registeredEvents;

    // --- Empty State ---
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                "You haven't registered for any events yet.",
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Press 'Register' on an event's detail page to add it here.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              // Optional: Button to clear for demo purposes
              if (events
                  .isNotEmpty) // Only show clear button if there are events
                ElevatedButton.icon(
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text("Clear My Events (Demo)"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                  ),
                  // Use context.read inside callbacks
                  onPressed:
                      () => context.read<MyEventsNotifier>().clearEvents(),
                ),
            ],
          ),
        ),
      );
    }

    // --- Display List from Notifier ---
    // No FutureBuilder needed here
    return RefreshIndicator(
      // Refresh can clear the demo list or simply do nothing in UI-only mode
      onRefresh: () async {
        // Use context.read inside callbacks
        context
            .read<MyEventsNotifier>()
            .clearEvents(); // Example: Clear list on refresh
        // You might want to remove the clearEvents call here eventually
        // and replace it with actual data fetching logic later.
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16.0), // Padding around the list
        itemCount: events.length,
        separatorBuilder:
            (context, index) =>
                const SizedBox(height: 12), // Space between cards
        itemBuilder: (context, index) {
          final event = events[index];
          // Display each registered event using the standard EventCard layout
          return EventCard(
            event: event,
            // isCompact: false, // Default is false
            onTap: () => _navigateToEventDetail(context, event),
          );
        },
      ),
    );
  }
}

// lib/screens/public_discover_screen.dart
// FRONTEND-ONLY VERSION (Uses Random Data)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

// Import models and widgets
import '../models/event.dart';
import '../widgets/event_card.dart';
// Import the random event generator
import '../utils/random_event_generator.dart';

class PublicDiscoverScreen extends StatefulWidget {
  const PublicDiscoverScreen({super.key});

  @override
  State<PublicDiscoverScreen> createState() => _PublicDiscoverScreenState();
}

class _PublicDiscoverScreenState extends State<PublicDiscoverScreen> {
  // Future now holds randomly generated events
  late Future<List<Event>> _publicEventsFuture;
  final Logger log = Logger();

  @override
  void initState() {
    super.initState();
    _loadEvents(); // Load initial random events
  }

  // Method to load or reload RANDOM events
  void _loadEvents() {
    log.i("Loading RANDOM events for PublicDiscoverScreen...");
    // Generate a list of random events (e.g., 10 events)
    final randomEvents = generateRandomEvents(10);

    // Simulate an asynchronous operation using Future.value
    // This allows keeping the FutureBuilder structure
    _publicEventsFuture = Future.value(randomEvents);

    // Trigger a rebuild if the widget is still mounted
    if (mounted) {
      setState(() {});
    }
    log.i("Loaded ${randomEvents.length} random events.");
  }

  // Handles tapping on an event card - Navigation stays the same
  void _handleEventTap(Event event) {
    log.i(
      "Event Tap on Public Discover (Random Data): ${event.id} - ${event.eventName}",
    );
    // Navigate to event detail screen, passing the Event object via EXTRA
    context.pushNamed(
      'eventDetail',
      pathParameters: {'eventId': event.id}, // Keep for consistency if needed
      extra: event, // Pass the full Event object
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Events (Demo)'), // Indicate demo mode
        leading:
            GoRouter.of(context).canPop()
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                )
                : null,
        actions: [
          // Refresh button reloads random events
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Load New Random Events',
            onPressed: _loadEvents, // Call _loadEvents to regenerate
          ),
        ],
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 1,
      ),
      body: FutureBuilder<List<Event>>(
        future: _publicEventsFuture,
        builder: (context, snapshot) {
          // 1. Handle Error State (Less likely with random data, but good practice)
          if (snapshot.hasError) {
            log.e(
              "Error displaying random events: ${snapshot.error}",
              error: snapshot.error,
              stackTrace: snapshot.stackTrace,
            );
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 40,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Oops! Something went wrong displaying events.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text("Retry"),
                      onPressed: _loadEvents,
                    ),
                  ],
                ),
              ),
            );
          }

          // 2. Handle Loading State (Future.value completes quickly, but handles the initial frame)
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading placeholders
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: List.generate(
                5, // Show a few placeholders initially
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildPlaceholderEventCard(context), // Use placeholder
                ),
              ),
            );
          }

          // 3. Handle Empty State (generateRandomEvents should ideally return > 0)
          final events = snapshot.data;
          // Add explicit check for non-null AND non-empty list
          if (events == null || events.isEmpty) {
            log.w("No random events generated or snapshot data is null.");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.event_busy_outlined,
                    size: 50,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  const Text("No events to display right now."),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    // Option to try reloading
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("Reload Events"),
                    onPressed: _loadEvents,
                  ),
                ],
              ),
            );
          }

          // 4. Display the list of random events
          return RefreshIndicator(
            onRefresh: () async {
              _loadEvents(); // Pull-to-refresh reloads random events
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: events.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                // Ensure index is within bounds (though ListView.separated handles itemCount)
                if (index >= events.length) return const SizedBox.shrink();
                final event = events[index];
                return Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 600,
                    ), // Max width for cards
                    child: EventCard(
                      event: event, // Pass the random Event object
                      onTap: () => _handleEventTap(event), // Navigate on tap
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Helper to build placeholder card (Keep as is)
  Widget _buildPlaceholderEventCard(BuildContext context) {
    final placeholderColor = Colors.grey[300];
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            color: placeholderColor,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 10,
                  width: 80,
                  color: placeholderColor,
                  margin: const EdgeInsets.only(bottom: 8),
                ),
                Container(
                  height: 12,
                  width: 200,
                  color: placeholderColor,
                  margin: const EdgeInsets.only(bottom: 6),
                ),
                Container(
                  height: 10,
                  width: 150,
                  color: placeholderColor,
                  margin: const EdgeInsets.only(bottom: 4),
                ),
                Container(height: 10, width: 180, color: placeholderColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

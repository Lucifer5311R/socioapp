// lib/notifiers/my_events_notifier.dart
import 'package:flutter/foundation.dart';
import '../models/event.dart'; // Import your Event model

class MyEventsNotifier extends ChangeNotifier {
  // Private list to hold the "registered" events in memory
  final List<Event> _registeredEvents = [];

  // Public getter to access the list
  List<Event> get registeredEvents => List.unmodifiable(_registeredEvents);

  // Method to check if an event is already "registered"
  bool isRegistered(Event event) {
    // Compare based on event ID
    return _registeredEvents.any((e) => e.id == event.id);
  }

  // Method to "register" an event (add it to the list)
  void registerEvent(Event event) {
    if (!isRegistered(event)) {
      _registeredEvents.add(event);
      // Sort by date after adding (optional, keeps list ordered)
      _registeredEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      notifyListeners(); // <-- This updates listening widgets
    }
  }

  // Method to "unregister" an event (remove it from the list)
  void unregisterEvent(Event event) {
    _registeredEvents.removeWhere((e) => e.id == event.id);
    notifyListeners(); // Notify widgets listening to this notifier
  }

  // Method to clear all events (for demo/refresh)
  void clearEvents() {
    _registeredEvents.clear();
    notifyListeners();
  }
}

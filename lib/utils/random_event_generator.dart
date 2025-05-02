// lib/utils/random_event_generator.dart
import 'dart:math';
import 'package:flutter/foundation.dart'; // For UniqueKey
import '../models/event.dart';
import 'sample_data.dart'; // Import image utility

List<String> _eventNouns = [
  'Summit',
  'Conference',
  'Workshop',
  'Hackathon',
  'Fest',
  'Meetup',
  'Symposium',
  'Expo',
  'Gala',
  'Challenge',
];
List<String> _eventAdjectives = [
  'Annual Tech',
  'Global Innovation',
  'Creative Coding',
  'Entrepreneurship',
  'Future Leaders',
  'Digital Art',
  'Robotics',
  'AI Ethics',
  'Sustainable Design',
  'Campus Music',
];
List<String> _locations = [
  'Main Auditorium',
  'Tech Park Seminar Hall',
  'Library Annex Room 3',
  'Student Union Plaza',
  'Online (Virtual)',
  'Engineering Block C Lab',
  'Arts Department Gallery',
  'Sports Complex Field B',
];
List<String> _departments = [
  'Computer Science Dept.',
  'Management Studies',
  'Electronics Club',
  'Student Council',
  'Alumni Association',
  'Fine Arts Society',
  'Robotics Club',
  'Entrepreneurship Cell',
];
List<String> _tagsPool = [
  'Tech',
  'Academic',
  'Workshop',
  'Competition',
  'Cultural',
  'Social',
  'Networking',
  'Career',
  'Seminar',
  'Guest Lecture',
  'Free',
  'Paid',
  'Beginner',
  'Advanced',
  'Fest',
];
List<String> _organizerNames = [
  'Dr. Evelyn Reed',
  'Prof. Kenji Tanaka',
  'ACM Student Chapter',
  'IEEE Branch',
  'The Coding Club',
  'Placement Cell',
  'Music Society',
  'TechFest Committee',
];

// Simple lorem ipsum generator (replace with a package like 'lorem_ipsum' for better text)
String _generateDescription(String eventName, String department) {
  Random random = Random();
  List<String> templates = [
    "Join us for the exciting $eventName, brought to you by the $department. Discover the latest trends, network with experts, and enhance your skills. Don't miss out!",
    "The $department is proud to present $eventName. This event offers a unique opportunity for learning and collaboration. Expect insightful sessions and engaging activities. Register today!",
    "Get ready for $eventName! A premier event featuring guest speakers, workshops, and competitions. Whether you're a beginner or an expert, there's something for everyone. Hosted by $department.",
  ];
  return templates[random.nextInt(templates.length)];
}

List<String> _generateRandomTags() {
  Random random = Random();
  int count = random.nextInt(3) + 1; // 1-3 tags
  List<String> availableTags = List.from(_tagsPool); // Copy to allow removal
  List<String> selectedTags = [];
  for (int i = 0; i < count; i++) {
    if (availableTags.isEmpty) break;
    int index = random.nextInt(availableTags.length);
    selectedTags.add(availableTags.removeAt(index));
  }
  // Ensure 'Paid'/'Free' tags are consistent with fee
  // (Handled below when creating the event object)
  return selectedTags;
}

String _generateSchedule() {
  Random random = Random();
  List<String> items = [
    "9:00 AM: Registration & Coffee",
    "10:00 AM: Opening Keynote",
    "11:00 AM: Session 1 - ${_eventAdjectives[random.nextInt(_eventAdjectives.length)]}",
    "12:00 PM: Workshop - ${_eventNouns[random.nextInt(_eventNouns.length)]} Basics",
    "1:00 PM: Lunch Break",
    "2:00 PM: Panel Discussion",
    "3:00 PM: Session 2 - Deep Dive",
    "4:00 PM: Networking Session",
    "5:00 PM: Closing Remarks",
  ];
  int itemCount = random.nextInt(4) + 3; // 3-6 schedule items
  items.shuffle(random);
  return items.take(itemCount).join('\n');
}

String _generateRules() {
  Random random = Random();
  List<String> items = [
    "All participants must register online.",
    "Student ID card is mandatory for entry.",
    "Outside food and beverages are not permitted.",
    "Follow instructions from event organizers.",
    "Maintain decorum throughout the event.",
    "Plagiarism will result in disqualification (for competitions).",
    "Use of mobile phones restricted during sessions.",
    "Respect venue property.",
  ];
  int itemCount = random.nextInt(3) + 2; // 2-4 rules
  items.shuffle(random);
  return items.take(itemCount).map((e) => "• $e").join('\n');
}

String _generatePrizes() {
  Random random = Random();
  List<String> items = [
    "1st Place: \$100 Amazon Voucher + Certificate",
    "2nd Place: \$50 Book Coupon + Certificate",
    "3rd Place: Certificate of Merit",
    "Top 5 participants receive goodies.",
    "All attendees get participation certificates.",
    "Best Project Award: Trophy + \$200",
    "Most Innovative Idea: Certificate + Swag Bag",
  ];
  int itemCount = random.nextInt(3) + 1; // 1-3 prize details
  items.shuffle(random);
  return items.take(itemCount).map((e) => "• $e").join('\n');
}

String _generateOrganizerInfo(String dept) {
  Random random = Random();
  String name = _organizerNames[random.nextInt(_organizerNames.length)];
  String email = "${name.split(' ').last.toLowerCase()}@example.edu";
  String phone = "+91 98${random.nextInt(90000000) + 10000000}";
  return "$name\n$dept\n$email\n$phone";
}

List<Event> generateRandomEvents(int count) {
  final random = Random();
  List<Event> events = [];

  for (int i = 0; i < count; i++) {
    String name =
        '${_eventAdjectives[random.nextInt(_eventAdjectives.length)]} ${_eventNouns[random.nextInt(_eventNouns.length)]} ${random.nextInt(50) + 2024}';
    String location = _locations[random.nextInt(_locations.length)];
    String department = _departments[random.nextInt(_departments.length)];
    String description = _generateDescription(
      name,
      department,
    ); // 1-2 paragraphs, 2-4 sentences , 2-4 sentences each
    DateTime createdAt = DateTime.now().subtract(
      Duration(days: random.nextInt(60)),
    );
    DateTime eventDate = DateTime.now().add(
      Duration(days: random.nextInt(90) - 15),
    ); // -15 to +74 days from now
    double fee =
        random.nextDouble() < 0.3
            ? 0.0
            : (random.nextInt(50) + 5) * 10.0; // 30% chance free, else 50-540
    int maxReg = random.nextInt(151) + 50; // 50-200
    int currentReg =
        (maxReg > 0) ? random.nextInt(maxReg + 1) : 0; // 0 to maxReg

    List<String> tags = _generateRandomTags();
    // Add/Remove Free/Paid tag based on fee
    tags.removeWhere((tag) => tag == 'Free' || tag == 'Paid');
    tags.add(fee == 0.0 ? 'Free' : 'Paid');
    int minTeam = 1;
    int maxTeam = 1;
    // ~20% chance of being a team event
    if (random.nextDouble() < 0.2) {
      minTeam = random.nextInt(2) + 2; // Min team size 2 or 3
      maxTeam = minTeam + random.nextInt(3); // Max team size min to min+2
    }
    events.add(
      Event(
        id: 'random_event_${UniqueKey().toString()}', // Unique random ID
        createdAt: createdAt,
        organizerId: 'org_${random.nextInt(100)}', // Random organizer ID
        eventName: name,
        description: description,
        eventDate: eventDate,
        location: location,
        registrationFee: fee,
        bannerUrl: getRandomEventImageUrl(), // Assign random image URL
        isPublic: random.nextDouble() < 0.9 ? true : false, // 90% public
        tags: tags,
        department: department,
        maxRegistrations: maxReg,
        currentRegistrations: currentReg,
        rules: _generateRules(),
        schedule: _generateSchedule(),
        prizes:
            fee > 0 || tags.contains('Competition')
                ? _generatePrizes()
                : "Participation Certificates for all attendees.", // Add prizes for paid/competition events
        organizerInfo: _generateOrganizerInfo(department),
        minTeamSize: minTeam,
        maxTeamSize: maxTeam,
      ),
    );
  }
  return events;
}

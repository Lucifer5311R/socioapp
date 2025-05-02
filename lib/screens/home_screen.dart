// lib/screens/home_screen.dart
// REVISED V5.4 - Fixed ALL Diagnostics (Const, Controller Type, Opacity, Icons Scope)

import 'dart:math'; // For Random in placeholders

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:carousel_slider/carousel_slider.dart'; // Import Carousel Slider
import 'package:cached_network_image/cached_network_image.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

// Import models and widgets
import '../widgets/my_events_tab.dart';
import '../models/event.dart';
import '../models/category.dart';
import '../widgets/event_card.dart'; // Using updated EventCard
import '../widgets/category_card.dart';
import '../widgets/notifications_tab.dart';
import 'student_dashboard_screen.dart';
// Import Notifier
import '../notifiers/home_screen_notifier.dart';
// Import utilities
import '../utils/random_event_generator.dart'; // Used by Notifier placeholder
import '../utils/sample_data.dart';

// --- Constants ---
const double kTopPicksCarouselHeight = 235.0;
const double kStandardCarouselHeight = 240.0;
const double kClubCardWidth = 180.0;
const double kEventCardWidth = 210.0;
const double kMvpCardWidth = 150.0;

// --- Main Widget Structure ---
// Wrap HomeScreen presentation logic with ChangeNotifierProvider
class HomeScreenWrapper extends StatelessWidget {
  const HomeScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the Notifier to the HomeScreen widget tree
    return ChangeNotifierProvider(
      create: (_) => HomeScreenNotifier(),
      child: const HomeScreen(), // Your original HomeScreen widget
    );
  }
}

// HomeScreen uses StatefulWidget for local UI state like _selectedIndex and carousel page
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Logger log = Logger();
  int _selectedIndex = 0; // Bottom nav index

  // --- Static Data (Defined within State class for easy access by helpers) ---
  // Made static as they don't depend on instance state
  static final List<Category> _placeholderCategories = [
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
  static const Map<String, IconData> _eventIcons = {
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

  // --- Local UI State ---
  // Correct Controller Type!
  final CarouselSliderController _topPicksCarouselController =
      CarouselSliderController();
  int _topPicksCurrentPage = 0;

  @override
  void initState() {
    super.initState();
    // Initial data loading handled by Notifier's constructor via Provider
  }

  // --- Navigation Callbacks ---
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToEventDetail(BuildContext context, Event event) {
    if (event.id.isNotEmpty) {
      context.pushNamed(
        'eventDetail',
        pathParameters: {'eventId': event.id},
        extra: event,
      );
    } else {
      log.e("Nav Error: Event ID empty for ${event.eventName}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Error: Invalid event ID."),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _handleCategoryTap(Category category) {
    log.i("Category tapped: ${category.title}");
    context.pushNamed(
      'publicDiscover',
      queryParameters: {'category': category.title},
    );
  }

  void _navigateToSearch(BuildContext context) {
    log.i(
      "Search icon tapped - Navigating to Search Screen (Placeholder)",
    ); /* context.pushNamed('searchScreen'); */
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Navigate to Search Screen (Not Implemented)"),
      ),
    );
  }

  void _navigateToViewAll(BuildContext context, String section) {
    log.i(
      "View All tapped for section: $section",
    ); /* context.pushNamed('publicDiscover', queryParameters: {'filter': section.toLowerCase()}); */
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Navigate to View All $section (Not Implemented)"),
      ),
    );
  }

  void _navigateToClubList(BuildContext context) {
    context.pushNamed('clubList'); // Use the route name defined in main.dart
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define tabs
    final List<Widget> widgetOptions = <Widget>[
      _buildHomeTabContent(context), // Needs context to access Provider
      const MyEventsTab(), // Can be const if needed elsewhere
      const NotificationsTabFrontend(),
      const StudentDashboardScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(_selectedIndex),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 1,
        shadowColor: colorScheme.shadow.withAlpha((255 * 0.1).round()),
        /* Fixed Opacity */ actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search Events',
            onPressed: () => _navigateToSearch(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: widgetOptions),
      // BottomNavBar - *REMOVED* 'const' from items list literal
      bottomNavigationBar: BottomNavigationBar(
        items: /* REMOVED const */ <BottomNavigationBarItem>[
          // Individual items can be const
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'My Events',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant.withAlpha(
          (255 * 0.7).round(),
        ),
        /* Fixed Opacity */ onTap: _onItemTapped,
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

  // --- AppBar Title Helper ---
  String _getAppBarTitle(int index) {
    return ['SOCIO.', 'My Events', 'Notifications', 'Profile'][index];
  }

  // --- Placeholder Tab Helper ---
  Widget _buildPlaceholderTab(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction, size: 50, color: Colors.grey),
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

  // --- Home Tab Content (Reads from Notifier) ---
  Widget _buildHomeTabContent(BuildContext context) {
    // Use watch only for data needed directly in this build scope
    final notifier = context.watch<HomeScreenNotifier>();
    final theme = Theme.of(context);
    final String userName =
        (notifier.userProfile?['full_name'] ?? 'Student').toString();

    if (notifier.profileLoadingStatus == LoadingStatus.loading ||
        notifier.profileLoadingStatus == LoadingStatus.idle) {
      return const Center(child: CircularProgressIndicator());
    }
    if (notifier.profileLoadingStatus == LoadingStatus.error) {
      // Consider adding a retry button that calls notifier.refreshData()
      return _buildErrorWidget("Could not load profile data.");
    }

    // Main scrollable content
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<HomeScreenNotifier>().refreshData();
      },
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24.0),
        children: [
          // 1. Greeting
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 20.0,
              bottom: 8.0,
            ),
            child: Text(
              "Hi, $userName!",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 2. Top Picks Carousel
          _buildSectionHeader(
            "Top Picks",
            context: context,
            showViewAll: false,
          ),
          _buildTopPicksCarousel(context), // Uses FutureBuilder inside
          const SizedBox(height: 16),

          // 3. Campus Filter Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: notifier.selectedCampusFilter, // Read from notifier
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, size: 24),
                    elevation: 8,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                    underline: Container(
                      height: 1,
                      color: theme.colorScheme.secondary.withAlpha(
                        (255 * 0.5).round(),
                      ) /* Fixed Opacity */,
                    ),
                    // Use context.read for actions in callbacks
                    onChanged: (String? newValue) {
                      context.read<HomeScreenNotifier>().setCampusFilter(
                        newValue,
                      );
                    },
                    items:
                        notifier.campusOptions
                            .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                    hint: const Text("Select Campus"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Featured Events Carousel
          _buildSectionHeader(
            "Featured Events",
            context: context,
            onViewAllTap: () => _navigateToViewAll(context, "Featured"),
          ),
          _buildStandardEventCarousel(
            context: context,
            future: notifier.featuredEventsFuture,
            loadingStatus: notifier.featuredEventsLoadingStatus,
            height: kStandardCarouselHeight,
            itemWidth: kEventCardWidth,
            errorMsg: "Could not load featured events.",
            emptyMsg: "No featured events found.",
          ),
          const SizedBox(height: 24),

          // 5. Upcoming Fests Carousel
          _buildSectionHeader(
            "Upcoming Fests",
            context: context,
            onViewAllTap: () => _navigateToViewAll(context, "Fests"),
          ),
          _buildStandardEventCarousel(
            context: context,
            future: notifier.upcomingFestsFuture,
            loadingStatus: notifier.upcomingFestsLoadingStatus,
            height: kStandardCarouselHeight,
            itemWidth: kEventCardWidth,
            errorMsg: "Could not load upcoming fests.",
            emptyMsg: "No upcoming fests found.",
          ),
          const SizedBox(height: 24),

          // 6. Categories Grid
          _buildSectionHeader(
            "Browse by Category",
            context: context,
            showViewAll: false,
          ),
          _buildCategoryGrid(_placeholderCategories), // Use static categories
          const SizedBox(height: 24),

          // 7. University Centers and Clubs Carousel
          _buildSectionHeader(
            "University Centers & Clubs",
            context: context,
            onViewAllTap: () => _navigateToClubList(context),
          ),
          _buildClubsCarouselPlaceholder(context), // Uses placeholder data
          const SizedBox(height: 24),

          // 9. Team Events Section
          _buildSectionHeader(
            "Team Events", // Section title
            context: context,
            onViewAllTap:
                () => _navigateToViewAll(
                  context,
                  "Team Events",
                ), // Optional: Implement View All later
          ),
          _buildStandardEventCarousel(
            // Reuse the standard carousel builder
            context: context,
            future:
                notifier.teamEventsFuture, // Use the new future from notifier
            loadingStatus:
                notifier.teamEventsLoadingStatus, // Use the new status
            height: kStandardCarouselHeight, // Use standard height/width
            itemWidth: kEventCardWidth,
            errorMsg: "Could not load team events.",
            emptyMsg: "No team events found.", // Empty state message
          ),

          const SizedBox(height: 24),

          // 8. Upcoming Events Section
          _buildSectionHeader(
            "Upcoming Events",
            context: context,
            showViewAll: false,
          ),
          _buildUpcomingFilters(context), // Filter chips row
          const SizedBox(height: 8),
          _buildVerticalEventList(context), // Vertical list using FutureBuilder
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- Helper Widgets for Home Tab Content ---

  // Helper for Top Picks Carousel (Reads Notifier state via context.watch)
  Widget _buildTopPicksCarousel(BuildContext context) {
    // Watch the specific parts of the notifier needed for this builder
    final future = context.watch<HomeScreenNotifier>().topEventsFuture;
    final status = context.watch<HomeScreenNotifier>().topEventsLoadingStatus;

    return FutureBuilder<List<Event>>(
      future: future,
      builder: (context, snapshot) {
        if (status == LoadingStatus.loading && !snapshot.hasData) {
          return _buildCarouselLoadingPlaceholder(
            height: kTopPicksCarouselHeight,
          );
        } else if (status == LoadingStatus.error) {
          return _buildErrorWidget("Could not load top picks.");
        } else {
          final events = snapshot.data ?? [];
          List<Widget> carouselItems = [
            SizedBox(
              height: kTopPicksCarouselHeight,
              child: _buildMvpCardPlaceholder(
                context,
                cardHeight: kTopPicksCarouselHeight,
              ),
            ),
          ];
          carouselItems.addAll(
            events
                .map(
                  (event) => _buildTopPickEventCard(
                    context,
                    event,
                    kTopPicksCarouselHeight,
                  ),
                )
                .toList(),
          );
          if (carouselItems.length <= 1) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: carouselItems.first,
            );
          }

          // Use local state (_topPicksCurrentPage) for indicators
          return Column(
            children: [
              CarouselSlider.builder(
                carouselController:
                    _topPicksCarouselController, // Use local controller
                options: CarouselOptions(
                  height: kTopPicksCarouselHeight,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  viewportFraction: 0.9,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.15,
                  enableInfiniteScroll: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _topPicksCurrentPage = index;
                    });
                  }, // Update local state
                ),
                itemCount: carouselItems.length,
                itemBuilder: (context, itemIndex, pageViewIndex) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: carouselItems[itemIndex],
                  );
                },
              ),
              // Indicators read local state
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    carouselItems.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap:
                            () => _topPicksCarouselController.animateToPage(
                              entry.key,
                            ),
                        /* animateToPage is correct method */ child: Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 4.0,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black)
                                .withAlpha(
                                  (255 *
                                          (_topPicksCurrentPage == entry.key
                                              ? 0.9
                                              : 0.4))
                                      .round(),
                                ) /* Fixed Opacity */,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          );
        }
      },
    );
  }

  // Helper for Standard Event Carousel (Reads Notifier state via context.watch)
  Widget _buildStandardEventCarousel({
    required BuildContext context,
    required Future<List<Event>> future,
    required LoadingStatus loadingStatus,
    required double height,
    required double itemWidth,
    required String errorMsg,
    required String emptyMsg,
  }) {
    // Use FutureBuilder directly listening to the passed future
    return FutureBuilder<List<Event>>(
      future: future,
      builder: (context, snapshot) {
        // Use loadingStatus from notifier for more accurate loading state
        if (loadingStatus == LoadingStatus.loading && !snapshot.hasData) {
          return _buildHorizontalLoadingPlaceholder(
            cardWidth: itemWidth,
            cardHeight: height,
          );
        } else if (loadingStatus == LoadingStatus.error) {
          return _buildErrorWidget(errorMsg);
        } else {
          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return _buildEmptyWidget(emptyMsg);
          }
          return SizedBox(
            height: height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: events.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final event = events[index];
                return SizedBox(
                  width: itemWidth,
                  child: EventCard(
                    event: event,
                    isCompact: false,
                    onTap: () => _navigateToEventDetail(context, event),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  // Builds card for Top Picks carousel
  Widget _buildTopPickEventCard(
    BuildContext context,
    Event event,
    double cardHeight,
  ) {
    // Ensure the EventCard is wrapped in SizedBox matching the carousel item height
    return SizedBox(
      height: cardHeight,
      child: EventCard(
        event: event,
        isCompact: true,
        onTap: () => _navigateToEventDetail(context, event),
      ),
    );
  }

  // Placeholder Widgets (MVP, Clubs, Shimmer etc.)
  Widget _buildMvpCardPlaceholder(
    BuildContext context, {
    required double cardHeight,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SizedBox(
      width: double.infinity,
      height: cardHeight,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: colorScheme.tertiaryContainer.withAlpha((255 * 0.8).round()),
        /* Fixed Opacity */ child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 36,
                color: colorScheme.onTertiaryContainer,
              ),
              const SizedBox(height: 8),
              Text(
                "🏆 MVP Name",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onTertiaryContainer,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "XX Events Attended",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onTertiaryContainer.withAlpha(
                    (255 * 0.8).round(),
                  ),
                ) /* Fixed Opacity */,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  "View Profile",
                  style: TextStyle(color: colorScheme.onTertiaryContainer),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClubsCarouselPlaceholder(BuildContext context) {
    List<Map<String, String>> placeholderClubs = List.generate(
      5,
      (index) => {
        'title': 'Club/Center ${index + 1}',
        'image': getRandomEventImageUrl(),
        'desc': 'Short description of the club or center goes here...',
      },
    );
    return SizedBox(
      height: kStandardCarouselHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: placeholderClubs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final club = placeholderClubs[index];
          return _buildClubCardPlaceholder(
            context,
            club['image']!,
            club['title']!,
            club['desc']!,
          );
        },
      ),
    );
  }

  Widget _buildClubCardPlaceholder(
    BuildContext context,
    String imageUrl,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    return SizedBox(
      width: kClubCardWidth,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    height: 100,
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.business_outlined,
                      color: Colors.grey,
                    ),
                  ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    TextButton.icon(
                      icon: Icon(
                        Icons.link,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(
                        "Learn More",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Loading Placeholders
  Widget _buildCarouselLoadingPlaceholder({required double height}) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      alignment: Alignment.center,
      child: _buildPlaceholderCard(
        context,
        width: MediaQuery.of(context).size.width * 0.85,
        height: height * 0.9,
      ),
    );
  }

  Widget _buildHorizontalLoadingPlaceholder({
    required double cardWidth,
    required double cardHeight,
  }) {
    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount:
            (MediaQuery.of(context).size.width / (cardWidth + 12)).ceil(),
        itemBuilder:
            (context, index) => Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: _buildPlaceholderCard(
                context,
                width: cardWidth,
                height: cardHeight,
              ),
            ),
      ),
    );
  }

  Widget _buildVerticalLoadingPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildPlaceholderCard(context, height: 200),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard(
    BuildContext context, {
    double width = 250,
    double height = 280,
  }) {
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
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: height * 0.45,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: width * 0.5,
                    color: baseColor,
                    margin: const EdgeInsets.only(bottom: 8),
                  ),
                  Container(
                    height: 10,
                    width: width * 0.8,
                    color: baseColor,
                    margin: const EdgeInsets.only(bottom: 6),
                  ),
                  Container(height: 10, width: width * 0.6, color: baseColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Error/Empty Widgets
  Widget _buildErrorWidget(String message) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(String message) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withAlpha(150),
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withAlpha(200),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Section Header Helper
  Widget _buildSectionHeader(
    String title, {
    bool showViewAll = true,
    VoidCallback? onViewAllTap,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (showViewAll && onViewAllTap != null)
            TextButton(
              onPressed: onViewAllTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                visualDensity: VisualDensity.compact,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("View all"),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Category Grid Helper
  Widget _buildCategoryGrid(List<Category> categories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 1.05,
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

  // --- Upcoming Event Filter Chips ---
  Widget _buildUpcomingFilters(BuildContext context) {
    final notifier = context.watch<HomeScreenNotifier>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              notifier.upcomingFilters.map((filter) {
                final bool isSelected =
                    notifier.selectedUpcomingFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                    onSelected: (bool selected) {
                      final newFilter = selected ? filter : "All";
                      context.read<HomeScreenNotifier>().setUpcomingFilter(
                        newFilter,
                      );
                    },
                    showCheckmark: false,
                    selectedColor: colorScheme.secondaryContainer.withAlpha(
                      (255 * 0.7).round(),
                    ),
                    backgroundColor: colorScheme.surfaceContainerLowest,
                    labelStyle: TextStyle(
                      color:
                          isSelected
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color:
                          isSelected
                              ? colorScheme.secondary.withAlpha(
                                (255 * 0.5).round(),
                              )
                              : colorScheme.outline.withAlpha(
                                (255 * 0.5).round(),
                              ),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  // --- Vertical Event List ---
  Widget _buildVerticalEventList(BuildContext context) {
    final notifier = context.watch<HomeScreenNotifier>();
    final future = notifier.allUpcomingEventsFuture;
    final status = notifier.allUpcomingEventsLoadingStatus;

    return FutureBuilder<List<Event>>(
      future: future,
      builder: (context, snapshot) {
        if (status == LoadingStatus.loading && !snapshot.hasData) {
          return _buildVerticalLoadingPlaceholder();
        } else if (status == LoadingStatus.error) {
          return _buildErrorWidget("Could not display upcoming events.");
        } else {
          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return _buildEmptyWidget(
              "No upcoming events found matching filters.",
            );
          }
          return ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: events.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final currentEvent = events[index];
              // Access static _eventIcons map directly using class name
              final iconData = _HomeScreenState._getIconForEvent(currentEvent);
              return EventCard(
                event: currentEvent,
                leadingIconData: iconData,
                leadingIconColor: Theme.of(context).colorScheme.secondary,
                isCompact: false,
                onTap: () => _navigateToEventDetail(context, currentEvent),
              );
            },
          );
        }
      },
    );
  }

  // Icon Helper - Make static or keep as instance method if _HomeScreenState is stateful
  static IconData? _getIconForEvent(Event event) {
    // Made static for simplicity now
    if (event.tags == null) return Icons.event_note_outlined;
    for (String tag in event.tags!) {
      final lowerTag = tag.toLowerCase();
      // Access static map using class name
      if (_HomeScreenState._eventIcons.containsKey(lowerTag)) {
        return _HomeScreenState._eventIcons[lowerTag];
      }
    }
    return Icons.event_note_outlined;
  }
} // End of _HomeScreenState

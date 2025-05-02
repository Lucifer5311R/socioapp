// lib/screens/event_detail_screen.dart
// REFINED V4 - Integrated with MyEventsNotifier for UI Registration

import 'package:cached_network_image/cached_network_image.dart'; // Import CachedNetworkImage
import 'package:flutter/gestures.dart'; // Keep for RichText links
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart'; // <-- Import Provider
import 'package:flutter/gestures.dart';

import '../models/event.dart';
import '../notifiers/my_events_notifier.dart'; // <-- Import Notifier
import '../widgets/team_registration_form.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;
  final Logger log = Logger();

  EventDetailScreen({required this.event, super.key});

  // --- Modified registration handler ---
  void _handleRegistrationAction(
    BuildContext context,
    MyEventsNotifier notifier,
  ) {
    // Check if event is a team event
    if (event.isTeamEvent) {
      // --- Show Team Registration Form ---
      log.i("Showing team registration form for: ${event.eventName}");
      showModalBottomSheet(
        context: context,
        // Make sheet scrollable and expand based on content
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          // Optional: Rounded corners
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => TeamRegistrationForm(event: event),
      );
    } else {
      // --- Handle Individual Registration (Current UI-only logic) ---
      log.i("UI ACTION: Registering individual for event: ${event.eventName}");
      notifier.registerEvent(event); // Add event to the notifier's list

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "${event.eventName}" to My Events! (UI Only)'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  // Placeholder Actions (Keep others as needed)
  void _navigateToProfile(BuildContext context) {
    log.i("Navigate to Profile/Dashboard Tapped (Placeholder)");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile icon tapped (Demo)")));
    // Example if using GoRouter: context.goNamed('profile');
  }

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    log.i("Attempting to launch URL (disabled): $urlString");
    // Add url_launcher package and uncomment to enable
    // final Uri uri = Uri.parse(urlString);
    // if (await canLaunchUrl(uri)) {
    //   await launchUrl(uri);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Could not launch URL: $urlString")),
    //   );
    // }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Link tapped (launch disabled): $urlString")),
    );
  }

  // --- Widget Builders ---
  Widget _buildTagChip(String text, Color backgroundColor, Color textColor) {
    return Chip(
      label: Text(text),
      labelStyle: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
      backgroundColor: backgroundColor,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide.none,
    );
  }

  Widget _buildDetailRow(IconData icon, String text, BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .start, // Use start for potentially multi-line text
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds a content section with title, handling potential links and bullet points
  Widget _buildInfoSection(
    BuildContext context,
    String title,
    String content, {
    bool parseContent = true, // Set to false to display raw text
  }) {
    final theme = Theme.of(context);

    // Function to parse content (URLs, bullets)
    List<Widget> buildContentWidgets(String text) {
      if (!parseContent) {
        return [
          Text(
            text.isEmpty ? "Information not available." : text,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ];
      }

      final RegExp urlRegExp = RegExp(
        r'((https?:\/\/|www\.)[^\s]+)',
        caseSensitive: false,
      );
      final List<Widget> widgets = [];

      if (text.trim().isEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "Information not available.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
        );
        return widgets;
      }

      final lines = text.split('\n');
      for (final line in lines) {
        if (line.trim().isEmpty) {
          widgets.add(const SizedBox(height: 8.0));
          continue;
        }

        List<InlineSpan> spans = [];
        int currentPosition = 0;
        // Basic bullet point check (adjust regex if needed for more types)
        bool isBullet = line.trim().startsWith(RegExp(r'[•*-]\s*'));
        String displayLine =
            isBullet
                ? line.trim().replaceFirst(RegExp(r'[•*-]\s*'), '')
                : line.trim();

        for (final match in urlRegExp.allMatches(displayLine)) {
          if (match.start > currentPosition) {
            spans.add(
              TextSpan(
                text: displayLine.substring(currentPosition, match.start),
              ),
            );
          }

          spans.add(
            TextSpan(
              text: match.group(0),
              style: TextStyle(
                color: Colors.blue[800],
                decoration: TextDecoration.underline,
                decorationColor: Colors.blue[800],
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () {
                      _launchUrl(context, match.group(0)!);
                    },
            ),
          );
          currentPosition = match.end;
        }
        if (currentPosition < displayLine.length) {
          spans.add(TextSpan(text: displayLine.substring(currentPosition)));
        }

        widgets.add(
          Padding(
            padding: EdgeInsets.only(
              left: isBullet ? 8.0 : 0,
              top: 4.0,
              bottom: 4.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isBullet)
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 8.0,
                      top: 7,
                    ), // Adjust top padding for alignment
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: theme.textTheme.bodyLarge?.color?.withAlpha(180),
                    ),
                  ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      children: spans,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return widgets;
    }

    // Return Column containing the title and parsed content
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...buildContentWidgets(content), // Spread the list of widgets
      ],
    );
  }

  // Helper to create the scrollable content view for each tab
  Widget _buildTabView(BuildContext context, List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Add spacing between widgets passed in the list
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isEven) {
            return children[index ~/ 2];
          } else {
            // Add spacing between sections in the tab
            return const SizedBox(height: 24.0);
          }
        }),
      ),
    );
  }
  // --- End Widget Builders ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // --- Get the Notifier using context.watch ---
    // context.watch makes the widget rebuild when the notifier changes (e.g., when isRegistered changes)
    final myEventsNotifier = context.watch<MyEventsNotifier>();
    // --- Check registration status ---
    final bool alreadyRegistered = myEventsNotifier.isRegistered(event);

    // --- Data Formatting & Calculation ---
    final String formattedDate = DateFormat(
      'MMM d, EEEE',
    ).format(event.eventDate); // Example format
    final String formattedTime = DateFormat('h:mm a').format(event.eventDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(
      event.eventDate.year,
      event.eventDate.month,
      event.eventDate.day,
    );
    final difference = eventDay.difference(today);
    final int daysLeft = difference.isNegative ? 0 : difference.inDays;
    final bool isEventUpcomingOrToday =
        !difference.isNegative || eventDay.isAtSameMomentAs(today);
    final String feeString =
        event.registrationFee == 0.0 || event.registrationFee == null
            ? 'Free'
            : '₹${event.registrationFee?.toStringAsFixed(0)}';
    final String registrationCount =
        '${event.currentRegistrations ?? 0}/${event.maxRegistrations ?? 'NA'} registrations';
    // Determine primary tag (optional enhanced logic)
    String? primaryTagText;
    Color? primaryTagBgColor;
    Color? primaryTagTextColor;
    if (event.tags?.contains("Free") ?? false) {
      primaryTagText = "Free";
      primaryTagBgColor = Colors.green[50];
      primaryTagTextColor = Colors.green[800];
    } else if (event.registrationFee != null && event.registrationFee! > 0) {
      primaryTagText = "Paid";
      primaryTagBgColor = Colors.blue[50];
      primaryTagTextColor = Colors.blue[800];
    } // Add more logic (Featured, Academic etc.) if needed

    // --- Define Tabs ---
    final List<Tab> tabs = <Tab>[
      const Tab(text: 'Details'),
      const Tab(text: 'Rules'), // Shortened label
      const Tab(text: 'Schedule'),
      const Tab(text: 'Prizes'),
      const Tab(text: 'Organizers'),
    ];

    // --- Build UI ---
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: colorScheme.surface, // Use theme surface color
        body: CustomScrollView(
          slivers: <Widget>[
            // --- AppBar ---
            SliverAppBar(
              title: Text(
                'SOCIO.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.account_circle_outlined, // Use outlined version
                    color: colorScheme.primary,
                    size: 28,
                  ),
                  tooltip: 'Profile / Dashboard',
                  onPressed: () => _navigateToProfile(context),
                ),
                const SizedBox(width: 8),
              ],
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              elevation: 1.0, // Subtle elevation
              pinned: true, // Keep AppBar visible
              floating: true, // Allow AppBar to reappear quickly
              snap: true, // Snap AppBar into view
            ),

            // --- Banner Image ---
            SliverToBoxAdapter(
              child: Container(
                height: 200,
                color: colorScheme.surfaceContainerLowest, // Placeholder color
                child:
                    (event.bannerUrl != null && event.bannerUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                          imageUrl: event.bannerUrl!,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          errorWidget: (context, url, error) {
                            log.w(
                              "Failed to load banner: ${event.bannerUrl}",
                              error: error,
                            );
                            return const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey,
                                size: 50,
                              ),
                            );
                          },
                        )
                        : const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                            size: 50,
                          ),
                        ),
              ),
            ),

            // --- Header Section ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tags Wrap
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              if (primaryTagText != null)
                                _buildTagChip(
                                  primaryTagText,
                                  primaryTagBgColor!,
                                  primaryTagTextColor!,
                                ),
                              // Add logic to show other relevant tags if needed
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Event Name
                          Text(
                            event.eventName,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Department (if available)
                          if (event.department != null &&
                              event.department!.isNotEmpty)
                            Text(
                              "Dept. of ${event.department!}",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Days Left Indicator (if applicable)
                    if (isEventUpcomingOrToday)
                      Container(
                        width: 65,
                        height: 65,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.yellow[600],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$daysLeft',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              daysLeft == 1 ? 'day left' : 'days left',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.black87,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // --- TabBar ---
            SliverPersistentHeader(
              delegate: _SliverTabBarDelegate(
                TabBar(
                  tabs: tabs,
                  labelColor: Colors.blue[800],
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: Colors.blue[800],
                  indicatorWeight: 3.0,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                  overlayColor: WidgetStatePropertyAll(
                    Colors.blue[800]?.withOpacity(0.1),
                  ), // Feedback color
                ),
              ),
              pinned: true, // Keep TabBar visible while scrolling content
            ),

            // --- Tab Content Area ---
            SliverFillRemaining(
              // Use SliverFillRemaining for TabBarView in CustomScrollView
              // hasScrollBody: false, // Set to true if tab content itself needs to scroll independently
              child: TabBarView(
                physics:
                    const BouncingScrollPhysics(), // Allow nice swipe physics
                children: [
                  // == Tab 1: Details ==
                  _buildTabView(context, [
                    // Using helpers to build sections
                    Text(
                      "Event details",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12), // Add space before details
                    _buildDetailRow(
                      Icons.calendar_today_outlined,
                      formattedDate,
                      context,
                    ),
                    _buildDetailRow(
                      Icons.access_time_outlined,
                      formattedTime,
                      context,
                    ),
                    _buildDetailRow(
                      Icons.location_on_outlined,
                      event.location ?? 'N/A',
                      context,
                    ),
                    _buildDetailRow(
                      Icons.confirmation_number_outlined,
                      feeString,
                      context,
                    ),
                    _buildDetailRow(
                      Icons.people_alt_outlined,
                      registrationCount,
                      context,
                    ),
                    if (event.isTeamEvent)
                      _buildDetailRow(
                        Icons.group, // Team icon
                        'Team Event (${event.minTeamSize} - ${event.maxTeamSize} members)', // Text indicating team event and size
                        context,
                      ),
                    const SizedBox(height: 12), // Add space before description
                    // Add Description Section explicitly if not using _buildInfoSection
                    _buildInfoSection(
                      context,
                      "Description",
                      event.description ?? "No description provided.",
                      parseContent: true,
                    ), // Enable parsing for description
                  ]),

                  // == Tab 2: Rules ==
                  _buildTabView(context, [
                    _buildInfoSection(
                      context,
                      "Rules and guidelines",
                      event.rules ?? "",
                      parseContent: true,
                    ),
                  ]),

                  // == Tab 3: Schedule ==
                  _buildTabView(context, [
                    _buildInfoSection(
                      context,
                      "Schedule",
                      event.schedule ?? "",
                      parseContent: true,
                    ),
                  ]),

                  // == Tab 4: Prizes ==
                  _buildTabView(context, [
                    _buildInfoSection(
                      context,
                      "Prizes & Opportunities",
                      event.prizes ?? "",
                      parseContent: true,
                    ),
                  ]),

                  // == Tab 5: Organizers ==
                  _buildTabView(context, [
                    _buildInfoSection(
                      context,
                      "Organizers",
                      event.organizerInfo ?? "",
                      parseContent: true,
                    ),
                    // Parse potential contact info/links
                  ]),
                ],
              ),
            ),
          ],
        ),
        // --- UPDATE Bottom Navigation Bar ---
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    alreadyRegistered
                        ? Colors.grey[600]
                        : colorScheme.primary, // Use theme primary
                foregroundColor: colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 48),
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBackgroundColor: Colors.grey[400],
                disabledForegroundColor: Colors.white70,
              ),
              // --- Disable button or change action based on status ---
              onPressed:
                  alreadyRegistered
                      ? null // Disable if already registered (simple check)
                      // Call the new action handler
                      : () =>
                          _handleRegistrationAction(context, myEventsNotifier),
              // --- END UPDATED onPressed ---
              icon: Icon(
                alreadyRegistered
                    ? Icons.check_circle_outline
                    : Icons.app_registration,
                size: 20,
              ),
              // Label remains the same for now
              label: Text(alreadyRegistered ? 'Registered' : 'Register'),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper class _SliverTabBarDelegate (Keep as is)
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Add a background color to ensure tabs stand out when pinned
    return Container(
      color:
          Theme.of(
            context,
          ).colorScheme.surface, // Use surface color for background
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

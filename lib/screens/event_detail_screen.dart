// lib/screens/event_detail_screen.dart
// REFINED V3 - Distributed Content Across Tabs (Option 2)

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../models/event.dart'; // Ensure Event model is imported

class EventDetailScreen extends StatelessWidget {
  final Event event; // Receive the Event object
  final Logger log = Logger();

  EventDetailScreen({required this.event, super.key});

  // --- Placeholder Actions ---
  void _handleRegistration(BuildContext context) {
    log.i("Simulating registration for event: ${event.eventName}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registered for "${event.eventName}"! (Demo)'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    log.i("Navigate to Profile/Dashboard Tapped (Placeholder)");
    // Example: context.goNamed('studentDashboard'); // Navigate if needed
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile icon tapped (Demo)")));
  }

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    // Placeholder - implement using url_launcher package if needed
    log.i("Attempting to launch URL (disabled): $urlString");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Link tapped (launch disabled): $urlString")),
    );
  }

  // --- Helper Widget Builders ---

  // Builds the colored tags like "Featured", "Academic"
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

  // Builds Icon + Text row for the core event details
  Widget _buildDetailRow(IconData icon, String text, BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
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

  // Builds a content section with title - USED WITHIN EACH TAB NOW
  Widget _buildInfoSection(
    BuildContext context,
    String title,
    String content, {
    bool parseContent = true,
  }) {
    final theme = Theme.of(context);

    // Function to parse content (URLs, bullets)
    List<Widget> buildContentWidgets(String text) {
      if (!parseContent) {
        return [
          Text(
            text,
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
        bool isBullet = line.trim().startsWith(RegExp(r'[•*-]'));
        String displayLine =
            isBullet ? line.trim().substring(1).trim() : line.trim();

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
                    padding: const EdgeInsets.only(right: 8.0, top: 7),
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
        ...buildContentWidgets(content),
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
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // --- Data Formatting & Calculation ---
    final String formattedDate = DateFormat(
      'MMM d, yyyy',
    ).format(event.eventDate);
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
    bool isFeatured = event.tags?.contains('Featured') ?? false;
    bool isAcademic = event.tags?.contains('Academic') ?? false;
    // Determine primary tag logic
    String? primaryTagText;
    Color? primaryTagBgColor;
    Color? primaryTagTextColor;
    if (event.registrationFee != null && event.registrationFee! > 0) {
      primaryTagText = "Paid";
      primaryTagBgColor = Colors.blue[50];
      primaryTagTextColor = Colors.blue[800];
    } else if (event.tags?.contains("Free") ?? false) {
      primaryTagText = "Free";
      primaryTagBgColor = Colors.green[50];
      primaryTagTextColor = Colors.green[800];
    } else if (isFeatured) {
      primaryTagText = "Featured";
      primaryTagBgColor = Colors.yellow[600];
      primaryTagTextColor = Colors.black;
    }
    // Add else if for 'Academic' or other primary tags if needed

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
        backgroundColor: colorScheme.surface,
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
                    Icons.account_circle,
                    color: Colors.blue[800],
                    size: 28,
                  ),
                  tooltip: 'Profile / Dashboard',
                  onPressed: () => _navigateToProfile(context),
                ),
                const SizedBox(width: 8),
              ],
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              elevation: 1.0,
              pinned: true,
              floating: true,
              snap: true,
            ),

            // --- Banner Image ---
            SliverToBoxAdapter(
              child: Container(
                height: 200,
                color: Colors.grey[300],
                child:
                    (event.bannerUrl != null && event.bannerUrl!.isNotEmpty)
                        ? Image.network(
                          event.bannerUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder:
                              (context, child, progress) =>
                                  progress == null
                                      ? child
                                      : const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                          errorBuilder: (context, error, stackTrace) {
                            log.w(
                              "Failed to load banner: ${event.bannerUrl}",
                              error: error,
                              stackTrace: stackTrace,
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
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              // Display determined primary tag OR specific tags like Academic
                              if (primaryTagText != null)
                                _buildTagChip(
                                  primaryTagText,
                                  primaryTagBgColor!,
                                  primaryTagTextColor!,
                                ),
                              if (isAcademic && primaryTagText != 'Academic')
                                _buildTagChip(
                                  'Academic',
                                  Colors.blue[50]!,
                                  Colors.blue[800]!,
                                ), // Show Academic if not primary
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            event.eventName,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (event.department != null &&
                              event.department!.isNotEmpty)
                            Text(
                              "Dept. of ${event.department!}",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
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
                ),
              ),
              pinned: true,
            ),

            // --- Tab Content Area (Distributed) ---
            SliverFillRemaining(
              // Ensure TabBarView itself doesn't scroll if content fits
              // hasScrollBody: false, // Use if content per tab is short
              child: TabBarView(
                physics: const BouncingScrollPhysics(), // Allow swipe physics
                children: [
                  // == Tab 1: Details ==
                  _buildTabView(context, [
                    Text(
                      "Event details",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 24),
                    // Description Section
                    Text(
                      "Description",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description ?? "No description provided.",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ]),

                  // == Tab 2: Rules ==
                  _buildTabView(context, [
                    _buildInfoSection(
                      context,
                      "Rules and guidelines",
                      event.rules ?? "",
                    ),
                  ]),

                  // == Tab 3: Schedule ==
                  _buildTabView(context, [
                    _buildInfoSection(
                      context,
                      "Schedule",
                      event.schedule ?? "",
                    ),
                  ]),

                  // == Tab 4: Prizes ==
                  _buildTabView(context, [
                    _buildInfoSection(
                      context,
                      "Prizes & Opportunities",
                      event.prizes ?? "",
                    ),
                  ]),

                  // == Tab 5: Organizers ==
                  _buildTabView(context, [
                    _buildInfoSection(
                      context,
                      "Organizers",
                      event.organizerInfo ?? "",
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
        // --- Bottom Navigation Bar ---
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
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
              ),
              onPressed: () => _handleRegistration(context),
              child: const Text('Register'),
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
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

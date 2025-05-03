// lib/widgets/event_card.dart
// REFINED V8 - Separate Detail Lines for Standard Cards

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/event.dart'; // Ensure Event model is imported

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final IconData? leadingIconData; // Optional icon
  final Color? leadingIconColor;
  final bool isCompact;
  const EventCard({
    required this.event,
    this.onTap,
    this.leadingIconData,
    this.leadingIconColor,
    this.isCompact = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final List<String> tags = event.tags ?? [];
    String formattedDate = 'Date N/A';
    String timeString = 'Time N/A';
    String location = event.location ?? 'Location N/A'; // Handle null location

    // Safely format date and time
    try {
      // Use slightly longer date format again if space allows
      formattedDate = DateFormat('MMM d, yyyy').format(event.eventDate);
      timeString = DateFormat('h:mm a').format(event.eventDate);
    } catch (e) {
      // print("Error formatting date/time in EventCard: $e");
    }

    // --- Banner Image (Keep as is) ---
    const Widget bannerPlaceholder = SizedBox(
      height: 120, // Consistent height
      width: double.infinity,
      child: Center(
        child: Icon(Icons.image_outlined, color: Colors.grey, size: 40),
      ),
    );
    final Widget bannerWidget =
        (event.bannerUrl != null && event.bannerUrl!.trim().isNotEmpty)
            ? CachedNetworkImage(
              imageUrl: event.bannerUrl!,
              fit: BoxFit.cover,
              height: 120,
              width: double.infinity,
              placeholder:
                  (context, url) => Container(
                    height: 120,
                    color: colorScheme.surfaceContainerLowest,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    height: 120,
                    color: colorScheme.surfaceContainerLowest,
                    child: bannerPlaceholder,
                  ),
            )
            : Container(
              height: 120,
              color: colorScheme.surfaceContainerLowest,
              child: bannerPlaceholder,
            );

    // --- Tag Chip Builder (Keep dense styling) ---
    Widget buildTagChip(String tag) {
      Color chipColor = colorScheme.secondaryContainer.withOpacity(0.5);
      Color chipTextColor = colorScheme.onSecondaryContainer;
      // Add specific color logic if needed...
      if (tag.toLowerCase() == 'free' ||
          tag.toLowerCase() == 'paid' ||
          tag.toLowerCase() == 'career' ||
          tag.toLowerCase() == 'seminar' ||
          tag.toLowerCase() == 'fest') {
        chipColor = const Color.fromARGB(255, 110, 255, 115);
        chipTextColor = Colors.black;
      } else if (tag.toLowerCase() == 'guest lecture' ||
          tag.toLowerCase() == 'social' ||
          tag.toLowerCase() == 'advanced' ||
          tag.toLowerCase() == 'beginner') {
        chipColor = const Color.fromARGB(255, 80, 174, 251);
        chipTextColor = Colors.black;
      } else {
        chipColor = const Color.fromARGB(255, 255, 209, 103);
        chipTextColor = Colors.black;
      }
      return Chip(
        label: Text(tag),
        labelStyle: textTheme.labelSmall?.copyWith(
          fontSize: 10,
          color: chipTextColor,
          fontWeight: FontWeight.w800,
        ),
        backgroundColor: chipColor,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: -2),
        visualDensity: const VisualDensity(horizontal: 0.0, vertical: -4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide.none,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Card height wraps content.
          children: [
            // 1. Banner Image
            bannerWidget,

            // 2. Content Section
            Flexible(
              // <-- Flexible is now direct child of Column
              fit: FlexFit.loose,
              child: Padding(
                // <-- Padding is now inside Flexible
                padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 8.0),
                child: Column(
                  // Inner column for details
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize:
                      MainAxisSize.min, // Inner column wraps its content
                  children: [
                    // -- Row for Tags and Optional Icon --
                    if (tags.isNotEmpty || leadingIconData != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 3.0,
                                runSpacing: 2.0,
                                children:
                                    tags.take(2).map(buildTagChip).toList(),
                              ),
                            ),
                            if (leadingIconData != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Icon(
                                  leadingIconData,
                                  size: 16,
                                  color:
                                      leadingIconColor ?? colorScheme.secondary,
                                ),
                              ),
                          ],
                        ),
                      ),

                    // -- Event Title --
                    Text(
                      event.eventName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.2, // Adjusted line height
                      ),
                      // Allow title to potentially wrap to 2 lines if needed, but keep it constrained
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // *** Increased spacing before details ***
                    const SizedBox(height: 6),

                    // -- Date & Time -- (Separate Line)
                    _buildIconText(
                      Icons.calendar_today_outlined,
                      '$formattedDate • $timeString',
                      context,
                    ),
                    // *** Minimal spacing between details ***
                    const SizedBox(height: 3),

                    // -- Location -- (Separate Line)
                    // -- Location & NEW Team Indicator Row --
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Location part (using helper without Expanded)
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                        ),
                        const SizedBox(width: 5),
                        // Use Flexible to allow location text to take space but not overflow row
                        Flexible(
                          child: Text(
                            location,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                              height: 1.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        // --- NEW: Team Indicator ---
                        if (event.isTeamEvent) // Check if it's a team event
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                            ), // Space before icon
                            child: Tooltip(
                              // Optional: Add tooltip for clarity
                              message:
                                  'Team Event (${event.minTeamSize}-${event.maxTeamSize} members)',
                              child: Icon(
                                Icons.group, // Team icon
                                size: 14, // Slightly larger icon
                                color: colorScheme.primary, // Use theme color
                              ),
                            ),
                          ),
                      ],
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

  // Helper to build icon-text rows (Keep optimized)
  Widget _buildIconText(IconData icon, String text, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center, // Align items vertically centered
      children: [
        Icon(
          icon,
          size: 12,
          color: colorScheme.onSurfaceVariant.withOpacity(0.8),
        ),
        const SizedBox(width: 5), // Slightly more space
        Expanded(
          child: Text(
            text,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
              height: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1, // Keep details to single lines
          ),
        ),
      ],
    );
  }
}

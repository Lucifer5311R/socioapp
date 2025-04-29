// lib/widgets/event_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart'; // Import the consolidated Event model

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final IconData? leadingIconData; // <-- Add optional icon data parameter
  final Color? leadingIconColor; // <-- Add optional icon color

  const EventCard({
    required this.event,
    this.onTap,
    this.leadingIconData, // <-- Add to constructor
    this.leadingIconColor, // <-- Add to constructor
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final List<String> tags = event.tags ?? [];
    String formattedDate = 'Date N/A';
    try {
      formattedDate = DateFormat.yMMMd().format(event.eventDate);
    } catch (_) {
      /* Handle formatting error */
    }
    final String timeString = DateFormat.jm().format(event.eventDate);

    // Banner Placeholder/Image Logic (Keep as is)
    const Widget placeholderIcon = Center(
      child: Icon(Icons.image_outlined, color: Colors.grey, size: 40),
    );
    final Widget bannerWidget =
        (event.bannerUrl != null && event.bannerUrl!.trim().isNotEmpty)
            ? Image.network(
              /* ... banner loading/error logic ... */
              event.bannerUrl!,
              fit: BoxFit.cover,
              height: 120,
              width: double.infinity,
              loadingBuilder:
                  (context, child, progress) =>
                      progress == null
                          ? child
                          : Container(
                            height: 120,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    height: 120,
                    color: Colors.grey[300],
                    child: placeholderIcon,
                  ),
            )
            : Container(
              height: 120,
              color: Colors.grey[300],
              child: placeholderIcon,
            );

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: SizedBox(
          width: 250, // Maintain consistent width for horizontal lists
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bannerWidget,
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Row for Tags and Optional Leading Icon ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          // Tags take available space
                          child: Wrap(
                            spacing: 4.0,
                            runSpacing: 4.0,
                            children:
                                tags
                                    .map(
                                      (tag) => Chip(
                                        /* ... tag chip styling ... */
                                        label: Text(tag),
                                        labelStyle: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue[800],
                                        ),
                                        backgroundColor: Colors.blue[50],
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        side: BorderSide.none,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                        // --- Display Leading Icon if provided ---
                        if (leadingIconData != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                            child: Icon(
                              leadingIconData,
                              size: 18,
                              color:
                                  leadingIconColor ??
                                  Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                      ],
                    ),
                    if (tags.isNotEmpty || leadingIconData != null)
                      const SizedBox(
                        height: 8,
                      ), // Add spacing if tags or icon shown
                    // --- Event Title ---
                    Text(
                      event.eventName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // --- Date/Time and Location Rows (Keep as is) ---
                    _buildIconText(
                      Icons.calendar_today_outlined,
                      '$formattedDate | $timeString',
                      context,
                    ),
                    const SizedBox(height: 4),
                    _buildIconText(
                      Icons.location_on_outlined,
                      event.location ?? 'Location N/A',
                      context,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build icon-text rows (Keep as is)
  Widget _buildIconText(IconData icon, String text, BuildContext context) {
    // ... (keep implementation)
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

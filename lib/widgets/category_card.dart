// lib/widgets/category_card.dart
// REFINED V2 - Using FittedBox for Responsiveness

import 'package:flutter/material.dart';
import '../models/category.dart'; // Import the Category model

class CategoryCard extends StatelessWidget {
  final Category categoryData;
  final VoidCallback? onTap;

  const CategoryCard({required this.categoryData, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Determine card background color from theme
    final cardBackgroundColor =
        theme.cardTheme.color ?? colorScheme.surfaceContainerLow;
    // Determine appropriate text colors based on the card's background
    final primaryTextColor = colorScheme.onSurface;
    final secondaryTextColor = colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0), // Match InkWell radius to Card
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          // Optional: Add a subtle border in dark mode
          side:
              theme.brightness == Brightness.dark
                  ? BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.3),
                    width: 0.5,
                  )
                  : BorderSide.none,
        ),
        color: cardBackgroundColor, // Use theme color
        clipBehavior:
            Clip.antiAlias, // Helps ensure content respects border radius
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Reduced padding
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center content vertically
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Use Flexible for the Icon space to allow it to take proportional space
              Flexible(
                flex: 2, // Give icon slightly more proportional space
                child: FractionallySizedBox(
                  // Constrain icon size relative to its allocated space
                  widthFactor:
                      0.55, // Allows icon to be up to 55% of card width
                  heightFactor:
                      0.55, // Allows icon to be up to 55% of its vertical space
                  child: FittedBox(
                    // Scales the icon down to fit within the FractionallySizedBox
                    fit: BoxFit.contain, // Ensures entire icon is visible
                    child: Icon(
                      categoryData.icon,
                      color: colorScheme.primary, // Use primary color for icon
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4), // Reduced spacing
              // Use Flexible for the text block space
              Flexible(
                flex: 1, // Give text slightly less proportional space
                child: FittedBox(
                  // Scale the text block down ONLY if necessary
                  fit:
                      BoxFit
                          .scaleDown, // Prevents text becoming tiny unless space is very tight
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Column wraps text height
                    children: [
                      Text(
                        categoryData.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          // Use bodyMedium for clear title
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1, // Ensure single line
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1), // Minimal spacing
                      Text(
                        categoryData.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: secondaryTextColor,
                          fontSize: 10, // Keep subtitle small
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1, // Ensure single line
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

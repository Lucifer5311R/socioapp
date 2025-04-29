// lib/widgets/category_card.dart

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
    // Determine card background color from theme's cardTheme or fallback
    // This allows it to respect the darkTheme definition in main.dart
    final cardBackgroundColor =
        theme.cardTheme.color ?? colorScheme.surfaceContainerLow;
    // Determine appropriate text colors based on the card's background
    final primaryTextColor = colorScheme.onSurface;
    final secondaryTextColor = colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0), // Slightly larger radius
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          // Optional: Add a subtle border in dark mode for definition
          side:
              theme.brightness == Brightness.dark
                  ? BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.3),
                    width: 0.5,
                  )
                  : BorderSide.none,
        ),
        // REMOVED hardcoded color: Colors.grey[100],
        // Let the Card use the color from the ThemeData (via cardTheme or default)
        // You can explicitly set it to use theme if needed:
        color: cardBackgroundColor, // Ensures it uses theme color
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                categoryData.icon,
                size: 30,
                // Use primary color, should contrast well on most backgrounds
                color: colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                categoryData.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor, // Use theme-aware text color
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                categoryData.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: secondaryTextColor, // Use theme-aware text color
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

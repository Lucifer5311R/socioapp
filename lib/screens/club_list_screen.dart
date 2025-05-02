// lib/screens/club_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/club_centre.dart'; // Import the model

class ClubListScreen extends StatelessWidget {
  const ClubListScreen({super.key});

  // --- Placeholder Data (Extracted Manually from PDF) ---
  // TODO: Replace this with data fetched from Supabase or another backend
  final List<ClubCentre> clubCentreData = const [
    ClubCentre(
      name: 'Centre for Neurodiversity Research and Innovation',
      abbreviation: 'CNRI',
      description:
          'Aims to enhance the understanding and support for neurodiverse individuals by fostering research and innovation.',
      // logoAsset: 'assets/logos/cnri.png', // Example asset path
    ),
    ClubCentre(
      name: 'Centre for Academic and Professional Support',
      abbreviation: 'CAPS',
      description:
          'Provides academic and professional training, resources, and talks designed to support students\' academic excellence and career development.',
      // logoAsset: 'assets/logos/caps.png',
    ),
    ClubCentre(
      name: 'Centre for Advanced Research and Development',
      abbreviation: 'CARD',
      description:
          'Fosters a culture of innovation and academic research by promoting interdisciplinary research and collaboration.',
      // logoAsset: 'assets/logos/card.png',
    ),
    ClubCentre(
      name: 'Centre for Artificial Intelligence',
      abbreviation: 'CAI',
      description:
          'Dedicated to advancing education, research, and innovation in the field of artificial intelligence, focusing on practical applications.',
      // logoAsset: 'assets/logos/cai.png',
    ),
    ClubCentre(
      name: 'Centre for Concept Design',
      abbreviation: 'CCD',
      description:
          'Emphasizes the importance of effective communication through media, content, and digital services. Nurtures creativity.',
      // logoAsset: 'assets/logos/ccd.png',
    ),
    ClubCentre(
      name: 'Centre for Counselling and Health Services',
      abbreviation: 'CCHS',
      description:
          'Offers a range of services to support the mental and physical well-being of students, including counseling and health support.',
      // logoAsset: 'assets/logos/cchs.png',
    ),
    ClubCentre(
      name: 'Centre for Digital Innovation',
      abbreviation: 'CDI',
      description:
          'Focuses on bridging the gap between academia and industry by promoting collaborations in information technology.',
      // logoAsset: 'assets/logos/cdi.png',
    ),
    ClubCentre(
      name: 'Centre for East Asian Studies',
      abbreviation: 'CEAS',
      description:
          'Dedicated to enhancing understanding of East Asian cultures, societies, and international relations, particularly with India.',
      // logoAsset: 'assets/logos/ceas.png',
    ),
    ClubCentre(
      name: 'Centre for Education Beyond Curriculum',
      abbreviation:
          'CEDRIC', // Note: PDF shows CEDBEC, text says CEDRIC - using text
      description:
          'Promotes experiential learning and progressive education models that go beyond traditional curricular frameworks.',
      // logoAsset: 'assets/logos/cedric.png',
    ),
    ClubCentre(
      name: 'Centre for Indian and Foreign Languages',
      abbreviation: 'CIFL',
      description:
          'Offers courses in a wide range of Indian and global languages, focusing on linguistic diversity and cultural exchange.',
      // logoAsset: 'assets/logos/cifl.png',
    ),
    ClubCentre(
      name: 'Centre for Korean Studies',
      abbreviation: 'CKS',
      description:
          'Fosters academic and cultural ties between India and Korea, offering specialized studies on Korea\'s history, language, culture, and economy.',
      // logoAsset: 'assets/logos/cks.png',
    ),
    ClubCentre(
      name: 'Centre for Placement and Career Guidance',
      abbreviation: 'CPCG',
      description:
          'Dedicated to supporting students in their career development and placement process through counseling, internships, and workshops.',
      // logoAsset: 'assets/logos/cpcg.png',
    ),
    ClubCentre(
      name: 'Centre for Publications',
      abbreviation: 'CPUB',
      description:
          'Plays a key role in advancing academic knowledge by publishing journals, books, and papers across various disciplines.',
      // logoAsset: 'assets/logos/cpub.png',
    ),
    ClubCentre(
      name: 'Centre for Research',
      abbreviation: 'CR',
      description:
          'Coordinates and promotes academic research within the university, fostering innovation and interdisciplinary research.',
      // logoAsset: 'assets/logos/cr.png',
    ),
    ClubCentre(
      name: 'Centre for Service Learning',
      abbreviation: 'CSL',
      description:
          'Promotes experiential learning through community service, encouraging social responsibility and application of academic knowledge.',
      // logoAsset: 'assets/logos/csl.png',
    ),
    ClubCentre(
      name: 'Centre for Social Action',
      abbreviation: 'CSA',
      description:
          'Engages students in developmental volunteerism, encouraging participation in activities that contribute to social causes.',
      // logoAsset: 'assets/logos/csa.png',
    ),
    // ... Add ALL other Centres and Clubs from the PDF ...
    // Example for a club from Page 13:
    ClubCentre(
      name: 'Finance and Investment Cell',
      abbreviation: 'FIC', // Assuming abbreviation
      description:
          'Focuses on finance, investment strategies, market analysis, and related activities.', // Example description
      // logoAsset: 'assets/logos/fic.png',
    ),
    ClubCentre(
      name: 'Mirai Tech Club',
      abbreviation: 'Mirai', // Assuming abbreviation
      description:
          'A club dedicated to exploring technology, coding, and innovation.', // Example description
      // logoAsset: 'assets/logos/mirai.png',
    ),
    // Add entries for all clubs listed on page 13/14
  ];
  // --- End Placeholder Data ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Centres & Clubs'),
        // Automatically includes back button if navigable
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: clubCentreData.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = clubCentreData[index];
          // Animate each item
          return _ClubListItem(
                item: item,
              ) // Use a dedicated widget for the item
              .animate(delay: (100 * index).ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, duration: 300.ms);
        },
      ),
    );
  }
}

// Widget for displaying a single club/centre item
class _ClubListItem extends StatelessWidget {
  final ClubCentre item;

  const _ClubListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Placeholder for logo
    Widget logoPlaceholder = Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          item.abbreviation,
          style: TextStyle(
            color: colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Make the card tappable
        onTap: () {
          // TODO: Implement navigation to a club-specific detail screen if needed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Tapped on ${item.name} (Detail page TBD)")),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Area
              item.logoAsset != null
                  ? ClipRRect(
                    // Use ClipRRect if using Image.asset
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      item.logoAsset!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      // Add error builder for asset images if necessary
                      errorBuilder:
                          (context, error, stackTrace) => logoPlaceholder,
                    ),
                  )
                  : logoPlaceholder, // Show placeholder if no asset path
              const SizedBox(width: 12),
              // Details Area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 3, // Limit description lines in the list
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Optional: Add a trailing icon like chevron_right
              // Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

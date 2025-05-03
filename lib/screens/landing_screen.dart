import 'dart:async';
import 'dart:math'; // For random animation delays and pi

import 'package:flutter/gestures.dart'; // For RichText links
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';

// --- LandingScreen Widget ---
// (No changes needed in the main LandingScreen widget itself)
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final verticalPadding = screenHeight * 0.03;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: verticalPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Top Section: Title & Tagline ---
              Flexible(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SOCIO.',
                      style: textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                    const SizedBox(height: 12),
                    Text(
                          'Discover, register, and experience campus events like never before.',
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 500.ms)
                        .slideY(begin: 0.2),
                  ],
                ),
              ),

              // --- Middle Section: Animated PageView Carousel ---
              const Flexible(flex: 8, child: AnimatedGraphicCarousel()),

              // --- Bottom Section: Buttons & Links ---
              Flexible(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                          ),
                          onPressed: () => context.goNamed('publicDiscover'),
                          child: const Text('Explore Events'),
                        )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 500.ms)
                        .slideY(begin: 0.5),
                    const SizedBox(height: 15),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () => context.goNamed('login'),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 700.ms, duration: 500.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Carousel Widget using PageView ---
class AnimatedGraphicCarousel extends StatefulWidget {
  const AnimatedGraphicCarousel({super.key});

  @override
  State<AnimatedGraphicCarousel> createState() =>
      _AnimatedGraphicCarouselState();
}

class _AnimatedGraphicCarouselState extends State<AnimatedGraphicCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  Timer? _timer;
  int _currentPage = 0;

  // --- MODIFIED: Added title and subtitle to page data ---
  final List<Map<String, dynamic>> _pageData = [
    {
      'centralIcon': Icons.explore_outlined,
      'centralIconColor': Colors.blue.shade600,
      'surroundingIcons': const [
        Icons.music_note,
        Icons.sports_soccer,
        Icons.computer,
        Icons.school,
        Icons.festival,
      ],
      'title': "Discover Events", // Added text
      'subtitle': "Find activities matching your interests.", // Added text
    },
    {
      'centralIcon': Icons.how_to_reg_outlined,
      'centralIconColor': Colors.green.shade600,
      'surroundingIcons': const [
        Icons.article_outlined,
        Icons.group_add_outlined,
        Icons.payment,
        Icons.verified_user_outlined,
        Icons.edit_note,
      ],
      'title': "Easy Registration", // Added text
      'subtitle': "Sign up for events in just a few taps.", // Added text
    },
    {
      'centralIcon': Icons.notifications_active_outlined,
      'centralIconColor': Colors.orange.shade700,
      'surroundingIcons': const [
        Icons.calendar_today,
        Icons.access_time,
        Icons.location_on_outlined,
        Icons.campaign_outlined,
        Icons.alarm,
      ],
      'title': "Stay Updated", // Added text
      'subtitle': "Get timely reminders & notifications.", // Added text
    },
    {
      'centralIcon': Icons.groups_2_outlined,
      'centralIconColor': Colors.purple.shade600,
      'surroundingIcons': const [
        Icons.forum_outlined,
        Icons.celebration,
        Icons.emoji_events,
        Icons.handshake_outlined,
        Icons.volunteer_activism,
      ],
      'title': "Connect & Engage", // Added text
      'subtitle': "Join clubs, participate, and earn badges.", // Added text
    },
  ];

  late final int _totalPages;

  @override
  void initState() {
    super.initState();
    _totalPages = _pageData.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _totalPages > 1) {
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timerInstance) {
      if (!mounted) {
        timerInstance.cancel();
        return;
      }
      if (_totalPages > 1) {
        _currentPage = (_currentPage + 1) % _totalPages;
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutQuad,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _totalPages,
            itemBuilder: (context, index) {
              final data = _pageData[index];
              // *** FIX APPLIED HERE ***
              // Use null-coalescing operator (??) to provide default values
              return _AnimatedGraphicPage(
                key: ValueKey('page_$index'),
                centralIcon:
                    data['centralIcon']
                        as IconData, // Assuming these are never null in your data
                centralIconColor:
                    data['centralIconColor']
                        as Color, // Assuming these are never null
                surroundingIcons:
                    data['surroundingIcons']
                        as List<IconData>, // Assuming these are never null
                title: data['title'] as String? ?? '', // Provide '' if null
                subtitle:
                    data['subtitle'] as String? ?? '', // Provide '' if null
              );
              // *** END OF FIX ***
            },
            onPageChanged: (index) {
              if (mounted) {
                setState(() {
                  _currentPage = index;
                });
              }
              _startTimer();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
          child: AnimatedSmoothIndicator(
            activeIndex: _currentPage,
            count: _totalPages,
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              spacing: 6,
              activeDotColor: colorScheme.primary,
              dotColor: colorScheme.onSurface.withOpacity(0.2),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Updated StatefulWidget for the content of a single page ---
class _AnimatedGraphicPage extends StatefulWidget {
  final IconData centralIcon;
  final Color centralIconColor;
  final List<IconData> surroundingIcons;
  final String title; // Added title
  final String subtitle; // Added subtitle

  const _AnimatedGraphicPage({
    super.key,
    required this.centralIcon,
    required this.centralIconColor,
    required this.surroundingIcons,
    required this.title, // Added title
    required this.subtitle, // Added subtitle
  });

  @override
  State<_AnimatedGraphicPage> createState() => _AnimatedGraphicPageState();
}

class _AnimatedGraphicPageState extends State<_AnimatedGraphicPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 650;
    final textTheme = Theme.of(context).textTheme;

    // Adjust base sizes
    final double centralIconBaseSize = isSmallScreen ? 55.0 : 70.0;
    final double surroundingIconBaseSize = isSmallScreen ? 30.0 : 40.0;

    // Reserve some estimated space for text at the bottom when calculating radius
    final double estimatedTextHeight = isSmallScreen ? 50 : 60;
    final availableDiameter = min(
      screenSize.width * 0.7,
      screenSize.height * 0.4 - estimatedTextHeight,
    );
    final radius = max(
      availableDiameter / 2.0 * 0.8,
      50.0,
    ); // Ensure radius doesn't get too small

    // Scale font sizes relative to base sizes or screen width
    final double titleFontSize = isSmallScreen ? 15 : 17;
    final double subtitleFontSize = isSmallScreen ? 11 : 12;

    return Column(
      // Use Column to stack graphic and text
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // --- Graphic Area ---
        Expanded(
          // Let the graphic stack take most of the space
          child: Center(
            child: SizedBox(
              width: radius * 2 + surroundingIconBaseSize,
              height: radius * 2 + surroundingIconBaseSize,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Central Icon
                  Icon(
                        widget.centralIcon,
                        size: centralIconBaseSize,
                        color: widget.centralIconColor,
                      )
                      .animate(
                        onPlay:
                            (controller) => controller.repeat(reverse: true),
                      )
                      .scaleXY(
                        begin: 0.95,
                        end: 1.05,
                        duration: 2200.ms,
                        curve: Curves.easeInOutSine,
                      )
                      .then(delay: 200.ms)
                      .tint(
                        color: Colors.white.withOpacity(0.3),
                        duration: 2200.ms,
                        curve: Curves.easeInOut,
                      )
                      .then(delay: 200.ms),

                  // Surrounding Icons
                  ...List.generate(widget.surroundingIcons.length, (index) {
                    final angle =
                        (2 * pi / widget.surroundingIcons.length) * index -
                        (pi / 2);
                    final x = radius * cos(angle);
                    final y = radius * sin(angle);
                    final randomSeed = Random(index);
                    final randomDelay = (randomSeed.nextDouble() * 500).ms;
                    final moveDuration =
                        (randomSeed.nextDouble() * 600 + 1200).ms;
                    final scaleDuration =
                        (randomSeed.nextDouble() * 500 + 1000).ms;
                    final rotateDuration =
                        (randomSeed.nextDouble() * 800 + 1400).ms;

                    return Transform.translate(
                      offset: Offset(x, y),
                      child: Icon(
                            widget.surroundingIcons[index],
                            size: surroundingIconBaseSize,
                            color: widget.centralIconColor.withOpacity(0.65),
                          )
                          .animate(
                            delay:
                                400.ms +
                                Duration(milliseconds: index * 50) +
                                randomDelay,
                            onPlay:
                                (controller) =>
                                    controller.repeat(reverse: true),
                          )
                          .move(
                            begin: Offset.zero,
                            end: Offset(
                              randomSeed.nextDouble() * 6 - 3,
                              randomSeed.nextDouble() * 6 - 3,
                            ),
                            duration: moveDuration,
                            curve: Curves.easeInOut,
                          )
                          .scaleXY(
                            begin: 0.9,
                            end: 1.1,
                            duration: scaleDuration,
                            curve: Curves.easeInOutSine,
                          )
                          .rotate(
                            begin: -0.05,
                            end: 0.05,
                            duration: rotateDuration,
                            curve: Curves.easeInOut,
                          )
                          .then(delay: (randomSeed.nextDouble() * 300).ms),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),

        // --- Text Area ---
        Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
            bottom: 5.0,
            left: 8.0,
            right: 8.0,
          ), // Padding around text
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap text content
            children: [
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  // Use titleMedium
                  fontWeight: FontWeight.bold,
                  color: widget.centralIconColor, // Use consistent color
                  fontSize: titleFontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).animate().fadeIn(delay: 100.ms), // Slight fade-in for text
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  // Use bodyMedium
                  color: widget.centralIconColor.withOpacity(
                    0.8,
                  ), // Slightly lighter
                  fontSize: subtitleFontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).animate().fadeIn(delay: 200.ms), // Staggered fade-in
            ],
          ),
        ),
      ],
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Top Section: Title ---
              Column(
                children: [
                  Text(
                    'SOCIO.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                          fontSize: 32,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Discover, register, and experience campus events like never before.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          color: Colors.blue[600],
                        ),
                  ),
                ],
              ),

              // --- Carousel Section ---
              const AutoCarousel(),

              // --- Bottom Section: Buttons ---
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => context.goNamed('publicDiscover'),
                    child: const Text('Get started'),
                  ),
                  const SizedBox(height: 15),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colors.blueAccent, width: 1.5),
                      foregroundColor: Colors.blue[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => context.goNamed('publicDiscover'),
                    child: const Text('Explore'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => context.goNamed('login'),
                        child: const Text('Log in'),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text('|', style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () => context.goNamed('signup'),
                        child: const Text('Sign up'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AutoCarousel extends StatefulWidget {
  const AutoCarousel({super.key});

  @override
  State<AutoCarousel> createState() => _AutoCarouselState();
}

class _AutoCarouselState extends State<AutoCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  late Timer _timer;
  int _currentPage = 0;
  final int _totalPages = 5;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _currentPage = (_currentPage + 1) % _totalPages;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _totalPages,
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'App Illustration / Carousel Slide',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SmoothPageIndicator(
          controller: _pageController,
          count: _totalPages,
          effect: const WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            spacing: 6,
            activeDotColor: Colors.black,
          ),
        ),
      ],
    );
  }
}

// lib/screens/landing_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Import flutter_animate

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme for consistent styling

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Top Section: Logo and Title ---
              Column(
                children: [
                  // Animate the Logo
                  Text(
                        'SOCIO.',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800], // Adjusted Color
                          fontSize: 32, // Larger Font
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 200.ms) // Fade in first
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 400.ms,
                      ), // Slide up slightly

                  const SizedBox(height: 20),

                  // Animate the Subtitle
                  Text(
                        'Discover, register, and experience campus events like never before.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: GoogleFonts.lato().fontFamily,
                          fontSize: 18, // Adjusted Font Size
                          color: Colors.blue[600], // Adjusted Color
                        ),
                      )
                      .animate()
                      .fadeIn(
                        duration: 500.ms,
                        delay: 400.ms,
                      ) // Fade in after logo
                      .slideY(begin: 0.2, end: 0, duration: 400.ms),
                ],
              ),

              // --- Middle Section: Illustration Placeholder ---
              // Animate the Illustration Box
              Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100], // Changed Color
                      borderRadius: BorderRadius.circular(
                        20,
                      ), // Adjusted Radius
                      boxShadow: [
                        // Optional: Add a subtle shadow
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'App Illustration/Image Placeholder',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 600.ms) // Fade in later
                  .scaleXY(
                    begin: 0.8,
                    end: 1.0,
                    duration: 500.ms,
                  ), // Scale up effect
              // --- Bottom Section: Buttons ---
              // Animate the entire bottom section together
              Column(
                    children: [
                      // Get Started Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.blue[600], // Changed Color
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          print("Get Started button tapped!");
                          context.goNamed('publicDiscover');
                        },
                        child: const Text('Get started'),
                      ),
                      const SizedBox(height: 15),

                      // Explore Button
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(
                            color: Colors.blueAccent,
                            width: 1.5,
                          ),
                          foregroundColor: Colors.blue[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          context.goNamed('publicDiscover');
                        },
                        child: const Text('Explore'),
                      ),
                      const SizedBox(height: 20),

                      // Login / Sign up Links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => context.goNamed('login'),
                            child: const Text('Log in'),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              '|',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.goNamed('signup'),
                            child: const Text('Sign up'),
                          ),
                        ],
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 800.ms) // Fade in last
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: 500.ms,
                  ), // Slide up from further down
            ],
          ),
        ),
      ),
    );
  }
}

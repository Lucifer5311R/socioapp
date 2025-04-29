// lib/main.dart

import 'dart:async'; // Required for StreamSubscription

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import your screen files
// Ensure these paths match your project structure
import 'screens/landing_screen.dart';
import 'models/event.dart'; // Import Event model
import 'screens/public_discover_screen.dart';
import 'screens/auth_screen.dart'; // Handles Login
import 'screens/signup_screen.dart'; // Handles Sign Up
import 'screens/profile_edit_screen.dart'; // Handles Profile Editing
import 'screens/complete_profile_screen.dart'; // Handles initial profile completion
import 'screens/home_screen.dart';
import 'screens/student_dashboard_screen.dart'; // Ensure this file exports StudentDashboardScreen class
import 'screens/event_detail_screen.dart'
    as event_detail; // Import your EventDetailScreen file here with prefix

// --- Helper class for GoRouter refresh (Keep as is) ---
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners(); // Notify initial state
    _subscription = stream.asBroadcastStream().listen(
      (dynamic event) {
        print('>>> GoRouterRefreshStream received auth event: $event');
        notifyListeners(); // Notify on any stream event
      },
      onError: (dynamic error) {
        // Also log errors
        print(
          '>>> GoRouterRefreshStream error listening to auth stream: $error',
        );
      },
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel(); // Cancel the stream subscription on dispose
    super.dispose();
  }
}

// --- Helper Function to Check Profile Completion (Keep as is) ---
Future<bool?> _isProfileComplete() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    return null; // Not logged in
  }

  try {
    final data =
        await supabase
            .from('profiles')
            .select(
              'register_no, department',
            ) // Select fields needed for completion check
            .eq('user_id', user.id)
            .maybeSingle(); // Use maybeSingle to handle no profile found

    if (data == null) {
      print('--- Profile Check: No profile found for user ${user.id} ---');
      return false; // No profile row exists = incomplete
    }

    // Check if essential fields are present and not empty/null
    final regNo = data['register_no'];
    final dept = data['department'];
    final bool complete =
        (regNo != null && regNo.toString().trim().isNotEmpty) &&
        (dept != null && dept.toString().trim().isNotEmpty);

    print('--- Profile Check: User ${user.id}, Complete: $complete ---');
    return complete;
  } catch (e) {
    print('--- ERROR checking profile completion: $e ---');
    return null; // Error occurred during check
  }
}

// --- GoRouter Configuration (Keep as is) ---
late final GoRouter _router; // Make it late final

// Initialize GoRouter (Keep as is)
void _initializeRouter() {
  _router = GoRouter(
    initialLocation: '/landing', // Start at your landing screen
    debugLogDiagnostics: true, // Helpful for debugging routes
    routes: <RouteBase>[
      // --- Define all your application routes ---
      GoRoute(
        path: '/landing',
        name: 'landing',
        builder:
            (BuildContext context, GoRouterState state) =>
                const LandingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder:
            (BuildContext context, GoRouterState state) =>
                const AuthScreen(isSignUp: false),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder:
            (BuildContext context, GoRouterState state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/complete-profile',
        name: 'completeProfile',
        builder:
            (BuildContext context, GoRouterState state) =>
                const CompleteProfileScreen(),
      ),
      GoRoute(
        path: '/profile-edit',
        name: 'profileEdit',
        builder:
            (BuildContext context, GoRouterState state) =>
                const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/discover',
        name: 'discover',
        builder:
            (BuildContext context, GoRouterState state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/student-dashboard',
        name: 'studentDashboard',
        builder:
            (BuildContext context, GoRouterState state) =>
                const StudentDashboardScreen(), // Added const
      ),
      GoRoute(
        path: '/public-discover',
        name: 'publicDiscover',
        builder:
            (BuildContext context, GoRouterState state) =>
                const PublicDiscoverScreen(),
      ),
      GoRoute(
        path: '/', // Root route
        name: 'home',
        builder:
            (BuildContext context, GoRouterState state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/event/:eventId', // Keep path structure
        name: 'eventDetail',
        builder: (BuildContext context, GoRouterState state) {
          final Event? event = state.extra as Event?;
          if (event == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(
                child: Text('Event data not found. Please go back.'),
              ),
            );
          }
          return event_detail.EventDetailScreen(event: event);
        },
      ),
    ],

    // --- UPDATED Redirect logic (Keep as is) ---
    redirect: (BuildContext context, GoRouterState state) async {
      final supabase = Supabase.instance.client;
      final bool loggedIn = supabase.auth.currentSession != null;
      final String currentLocation = state.matchedLocation;
      final String targetLocation = state.uri.toString();

      final bool onPublicRoute =
          targetLocation == '/landing' || targetLocation == '/public-discover';
      final bool onAuthFlowRoute =
          targetLocation == '/login' || targetLocation == '/signup';
      final bool onCompleteProfileRoute = targetLocation == '/complete-profile';

      print(
        'Redirect check: loggedIn=$loggedIn, Location=$currentLocation, Target=$targetLocation',
      );

      bool? profileComplete;
      if (loggedIn) {
        profileComplete = await _isProfileComplete();
        if (profileComplete == null) {
          print(
            "Profile completion check failed or user not found, treating as incomplete.",
          );
          profileComplete = false;
        }
      }

      if (!loggedIn) {
        if (onPublicRoute || onAuthFlowRoute) {
          return null;
        } else {
          print(
            'Redirecting to /landing (not logged in, accessing protected route)',
          );
          return '/landing';
        }
      } else {
        // Logged In
        if (profileComplete == false) {
          if (!onCompleteProfileRoute) {
            print(
              'Redirecting to /complete-profile (logged in, profile incomplete)',
            );
            return '/complete-profile';
          }
          return null;
        } else {
          // Logged In and Profile Complete
          if (onAuthFlowRoute || onCompleteProfileRoute || onPublicRoute) {
            print(
              'Redirecting to / (logged in, profile complete, accessing auth/complete/public)',
            );
            return '/';
          }
          return null;
        }
      }
    },

    // Listen for auth state changes (Keep as is)
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
  );
}

// --- NEW: Theme Manager ---
// Using ValueNotifier for simplicity. Replace with Provider/Riverpod if you prefer.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(
  ThemeMode.system,
); // Default to system theme

// --- Main App Entry Point ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://srmirwkdbcktvlyflvdi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNybWlyd2tkYmNrdHZseWZsdmRpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU0ODg5NDgsImV4cCI6MjA2MTA2NDk0OH0.z2qvwaO0qV3meul-QUmpEpsLoyZXwvqpm9FeTsSc0co',
  );
  _initializeRouter(); // Initialize router AFTER Supabase
  runApp(const MyApp());
}

// --- Root Application Widget ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- UPDATED: Use ValueListenableBuilder to react to theme changes ---
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        // Define the light theme
        final lightTheme = ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueAccent,
            brightness: Brightness.light, // Explicitly set brightness
          ),
          textTheme: GoogleFonts.latoTextTheme(
            ThemeData.light().textTheme,
          ), // Use light base
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          // Add other light theme specific customizations
        );

        // Define the dark theme
        final darkTheme = ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueAccent,
            brightness: Brightness.dark, // Explicitly set brightness
          ),
          textTheme: GoogleFonts.latoTextTheme(
            ThemeData.dark().textTheme,
          ), // Use dark base
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          // Add other dark theme specific customizations
          // Example: Different Card color
          cardTheme: CardTheme(
            color: Colors.grey[850], // Darker card background
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Colors.grey[700], // Darker chips
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
        );

        return MaterialApp.router(
          title: 'SOCIO App',
          theme: lightTheme, // Provide light theme
          darkTheme: darkTheme, // Provide dark theme
          themeMode: mode, // Control theme mode using the notifier
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

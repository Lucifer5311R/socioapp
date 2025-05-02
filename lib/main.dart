// lib/main.dart
// FINAL VERSION - Includes Provider Setup for MyEventsNotifier

import 'dart:async'; // Required for StreamSubscription

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // <-- Import Provider
import 'package:supabase_flutter/supabase_flutter.dart';

// Import your screen files
import 'screens/landing_screen.dart';
import 'models/event.dart'; // Import Event model
import 'screens/public_discover_screen.dart';
import 'screens/auth_screen.dart'; // Handles Login
import 'screens/signup_screen.dart'; // Handles Sign Up
import 'screens/profile_edit_screen.dart'; // Handles Profile Editing
import 'screens/complete_profile_screen.dart'; // Handles initial profile completion
import 'screens/home_screen.dart'; // Imports HomeScreen and HomeScreenWrapper
import 'screens/student_dashboard_screen.dart';
import 'screens/event_detail_screen.dart'
    as event_detail; // Import your EventDetailScreen file here with prefix

// --- IMPORT THE MY EVENTS NOTIFIER ---
import 'notifiers/my_events_notifier.dart';
// ------------------------------------

// --- Helper class for GoRouter refresh ---
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

// --- Helper Function to Check Profile Completion ---
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
              'register_no, department', // Select fields needed for completion check
            )
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

// --- GoRouter Configuration ---
late final GoRouter _router; // Make it late final

// Initialize GoRouter
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
        path: '/discover', // Often used as the main authenticated entry point
        name: 'discover',
        builder:
            (BuildContext context, GoRouterState state) =>
                const HomeScreenWrapper(), // Use Wrapper
      ),
      GoRoute(
        path: '/student-dashboard',
        name: 'studentDashboard',
        builder:
            (BuildContext context, GoRouterState state) =>
                const StudentDashboardScreen(),
      ),
      GoRoute(
        path: '/public-discover',
        name: 'publicDiscover',
        builder:
            (BuildContext context, GoRouterState state) =>
                const PublicDiscoverScreen(),
      ),
      GoRoute(
        path: '/', // Root route often points to home after login
        name: 'home',
        builder:
            (BuildContext context, GoRouterState state) =>
                const HomeScreenWrapper(), // Use Wrapper
      ),
      GoRoute(
        path: '/event/:eventId', // Keep path structure
        name: 'eventDetail',
        builder: (BuildContext context, GoRouterState state) {
          final Event? event = state.extra as Event?;
          if (event == null) {
            // Maybe redirect to a generic error page or back
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(
                child: Text('Event data not found. Please go back.'),
              ),
            );
          }
          // Use alias for clarity
          return event_detail.EventDetailScreen(event: event);
        },
      ),
    ],

    // --- Redirect logic ---
    redirect: (BuildContext context, GoRouterState state) async {
      final supabase = Supabase.instance.client;
      final bool loggedIn = supabase.auth.currentSession != null;
      final String currentLocation = state.matchedLocation;
      final String targetLocation = state.uri.toString();

      final bool onPublicRoute = [
        '/landing',
        '/public-discover',
      ].contains(currentLocation);
      final bool onAuthFlowRoute = [
        '/login',
        '/signup',
      ].contains(currentLocation);
      final bool onCompleteProfileRoute =
          currentLocation == '/complete-profile';

      print(
        'Redirect check: loggedIn=$loggedIn, Location=$currentLocation, Target=$targetLocation',
      );

      bool? profileComplete;
      if (loggedIn) {
        profileComplete = await _isProfileComplete();
        profileComplete ??= false;
      }

      if (!loggedIn) {
        if (onPublicRoute || onAuthFlowRoute) return null;
        print(
          'Redirecting to /landing (not logged in, accessing protected route)',
        );
        return '/landing';
      } else {
        // User is logged in
        if (profileComplete == false) {
          if (!onCompleteProfileRoute) {
            print(
              'Redirecting to /complete-profile (logged in, profile incomplete)',
            );
            return '/complete-profile';
          }
          return null; // Allow if already on complete profile
        } else {
          // Profile is complete
          if (onAuthFlowRoute ||
              onCompleteProfileRoute ||
              currentLocation == '/landing') {
            print(
              'Redirecting to / (logged in, profile complete, accessing auth/complete/landing)',
            );
            return '/'; // Redirect to home ('/')
          }
          return null; // Allow access to other routes
        }
      }
    },

    // Listen for auth state changes
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
  );
}

// --- Theme Manager ---
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

// --- Colors ---
const Color darkBlue = Color(0xFF063168);
const Color mediumBlue = Color(0xFF154CB3);
const Color brightYellow = Color(0xFFFFCC00);
const Color lightGray = Color(0xFFF5F5F5);
const Color mediumGray = Color(0xFFCCCCCC);
const Color darkGray = Color(0xFF888888);
const Color white = Color(0xFFFFFFFF);

// --- Main App Entry Point ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://srmirwkdbcktvlyflvdi.supabase.co', // YOUR SUPABASE URL
    // --- REPLACE PLACEHOLDER WITH YOUR ACTUAL ANON KEY ---
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNybWlyd2tkYmNrdHZseWZsdmRpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU0ODg5NDgsImV4cCI6MjA2MTA2NDk0OH0.z2qvwaO0qV3meul-QUmpEpsLoyZXwvqpm9FeTsSc0co',
    // -----------------------------------------------------
  );
  _initializeRouter(); // Initialize router AFTER Supabase

  // --- WRAP runApp WITH PROVIDER ---
  runApp(
    ChangeNotifierProvider(
      create: (context) => MyEventsNotifier(), // Create the notifier instance
      child: const MyApp(), // Your original root widget
    ),
  );
  // --- END WRAP ---
}

// --- Root Application Widget ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dmSansTextTheme = GoogleFonts.dmSansTextTheme(textTheme);

    // Color Schemes (Keep your existing definitions)
    const lightColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: mediumBlue,
      onPrimary: white,
      primaryContainer: Color(0xFFD0E4FF),
      onPrimaryContainer: Color(0xFF001D36),
      secondary: darkBlue,
      onSecondary: white,
      secondaryContainer: Color(0xFFD3E4FF),
      onSecondaryContainer: Color(0xFF001D36),
      tertiary: brightYellow,
      onTertiary: darkBlue,
      tertiaryContainer: Color(0xFFFFE086),
      onTertiaryContainer: Color(0xFF251A00),
      error: Color(0xFFBA1A1A),
      onError: white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: lightGray,
      onSurface: Color(0xFF1A1C1E),
      surfaceContainerHighest: white, // Use for card backgrounds in light mode
      surfaceContainerLow: Color(
        0xFFF0F4F8,
      ), // Slightly off-white for backgrounds
      onSurfaceVariant: darkGray,
      outline: mediumGray,
      outlineVariant: Color(0xFFC4C6CF), // Lighter outline
      shadow: Color(0xFF000000),
      inverseSurface: Color(0xFF2F3033),
      onInverseSurface: lightGray,
      inversePrimary: Color(0xFFA9C7FF),
      surfaceTint: mediumBlue,
    );
    const darkColorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: mediumBlue, // Keep primary blue consistent
      onPrimary: white,
      primaryContainer: Color(0xFF004A77),
      onPrimaryContainer: Color(0xFFD0E4FF),
      secondary: Color(0xFFA2C9FF), // Lighter blue for secondary accent
      onSecondary: Color(0xFF003258),
      secondaryContainer: Color(0xFF00497D), // Darker container
      onSecondaryContainer: Color(0xFFD3E4FF),
      tertiary: brightYellow, // Keep yellow accent
      onTertiary: darkBlue,
      tertiaryContainer: Color(0xFF594300), // Dark yellow container
      onTertiaryContainer: Color(0xFFFFE086),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF1A1C1E), // Dark surface
      onSurface: Color(0xFFE2E2E6), // Light text on dark surface
      surfaceContainerHighest: Color(
        0xFF333639,
      ), // Use for card backgrounds in dark mode
      surfaceContainerLow: Color(
        0xFF232528,
      ), // Slightly lighter dark for backgrounds
      onSurfaceVariant: mediumGray, // Grey text for less emphasis
      outline: darkGray,
      outlineVariant: Color(0xFF44474E), // Darker outline
      shadow: Color(0xFF000000),
      inverseSurface: Color(0xFFE2E2E6),
      onInverseSurface: Color(0xFF1A1C1E),
      inversePrimary: Color(0xFF154CB3), // Primary blue for inverse
      surfaceTint: mediumBlue,
    );

    // Input Decoration Theme (Keep your existing definition)
    final inputDecorationTheme = InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: mediumGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: darkGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: mediumBlue, width: 2.0),
      ),
    );
    // Button Themes (Keep your existing definitions)
    final elevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: mediumBlue,
        foregroundColor: white,
        textStyle: dmSansTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
    final textButtonTheme = TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: mediumBlue,
        textStyle: dmSansTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
    final outlinedButtonTheme = OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: mediumBlue,
        side: BorderSide(color: mediumBlue),
        textStyle: dmSansTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );

    // Build Theme Function (Keep your existing definition)
    ThemeData buildTheme(ColorScheme colorScheme) {
      return ThemeData(
        colorScheme: colorScheme,
        textTheme: dmSansTextTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        primaryTextTheme: dmSansTextTheme.copyWith(
          /* Add specific overrides if needed */
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 1,
          shadowColor: colorScheme.shadow.withAlpha(25),
          titleTextStyle: dmSansTextTheme.titleLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: inputDecorationTheme,
        elevatedButtonTheme: elevatedButtonTheme,
        textButtonTheme: textButtonTheme,
        outlinedButtonTheme: outlinedButtonTheme,
        cardTheme: CardTheme(
          elevation: 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: colorScheme.surfaceContainerHighest,
          clipBehavior: Clip.antiAlias,
        ), // Updated card theme color
        chipTheme: ChipThemeData(
          backgroundColor: colorScheme.secondaryContainer.withAlpha(128),
          labelStyle: dmSansTextTheme.labelSmall?.copyWith(
            color: colorScheme.onSecondaryContainer,
          ),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurfaceVariant.withAlpha(
            (255 * 0.7).round(),
          ),
          backgroundColor: colorScheme.surfaceContainer,
          type: BottomNavigationBarType.fixed,
          elevation: 3.0,
          selectedLabelStyle: dmSansTextTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: dmSansTextTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.normal,
          ),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: dmSansTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: dmSansTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.normal,
          ),
        ),
        useMaterial3: true,
      );
    }

    // Return MaterialApp.router (Keep your existing structure)
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp.router(
          title: 'SOCIO App',
          theme: buildTheme(lightColorScheme),
          darkTheme: buildTheme(darkColorScheme),
          themeMode: mode,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

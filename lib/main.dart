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

// --- NEW: Theme Manager (Keep as is) ---
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(
  ThemeMode.system,
); // Default to system theme

// --- NEW: Define Colors ---
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
    // IMPORTANT: Replace with secure loading (e.g., environment variables)
    url: 'https://srmirwkdbcktvlyflvdi.supabase.co', // DO NOT COMMIT THIS
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNybWlyd2tkYmNrdHZseWZsdmRpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU0ODg5NDgsImV4cCI6MjA2MTA2NDk0OH0.z2qvwaO0qV3meul-QUmpEpsLoyZXwvqpm9FeTsSc0co', // DO NOT COMMIT THIS - load securely
  );
  _initializeRouter(); // Initialize router AFTER Supabase
  runApp(const MyApp());
}

// --- Root Application Widget ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Apply DM Sans font globally
    final textTheme = Theme.of(context).textTheme;
    final dmSansTextTheme = GoogleFonts.dmSansTextTheme(textTheme);

    // --- Define ColorScheme for Light Theme ---
    const lightColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: mediumBlue, // Key interactive elements
      onPrimary: white, // Text/icons on primary
      primaryContainer: Color(0xFFD0E4FF), // Lighter primary containers
      onPrimaryContainer: Color(0xFF001D36), // Text on primary container
      secondary: darkBlue, // Less prominent elements, accents
      onSecondary: white, // Text/icons on secondary
      secondaryContainer: Color(0xFFD3E4FF), // Lighter secondary containers
      onSecondaryContainer: Color(0xFF001D36), // Text on secondary container
      tertiary: brightYellow, // Accent color
      onTertiary: darkBlue, // Text/icons on accent
      tertiaryContainer: Color(0xFFFFE086), // Lighter accent containers
      onTertiaryContainer: Color(0xFF251A00), // Text on accent container
      error: Color(0xFFBA1A1A), // Error color
      onError: white, // Text on error
      errorContainer: Color(0xFFFFDAD6), // Lighter error container
      onErrorContainer: Color(0xFF410002), // Text on error container
      surface: lightGray, // Backgrounds for cards, sheets
      onSurface: Color(0xFF1A1C1E), // Text on backgrounds
      surfaceContainerHighest: white, // Elevated surfaces
      onSurfaceVariant: darkGray, // Lower emphasis text/icons
      outline: mediumGray, // Borders, dividers
      shadow: Color(0xFF000000),
      inverseSurface: Color(
        0xFF2F3033,
      ), // Contrasting surface for SnackBar etc.
      onInverseSurface: lightGray, // Text on inverse surface
      inversePrimary: Color(0xFFA9C7FF), // Primary on dark background
      surfaceTint: mediumBlue, // Tint color over surfaces
    );

    // --- Define ColorScheme for Dark Theme ---
    const darkColorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: mediumBlue, // Keep key elements prominent
      onPrimary: white,
      primaryContainer: Color(0xFF004A77), // Darker primary container
      onPrimaryContainer: Color(0xFFD0E4FF),
      secondary: Color(0xFFA2C9FF), // Lighter secondary for contrast
      onSecondary: Color(0xFF003258),
      secondaryContainer: Color(0xFF00497D), // Darker secondary container
      onSecondaryContainer: Color(0xFFD3E4FF),
      tertiary: brightYellow, // Accent remains bright
      onTertiary: darkBlue,
      tertiaryContainer: Color(0xFF594300), // Darker accent container
      onTertiaryContainer: Color(0xFFFFE086),
      error: Color(0xFFFFB4AB), // Lighter error for dark mode
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A), // Darker error container
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF1A1C1E), // Dark background
      onSurface: Color(0xFFE2E2E6), // Light text on dark background
      surfaceContainerHighest: Color(0xFF333639), // Elevated dark surfaces
      onSurfaceVariant: mediumGray, // Medium gray text/icons
      outline: darkGray, // Darker gray borders/dividers
      shadow: Color(0xFF000000),
      inverseSurface: Color(0xFFE2E2E6), // Light inverse surface
      onInverseSurface: Color(0xFF1A1C1E), // Dark text on light inverse surface
      inversePrimary: Color(0xFF154CB3), // Primary color on light inverse
      surfaceTint: mediumBlue,
    );

    // Define common input decoration theme
    final inputDecorationTheme = InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: mediumGray), // Use theme color
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: darkGray), // Use theme color
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: mediumBlue,
          width: 2.0,
        ), // Use theme color
      ),
      // Add styles for labels, hints etc. using dmSansTextTheme if needed
    );

    // Define common button themes
    final elevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: mediumBlue, // Use theme primary
        foregroundColor: white, // Use onPrimary
        textStyle: dmSansTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ), // DM Sans Medium for buttons
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );

    final textButtonTheme = TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: mediumBlue, // Use theme primary
        textStyle: dmSansTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ), // DM Sans Medium
      ),
    );

    final outlinedButtonTheme = OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: mediumBlue, // Use theme primary
        side: BorderSide(color: mediumBlue), // Border uses primary
        textStyle: dmSansTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ), // DM Sans Medium
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );

    // Build the theme data
    ThemeData buildTheme(ColorScheme colorScheme) {
      return ThemeData(
        colorScheme: colorScheme,
        textTheme: dmSansTextTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        // Apply DM Sans weights to specific text styles
        primaryTextTheme: dmSansTextTheme.copyWith(
          headlineLarge: dmSansTextTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ), // H1/H2 Bold
          headlineMedium: dmSansTextTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ), // H1/H2 Bold
          titleLarge: dmSansTextTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ), // H3/H4 Medium
          titleMedium: dmSansTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ), // H3/H4 Medium
          bodyLarge: dmSansTextTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.normal,
          ), // Body Regular
          bodyMedium: dmSansTextTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.normal,
          ), // Body Regular
          labelLarge: dmSansTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ), // Button Medium
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surfaceContainerHighest,
          foregroundColor: colorScheme.onSurface,
          elevation: 1,
          shadowColor: colorScheme.shadow.withOpacity(0.1),
          titleTextStyle: dmSansTextTheme.titleLarge?.copyWith(
            color: colorScheme.primary, // Title uses Primary Blue
            fontWeight: FontWeight.bold, // Bold title
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
          color:
              colorScheme
                  .surfaceContainerHighest, // Cards use elevated surface color
          clipBehavior: Clip.antiAlias,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: colorScheme.secondaryContainer.withOpacity(0.5),
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
          unselectedItemColor: colorScheme.onSurfaceVariant.withOpacity(0.7),
          backgroundColor:
              colorScheme.surfaceContainer, // Slightly different background
          type: BottomNavigationBarType.fixed,
          elevation: 3.0,
          selectedLabelStyle: dmSansTextTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ), // Medium weight for selected label
          unselectedLabelStyle: dmSansTextTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.normal,
          ), // Regular for unselected
        ),
        tabBarTheme: TabBarTheme(
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: dmSansTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ), // Medium weight
          unselectedLabelStyle: dmSansTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.normal,
          ), // Regular
        ),
        useMaterial3: true,
      );
    }

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

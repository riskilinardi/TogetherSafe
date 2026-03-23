// =============================================================================
// main.dart - Entry Point for TogetherSafe Application
// This is the main file that runs when the app starts. It sets up the app
// structure and handles navigation between different pages.
//
// The app flow is:
// 1. Show splash screen while checking database
// 2. If first time user → Show onboarding screens
// 3. If returning user → Go straight to home page
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'homepage.dart';
import 'emergencyhomepage.dart';
import 'onboardingscreen.dart';
import 'profilepage.dart';
import 'guidespage.dart';
import 'reportpage.dart';
import 'db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  await DatabaseHelper.instance.initDb();
  runApp(const TogetherSafeApp());
}

class TogetherSafeApp extends StatelessWidget {
  const TogetherSafeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TogetherSafe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1B263B),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

// SplashScreen
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check onboarding status when screen loads
    _checkOnboardingStatus();
  }

  // Check if user has completed onboarding and navigate accordingly
  Future<void> _checkOnboardingStatus() async {
    // Add a small delay so the splash screen is visible
    await Future.delayed(const Duration(milliseconds: 1500));

    // Check if onboarding is completed
    bool onboardingCompleted = await DatabaseHelper.instance.isOnboardingCompleted();

    // Navigate to appropriate screen
    if (mounted) {
      if (onboardingCompleted) {
        // User has completed onboarding - go to main app
        // Also update streak when app opens
        await DatabaseHelper.instance.updateStreak();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else {
        // First time user - show onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B263B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFF415A77),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🛡️', style: TextStyle(fontSize: 50)),
              ),
            ),

            const SizedBox(height: 24),

            // App name
            const Text(
              'TogetherSafe',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0E0E0),
              ),
            ),

            const SizedBox(height: 8),

            // Tagline
            const Text(
              'Prepare Together, Stay Safe',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF778DA9),
              ),
            ),

            const SizedBox(height: 48),

            // Loading indicator
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MainPage - Main Navigation Container
// This widget handles the bottom navigation bar and switches between
// different pages.
//
// The app has 4 main tabs:
// 1. Home
// 2. Report
// 3. Guides
// 4. Profile
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Starting at 0 so Home tab is selected by default
  int _currentIndex = 0;

  // Switch Tab Method
  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Build Pages List
  // Returns the list of pages for each tab. HomePage receives the switchTab
  // callback so it can switch to other tabs from quick actions.
  List<Widget> get _pages => [
    HomePage(onSwitchTab: _switchTab),
    const ReportPage(),
    const GuidesPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      // Dark navy background colour matching our theme
      backgroundColor: const Color(0xFF1B263B),

      // Body
      // Display the page corresponding to the selected tab
      body: _pages[_currentIndex],

      // Bottom Navigation Bar
      // This is the main navigation for the app.
      bottomNavigationBar: Container(
        // Add a border on top of the navigation bar
        decoration: const BoxDecoration(
          color: Color(0xFF0D1B2A), // Darker navy than background
          border: Border(
            top: BorderSide(
              color: Color(0xFF415A77), // Subtle border colour
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          // Make background transparent so our Container colour shows
          backgroundColor: Colors.transparent,
          elevation: 0,

          // Fixed type means all items are always visible
          // (as opposed to shifting which hides labels for unselected items)
          type: BottomNavigationBarType.fixed,

          // Colours for selected and unselected items
          selectedItemColor: const Color(0xFF4FC3F7), // Cyan accent
          unselectedItemColor: const Color(0xFF778DA9), // Muted blue-grey

          // Current selected tab
          currentIndex: _currentIndex,

          // Handle tab selection
          onTap: (index) {
            // Update state to show the new page
            setState(() {
              _currentIndex = index;
            });
          },

          // Navigation items
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: 'Report',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Guides',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
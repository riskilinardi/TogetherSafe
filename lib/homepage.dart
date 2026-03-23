// =============================================================================
// homepage.dart - Calm Mode Home Page
// =============================================================================
// This is the main home page that users see during normal times.
// It displays the user's preparedness progress, gamification stats, and
// provides quick access to various features of the app.
//
// DATA FLOW:
// This page loads data from the local SQLite database (db.dart) including:
// - User profile
// - Gamification data
// - Badges
// - Preparedness tasks
// =============================================================================

import 'package:flutter/material.dart';
import 'db.dart';
import 'checklistpage.dart';
import 'quizpage.dart';
import 'emergencyhomepage.dart';
import 'api_service.dart';

class HomePage extends StatefulWidget {
  final Function(int)? onSwitchTab;

  const HomePage({Key? key, this.onSwitchTab}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // STATE VARIABLES
  // Loading state - shows spinner while fetching data from database
  bool _isLoading = true;

  // User's name from onboarding
  String _userName = 'User';

  // Gamification Data
  // These values are loaded from the database when the page opens.
  // They update in real-time as users complete tasks and earn achievements.
  double _preparednessLevel = 0.0;
  int _streakDays = 0;
  int _totalPoints = 0;
  int _badgesEarned = 0;

  // Challenge Data
  String _currentChallenge = 'Build Emergency Kit';
  int _challengeCompleted = 0;
  int _challengeTotal = 5;

  // Environment Data
  // Real-time weather and air quality data from data.gov.sg
  EnvironmentData? _environmentData;
  bool _isLoadingEnvironment = true;
  EmergencyAlert? _activeAlert;

  @override
  void initState() {
    super.initState();
    // Load data from database when page first opens
    _loadDataFromDatabase();
    // Load environment data from APIs
    _loadEnvironmentData();
  }

  // Load Environment Data from APIs
  // Fetches real-time weather, PSI, and rainfall data from data.gov.sg
  Future<void> _loadEnvironmentData() async {
    try {
      final apiService = ApiService();

      // Check for emergency conditions first
      final alert = await apiService.checkForEmergencies();

      // Get all environment data
      final envData = await apiService.getAllEnvironmentData();

      if (mounted) {
        setState(() {
          _environmentData = envData;
          _activeAlert = alert;
          _isLoadingEnvironment = false;
        });

        // If there's an active alert, show a notification
        if (alert != null) {
          _showAlertNotification(alert);
        }
      }
    } catch (e) {
      debugPrint('Error loading environment data: $e');
      if (mounted) {
        setState(() {
          _isLoadingEnvironment = false;
        });
      }
    }
  }

  // Show Alert Notification
  void _showAlertNotification(EmergencyAlert alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${alert.type}: ${alert.severity}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFF6F00),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to emergency mode with alert details
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EmergencyHomePage(
                  emergencyType: alert.type,
                  location: alert.location,
                  issuedTime: alert.formattedTime,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Load Data From Database
  // This method fetches all the data needed for the home page from SQLite.

  Future<void> _loadDataFromDatabase() async {
    try {
      // Fetch user profile for personalised greeting
      UserProfile? profile = await DatabaseHelper.instance.getUserProfile();

      // Fetch gamification data (points, streak, preparedness level)
      GamificationData? gamificationData = await DatabaseHelper.instance.getGamificationData();

      // Fetch unlocked badges count
      List<AchievementBadge> unlockedBadges = await DatabaseHelper.instance.getUnlockedBadges();

      List<PreparednessTask> kitTasks = await DatabaseHelper.instance.getTasksByCategory('Emergency Kit');
      int completedKitTasks = kitTasks.where((task) => task.isCompleted).length;

      // Update state with fetched data
      // Using setState() to trigger UI rebuild with new values
      setState(() {
        // User name
        _userName = profile?.name ?? 'User';

        // Gamification stats
        if (gamificationData != null) {
          _preparednessLevel = gamificationData.preparednessLevel;
          _streakDays = gamificationData.currentStreak;
          _totalPoints = gamificationData.totalPoints;
        }

        // Badges count
        _badgesEarned = unlockedBadges.length;

        _challengeCompleted = completedKitTasks;
        _challengeTotal = kitTasks.length;

        // Done loading
        _isLoading = false;
      });
    } catch (e) {
      // If there's an error, still hide loading and show default values
      // This prevents the app from getting stuck on the loading screen
      debugPrint('Error loading home page data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Refresh Data
  Future<void> refreshData() async {
    await _loadDataFromDatabase();
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  // Get Greeting Based on Time of Day
  // Returns a different greeting depending on what time it is.
  // Morning: 12am - 11:59am
  // Afternoon: 12pm - 4:59pm
  // Evening: 5pm - 11:59pm
  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Format Large Numbers
  // Converts large numbers to a more readable format.
  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  // Show Snackbar Message
  // Displays a temporary message at the bottom of the screen.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF415A77),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dark navy blue background - creates a calm, modern look
      backgroundColor: const Color(0xFF1B263B),

      // App Bar with title and emergency test button
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        title: const Text(
          'TogetherSafe',
          style: TextStyle(
            color: Color(0xFFE0E0E0),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // Emergency Mode test button (for testing/demo purposes)
          IconButton(
            icon: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFFF6F00), // Orange for visibility
            ),
            tooltip: 'Test Emergency Mode',
            onPressed: () {
              // Navigate to Emergency Mode for testing
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmergencyHomePage(),
                ),
              );
            },
          ),
        ],
      ),

      body: _isLoading
      // Show loading spinner while fetching data
          ? _buildLoadingState()
      // Show main content when data is loaded
          : RefreshIndicator(
        // Pull-to-refresh functionality - refresh both database and API data
        onRefresh: () async {
          await _loadDataFromDatabase();
          await _loadEnvironmentData();
        },
        color: const Color(0xFF4FC3F7),
        backgroundColor: const Color(0xFF0D1B2A),
        child: ListView(
          // Add padding on left and right sides
          padding: const EdgeInsets.symmetric(horizontal: 16),

          children: [
            // Greeting and welcome message
            _buildHeader(),

            // Real-time environment data card (Weather, PSI)
            _buildEnvironmentCard(),

            const SizedBox(height: 16),

            // Big card showing preparedness percentage
            _buildProgressCard(),

            const SizedBox(height: 16),

            // Row of three stat cards (Streak, Points, Badges)
            _buildStatsRow(),

            const SizedBox(height: 20),

            _buildSectionTitle('Current Challenge'),
            const SizedBox(height: 10),
            _buildChallengeCard(),

            const SizedBox(height: 20),

            // Quick Actions section
            _buildSectionTitle('Quick Actions'),
            const SizedBox(height: 10),
            _buildQuickActionsGrid(),

            // Bottom padding so content doesn't touch navigation bar
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // UI COMPONENT BUILDERS
  // ===========================================================================

  // Loading State
  // Shows a centered loading spinner while data is being fetched.
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading your progress...',
            style: TextStyle(
              color: Color(0xFF778DA9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Header Section
  // Shows a personalised greeting using the user's name from onboarding.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
        children: [
          // Dynamic greeting based on time of day
          Text(
            _getGreeting(),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF778DA9), // Muted blue-grey
            ),
          ),

          const SizedBox(height: 4),

          // Personalised welcome message with user's name
          Text(
            'Welcome back, $_userName!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE0E0E0), // Light grey - easy to read on dark bg
            ),
          ),
        ],
      ),
    );
  }

  // Preparedness Progress Card
  // This is the main card that shows the user's overall preparedness level.
  Widget _buildProgressCard() {
    // Convert decimal to percentage for display
    int percentageDisplay = (_preparednessLevel * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),

      // Gradient decoration for visual interest
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF415A77), Color(0xFF5C7A99)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with percentage and shield icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - label and percentage
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preparedness Level',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Display percentage from database
                  Text(
                    '$percentageDisplay%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // Right side - shield emoji in a circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🛡️', style: TextStyle(fontSize: 24)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar showing preparedness level visually
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _preparednessLevel, // 0.0 to 1.0 from database
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4FC3F7), // Cyan colour for the filled part
              ),
              minHeight: 8,
            ),
          ),

          // Show encouraging message based on level
          const SizedBox(height: 8),
          Text(
            _getEncouragingMessage(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // Get Encouraging Message
  // Returns a motivational message based on the user's preparedness level.
  String _getEncouragingMessage() {
    if (_preparednessLevel == 0) {
      return 'Start your preparedness journey today! 🚀';
    } else if (_preparednessLevel < 0.25) {
      return 'Great start! Keep completing tasks to level up! 💪';
    } else if (_preparednessLevel < 0.5) {
      return 'You\'re making progress! Halfway there! 🌟';
    } else if (_preparednessLevel < 0.75) {
      return 'Excellent work! Your family is getting safer! 🏆';
    } else if (_preparednessLevel < 1.0) {
      return 'Almost there! Just a few more tasks to go! 🎯';
    } else {
      return 'Amazing! You\'re fully prepared! Stay vigilant! ✅';
    }
  }

  // Stats Row
  // Displays three stat cards in a row: Streak, Points, and Badges.
  // These gamification elements encourage continued engagement with the app.
  Widget _buildStatsRow() {
    return Row(
      children: [
        // Streak card - shows consecutive days of app usage
        _buildStatCard(
          '🔥',
          _streakDays.toString(),
          'Streak',
          const Color(0xFFFFB74D), // Orange - associated with fire/streaks
        ),

        const SizedBox(width: 10),

        // Points card - total points earned from database
        _buildStatCard(
          '⭐',
          _formatNumber(_totalPoints),
          'Points',
          const Color(0xFF81C784), // Green - positive/growth
        ),

        const SizedBox(width: 10),

        // Badges card - count of unlocked badges from database
        _buildStatCard(
          '🏆',
          _badgesEarned.toString(),
          'Badges',
          const Color(0xFF4FC3F7), // Cyan - matches app accent colour
        ),
      ],
    );
  }

  // Individual Stat Card
  // Reusable widget for displaying a single statistic.
  // Takes emoji, value, label, and colour as parameters.
  Widget _buildStatCard(
      String emoji,
      String value,
      String label,
      Color valueColor,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A), // Darker than background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF415A77)), // Subtle border
        ),
        child: Column(
          children: [
            // Emoji at the top
            Text(emoji, style: const TextStyle(fontSize: 20)),

            const SizedBox(height: 4),

            // Value in the middle (coloured)
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),

            // Label at the bottom
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF778DA9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE0E0E0),
      ),
    );
  }

  // Shows the current challenge with progress indicator.
  // Progress is calculated from Emergency Kit category tasks in database.
  Widget _buildChallengeCard() {
    // Calculate progress as a decimal for the progress bar
    // Avoid division by zero if there are no tasks
    double challengeProgress = _challengeTotal > 0
        ? _challengeCompleted / _challengeTotal
        : 0.0;

    return GestureDetector(
      onTap: () {
        // Navigate to checklist page when tapping current challenge
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChecklistPage()),
        ).then((_) {
          // Refresh data when returning
          _loadDataFromDatabase();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF415A77)),
        ),
        child: Row(
          children: [
            // Target emoji on the left
            const Text('🎯', style: TextStyle(fontSize: 28)),

            const SizedBox(width: 12),

            // Challenge info in the middle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Challenge name
                  Text(
                    _currentChallenge,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE0E0E0),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Progress text - shows actual counts from database
                  Text(
                    '$_challengeCompleted of $_challengeTotal completed',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF778DA9),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: challengeProgress,
                      backgroundColor: const Color(0xFF415A77),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4FC3F7),
                      ),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow icon indicating it's tappable
            const Icon(Icons.chevron_right, color: Color(0xFF778DA9)),
          ],
        ),
      ),
    );
  }

  // Quick Actions Grid
  // These provide fast access to the most important app functions.
  Widget _buildQuickActionsGrid() {
    return Row(
      children: [
        // Checklist - opens full screen with back button
        Expanded(
          child: _buildQuickAction('📋', 'Checklist', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChecklistPage()),
            ).then((_) {
              // Refresh home page data when returning from checklist
              _loadDataFromDatabase();
            });
          }),
        ),

        const SizedBox(width: 16),

        // Quizzes - opens full screen with back button
        Expanded(
          child: _buildQuickAction('🧠', 'Quizzes', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QuizPage()),
            ).then((_) {
              // Refresh data when returning (user may have earned points)
              _loadDataFromDatabase();
            });
          }),
        ),
      ],
    );
  }

  // Individual Quick Action Button
  Widget _buildQuickAction(String emoji, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF415A77)),
          ),
          child: Column(
            children: [
              // Emoji icon
              Text(emoji, style: const TextStyle(fontSize: 22)),

              const SizedBox(height: 4),

              // Button label
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF778DA9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Environment Data Card
  // Displays real-time weather and PSI data from Singapore government APIs.
  Widget _buildEnvironmentCard() {
    // Show loading state while fetching API data
    if (_isLoadingEnvironment) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF415A77)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Loading weather data...',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF778DA9),
              ),
            ),
          ],
        ),
      );
    }

    // Show alert banner if there's an active alert
    if (_activeAlert != null) {
      return _buildAlertBanner(_activeAlert!);
    }

    // Show environment data if available
    if (_environmentData != null && _environmentData!.hasData) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF415A77)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text('📍', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Text(
                      'Singapore',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF778DA9),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Live Data',
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color(0xFF4FC3F7).withOpacity(0.8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Weather and PSI row
            Row(
              children: [
                // Weather section
                Expanded(
                  child: Row(
                    children: [
                      // Weather icon
                      Text(
                        _environmentData!.forecast2Hour?.weatherIcon ?? '🌤️',
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Temperature
                          Text(
                            _environmentData!.temperature != null
                                ? '${_environmentData!.temperature!.toStringAsFixed(0)}°C'
                                : '--°C',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          // Forecast
                          Text(
                            _environmentData!.forecast2Hour?.generalForecast ?? 'No data',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF778DA9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  width: 1,
                  height: 40,
                  color: const Color(0xFF415A77),
                ),

                // PSI section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Air Quality (PSI)',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF778DA9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _environmentData!.psi?.nationalPsi.toString() ?? '--',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(_environmentData!.psi?.statusColor ?? 0xFF4FC3F7),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(_environmentData!.psi?.statusColor ?? 0xFF4FC3F7).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _environmentData!.psi?.status ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(_environmentData!.psi?.statusColor ?? 0xFF4FC3F7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Rainfall indicator
            if (_environmentData!.rainfall != null && _environmentData!.rainfall!.hasSignificantRain) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🌧️', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      'Rain detected: ${_environmentData!.rainfall!.maxRainfall.toStringAsFixed(1)}mm at ${_environmentData!.rainfall!.maxRainfallLocation}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4FC3F7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Fallback if no data available
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF415A77)),
      ),
      child: const Row(
        children: [
          Text('🌤️', style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Text(
            'Weather data unavailable',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF778DA9),
            ),
          ),
        ],
      ),
    );
  }

  // Alert Banner
  // Shows when there's an active weather/environmental alert
  Widget _buildAlertBanner(EmergencyAlert alert) {
    return GestureDetector(
      onTap: () {
        // Navigate to emergency mode with alert details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmergencyHomePage(
              emergencyType: alert.type,
              location: alert.location,
              issuedTime: alert.formattedTime,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF6F00).withOpacity(0.3),
              const Color(0xFFFF6F00).withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFF6F00)),
        ),
        child: Row(
          children: [
            // Warning icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6F00).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFF6F00),
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            // Alert content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.type,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6F00),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${alert.severity} - ${alert.location}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE0E0E0),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFFF6F00),
            ),
          ],
        ),
      ),
    );
  }
}
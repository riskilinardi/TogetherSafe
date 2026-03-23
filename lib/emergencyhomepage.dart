// =============================================================================
// emergencyhomepage.dart - Emergency Mode Home Page
// =============================================================================
// This page is displayed when there is an active emergency alert. It has a
// completely different design from the Calm Mode (homepage.dart) to help users
// quickly identify that they're in Emergency Mode.
//
// Design Decisions (based on crisis informatics research):
// - High contrast colours (red/white) for visibility under stress
// - Large touch targets for easier tapping with shaky hands
// - Simplified navigation with only essential actions
// - Bold, clear text that's easy to read quickly
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

// EmergencyHomePage Widget
class EmergencyHomePage extends StatelessWidget {
  // PARAMETERS - Emergency Details
  // These values are passed in when the page is created from an
  // API alert.

  final String emergencyType;
  final String location;
  final String issuedTime;

  // Constructor with default values for testing
  const EmergencyHomePage({
    Key? key,
    this.emergencyType = 'FLASH FLOOD WARNING',
    this.location = 'Bukit Timah Area',
    this.issuedTime = '9:35 AM',
  }) : super(key: key);

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  // Get Safety Steps Based on Emergency Type
  // Returns a list of safety instructions specific to the type of emergency.
  // This ensures users get relevant guidance for their situation.
  List<String> _getSafetySteps() {
    // Check what type of emergency it is and return appropriate steps

    if (emergencyType.toLowerCase().contains('flood')) {
      // Flood safety steps - based on SCDF guidelines
      return [
        'Move to higher ground immediately',
        'Avoid walking or driving through flood waters',
        'Stay away from storm drains and ditches',
        'Turn off electricity at the main switch if safe',
        'Do not touch electrical equipment if wet',
        'Listen to emergency broadcasts for updates',
        'Call 995 if you need rescue assistance',
      ];
    } else if (emergencyType.toLowerCase().contains('haze')) {
      // Haze safety steps - based on NEA guidelines
      return [
        'Stay indoors and close all windows',
        'Use air purifier if available',
        'Wear N95 mask if going outside',
        'Reduce physical activity',
        'Drink plenty of water',
        'Seek medical attention if feeling unwell',
      ];
    } else if (emergencyType.toLowerCase().contains('fire')) {
      // Fire safety steps - based on SCDF guidelines
      return [
        'Alert everyone and evacuate immediately',
        'Use stairs, never elevators',
        'Stay low to avoid smoke inhalation',
        'Feel doors before opening - if hot, find another exit',
        'Meet at designated assembly point',
        'Call 995 once safely outside',
        'Do not re-enter the building',
      ];
    }

    // Default general emergency steps if type not recognised
    return [
      'Stay calm and assess the situation',
      'Follow official instructions',
      'Move to a safe location',
      'Contact emergency services if needed',
      'Check on family and neighbours',
      'Listen to emergency broadcasts',
    ];
  }

  // Get Dynamic Subtitle for "What To Do" Button
  String _getSubtitleForEmergency() {
    if (emergencyType.toLowerCase().contains('flood')) {
      return 'Flood Safety Steps';
    } else if (emergencyType.toLowerCase().contains('haze')) {
      return 'Haze Safety Steps';
    } else if (emergencyType.toLowerCase().contains('fire')) {
      return 'Fire Safety Steps';
    }
    return 'Safety Steps';
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to light icons (white) since background is dark red
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      // Dark red background - creates urgency and clearly different from Calm Mode
      backgroundColor: const Color(0xFFB71C1C),

      body: SafeArea(
        child: Column(
          children: [
            // Yellow alert banner at the top
            _buildAlertBanner(),

            // "EMERGENCY MODE" header
            _buildHeader(),

            // Main action buttons (Call 995, What To Do, etc.)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Call emergency services button
                    _buildActionButton(
                      context,
                      emoji: '📞',
                      title: 'CALL 995',
                      subtitle: 'Emergency Services',
                      color: const Color(0xFFD32F2F),
                      onTap: () => _makePhoneCall(context, '995'),
                    ),

                    const SizedBox(height: 12),

                    // Safety steps button
                    _buildActionButton(
                      context,
                      emoji: '📋',
                      title: 'WHAT TO DO',
                      subtitle: _getSubtitleForEmergency(),
                      color: const Color(0xFFFF6F00),
                      onTap: () => _showSafetySteps(context),
                    ),

                    const SizedBox(height: 12),

                    // Find shelter button
                    _buildActionButton(
                      context,
                      emoji: '🏠',
                      title: 'FIND SHELTER',
                      subtitle: 'Nearest Safe Location',
                      color: const Color(0xFF1976D2),
                      onTap: () => _showShelterInfo(context),
                    ),

                    const SizedBox(height: 12),

                    // Contact family button
                    _buildActionButton(
                      context,
                      emoji: '👨‍👩‍👧',
                      title: 'CONTACT FAMILY',
                      subtitle: 'Send "I\'m Safe" Alert',
                      color: const Color(0xFF388E3C),
                      onTap: () => _sendSafetyAlert(context),
                    ),
                  ],
                ),
              ),
            ),

            // Exit button at the bottom
            _buildExitButton(context),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // UI COMPONENT BUILDERS
  // ===========================================================================

  // Alert Banner
  // Yellow warning banner at the top that shows emergency details.
  // Yellow was chosen because it's universally recognised as a warning colour.
  Widget _buildAlertBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFFFFEB3B), // Bright yellow for warning

      child: Row(
        children: [
          // Warning emoji
          const Text('⚠️', style: TextStyle(fontSize: 24)),

          const SizedBox(width: 12),

          // Emergency details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emergencyType,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 2),

                // Location and time
                Text(
                  '$location • Issued $issuedTime',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Header
  // Shows "EMERGENCY MODE" label and a reassuring message.
  // The message "Stay Calm. Act Now." is designed to help reduce panic
  // while encouraging action.
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(
            'EMERGENCY MODE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 2, // Spaced out for emphasis
            ),
          ),

          SizedBox(height: 8),
          Text(
            'Stay Calm. Act Now.',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Action Button
  // Large, easy-to-tap button for emergency actions.
  // Each button has:
  // - Coloured emoji circle on the left
  // - Title and subtitle text
  // - Arrow icon on the right indicating it's tappable
  Widget _buildActionButton(
      BuildContext context, {
        required String emoji,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Add shadow for depth
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [
            // Coloured circle with emoji
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),

            const SizedBox(width: 16),

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(Icons.chevron_right, color: color, size: 28),
          ],
        ),
      ),
    );
  }

  // Exit Button
  // Button to exit Emergency Mode and return to Calm Mode.
  // Uses outline style to be less prominent than the action buttons because
  // we don't want users accidentally exiting.
  Widget _buildExitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _showExitConfirmation(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: const Center(
            child: Text(
              'Exit Emergency Mode',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ACTION METHODS
  // ===========================================================================

  // Make Phone Call
  // Opens the phone dialer with the emergency number (995 in Singapore).
  // Uses url_launcher package to handle the phone call.
  void _makePhoneCall(BuildContext context, String number) async {
    // Create a tel: URI for the phone number
    final Uri phoneUri = Uri(scheme: 'tel', path: number);

    try {
      // Check if we can launch the phone app
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Show error if phone app can't be opened
        _showErrorSnackBar(context, 'Could not launch phone dialer');
      }
    } catch (e) {
      // Handle any errors
      _showErrorSnackBar(context, 'Error making phone call');
    }
  }

  // Show Safety Steps
  // Opens a bottom sheet modal showing step-by-step safety instructions.
  void _showSafetySteps(BuildContext context) {
    // Get the safety steps based on emergency type
    final steps = _getSafetySteps();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B263B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,

      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,

          builder: (context, scrollController) {
            return Column(
              children: [
                // Drag handle bar at the top
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Text('📋', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Text(
                        _getSubtitleForEmergency(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider line
                const Divider(color: Color(0xFF415A77)),

                // List of safety steps
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step number in orange circle
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF6F00),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Step text
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  steps[index],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFFE0E0E0),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Show Shelter Information
  // Opens a bottom sheet showing nearby shelters.
  void _showShelterInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B263B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Only take space needed
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              const Row(
                children: [
                  Text('🏠', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 12),
                  Text(
                    'Nearby Shelters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildShelterItem(
                'Bukit Timah CC',
                '500m away',
                'Open 24 hours during emergency',
              ),
              const SizedBox(height: 12),
              _buildShelterItem(
                'Clementi Sports Hall',
                '1.2km away',
                'Capacity: 200 people',
              ),
              const SizedBox(height: 12),
              _buildShelterItem(
                'West Coast CC',
                '2.1km away',
                'Food and water available',
              ),
            ],
          ),
        );
      },
    );
  }

  // Shelter Item Widget
  // Displays a single shelter with name, distance, and additional info.
  Widget _buildShelterItem(String name, String distance, String info) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF415A77)),
      ),
      child: Row(
        children: [
          // Location icon
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Colors.white),
          ),

          const SizedBox(width: 12),

          // Shelter details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE0E0E0),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$distance • $info',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF778DA9),
                  ),
                ),
              ],
            ),
          ),

          // Arrow icon
          const Icon(Icons.chevron_right, color: Color(0xFF778DA9)),
        ],
      ),
    );
  }

  // Send Safety Alert
  // Shows a confirmation dialog before sending "I'm Safe" alert to family.
  // This prevents accidental sends.
  void _sendSafetyAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B263B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          // Title with emoji
          title: const Row(
            children: [
              Text('👨‍👩‍👧', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Text(
                'Contact Family',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Confirmation message
          content: const Text(
            'Send an "I\'m Safe" message to your emergency contacts?',
            style: TextStyle(color: Color(0xFF778DA9)),
          ),

          actions: [
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF778DA9)),
              ),
            ),

            // Confirm button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text('"I\'m Safe" alert sent to your family!'),
                      ],
                    ),
                    backgroundColor: Color(0xFF388E3C),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF388E3C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Send Alert',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show Exit Confirmation
  // Asks user to confirm before exiting Emergency Mode.
  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B263B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          title: const Text(
            'Exit Emergency Mode?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: const Text(
            'Only exit if the emergency has passed and you are safe.',
            style: TextStyle(color: Color(0xFF778DA9)),
          ),

          actions: [
            // Stay button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Stay',
                style: TextStyle(
                  color: Color(0xFF778DA9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Exit button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to MainPage (Calm Mode)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3F7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Exit',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show Error Snackbar
  // Helper method to show error messages at the bottom of the screen.
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
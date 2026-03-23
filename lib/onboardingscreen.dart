// =============================================================================
// onboarding_screen.dart - User Onboarding Flow
// =============================================================================
// This screen guides new users through the initial setup process. It collects
// essential information without requiring a full account registration.
//
// The onboarding flow has 4 steps:
// 1. Welcome - Introduction to the app
// 2. Your Name - What to call the user
// 3. Household - Who lives with them (for emergency planning)
// 4. Emergency Contacts - Who to notify during emergencies
// =============================================================================

import 'package:flutter/material.dart';
import 'db.dart';
import 'main.dart';

// OnboardingScreen Widget
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // STATE VARIABLES
  // Current step (0 = Welcome, 1 = Name, 2 = Household, 3 = Emergency Contacts)
  int _currentStep = 0;

  // Total number of steps
  final int _totalSteps = 4;

  // Page controller for smooth transitions between steps
  final PageController _pageController = PageController();

  // Text controllers for input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _contactRelationshipController = TextEditingController();

  // Household counts
  int _adultsCount = 1;
  int _childrenCount = 0;
  int _elderlyCount = 0;
  int _petsCount = 0;
  bool _hasSpecialNeeds = false;

  // Emergency contacts list
  List<EmergencyContact> _emergencyContacts = [];
  bool _isSaving = false;

  @override
  void dispose() {
    // Clean up controllers when widget is removed
    _pageController.dispose();
    _nameController.dispose();
    _postalCodeController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactRelationshipController.dispose();
    super.dispose();
  }

  // NAVIGATION METHODS
  // Move to next step
  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    }
  }

  // Move to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  // Complete onboarding and save data
  Future<void> _completeOnboarding() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Create user profile with collected data
      UserProfile profile = UserProfile(
        name: _nameController.text.trim().isEmpty
            ? 'User' // Default name if not provided
            : _nameController.text.trim(),
        postalCode: _postalCodeController.text.trim().isNotEmpty
            ? _postalCodeController.text.trim()
            : null,
        adultsCount: _adultsCount,
        childrenCount: _childrenCount,
        elderlyCount: _elderlyCount,
        petsCount: _petsCount,
        hasSpecialNeeds: _hasSpecialNeeds,
        onboardingCompleted: true,
      );

      // Save profile to database
      await DatabaseHelper.instance.insertUserProfile(profile);

      // Save emergency contacts
      for (EmergencyContact contact in _emergencyContacts) {
        await DatabaseHelper.instance.insertEmergencyContact(contact);
      }

      // Unlock "First Steps" badge for completing onboarding
      await DatabaseHelper.instance.unlockBadge('First Steps');

      // Check if user added emergency contacts for "Family First" badge
      if (_emergencyContacts.length >= 3) {
        await DatabaseHelper.instance.unlockBadge('Family First');
      }

      // Navigate to main app
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      }
    } catch (e) {
      // Show error message if save fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B263B),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator at top
            _buildProgressIndicator(),

            // Main content area with PageView for swipe transitions
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildWelcomeStep(),
                  _buildNameStep(),
                  _buildHouseholdStep(),
                  _buildEmergencyContactsStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI COMPONENTS
  // Progress Indicator
  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalSteps, (index) {
          bool isActive = index <= _currentStep;
          bool isCurrent = index == _currentStep;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isCurrent ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF4FC3F7)
                  : const Color(0xFF415A77),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  // Step 1: Welcome Screen
  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App logo/icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF415A77),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🛡️', style: TextStyle(fontSize: 60)),
            ),
          ),

          const SizedBox(height: 32),

          // Welcome title
          const Text(
            'Welcome to TogetherSafe',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE0E0E0),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          const Text(
            'Your personal disaster preparedness companion. '
                'Let\'s set up your profile so we can better help you '
                'stay safe during emergencies.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF778DA9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // Get Started button
          _buildPrimaryButton(
            text: 'Get Started',
            onPressed: _nextStep,
          ),
        ],
      ),
    );
  }

  // Step 2: Name Input
  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Back button
          _buildBackButton(),

          const SizedBox(height: 40),

          // Emoji and title
          const Text('👋', style: TextStyle(fontSize: 48)),

          const SizedBox(height: 16),

          const Text(
            'What should we call you?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE0E0E0),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'This helps personalise your experience.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF778DA9),
            ),
          ),

          const SizedBox(height: 32),

          // Name input field
          TextField(
            controller: _nameController,
            style: const TextStyle(
              color: Color(0xFFE0E0E0),
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: const TextStyle(color: Color(0xFF778DA9)),
              filled: true,
              fillColor: const Color(0xFF0D1B2A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF415A77)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF415A77)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),

          const Spacer(),

          // Continue button
          _buildPrimaryButton(
            text: 'Continue',
            onPressed: _nextStep,
          ),

          const SizedBox(height: 12),

          // Skip button
          _buildTextButton(
            text: 'Skip for now',
            onPressed: _nextStep,
          ),
        ],
      ),
    );
  }

  // Step 3: Household Information
  Widget _buildHouseholdStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Back button
          _buildBackButton(),

          const SizedBox(height: 40),

          // Emoji and title
          const Text('🏠', style: TextStyle(fontSize: 48)),

          const SizedBox(height: 16),

          const Text(
            'Tell us about your household',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE0E0E0),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'This helps us give you relevant emergency guidance.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF778DA9),
            ),
          ),

          const SizedBox(height: 32),

          // Counter for adults
          _buildCounter(
            label: 'Adults (18-64)',
            emoji: '👤',
            value: _adultsCount,
            onIncrement: () => setState(() => _adultsCount++),
            onDecrement: () {
              if (_adultsCount > 0) setState(() => _adultsCount--);
            },
          ),

          const SizedBox(height: 16),

          // Counter for children
          _buildCounter(
            label: 'Children (under 18)',
            emoji: '👶',
            value: _childrenCount,
            onIncrement: () => setState(() => _childrenCount++),
            onDecrement: () {
              if (_childrenCount > 0) setState(() => _childrenCount--);
            },
          ),

          const SizedBox(height: 16),

          // Counter for elderly
          _buildCounter(
            label: 'Elderly (65+)',
            emoji: '👴',
            value: _elderlyCount,
            onIncrement: () => setState(() => _elderlyCount++),
            onDecrement: () {
              if (_elderlyCount > 0) setState(() => _elderlyCount--);
            },
          ),

          const SizedBox(height: 16),

          // Counter for pets
          _buildCounter(
            label: 'Pets',
            emoji: '🐕',
            value: _petsCount,
            onIncrement: () => setState(() => _petsCount++),
            onDecrement: () {
              if (_petsCount > 0) setState(() => _petsCount--);
            },
          ),

          const SizedBox(height: 24),

          // Special needs toggle
          _buildToggle(
            label: 'Anyone with special needs?',
            description: 'Mobility issues, medical conditions, etc.',
            value: _hasSpecialNeeds,
            onChanged: (value) => setState(() => _hasSpecialNeeds = value),
          ),

          const SizedBox(height: 24),

          // Postal code input for location-based alerts
          _buildPostalCodeInput(),

          const SizedBox(height: 40),

          // Continue button
          _buildPrimaryButton(
            text: 'Continue',
            onPressed: _nextStep,
          ),

          const SizedBox(height: 12),

          // Skip button
          _buildTextButton(
            text: 'Skip for now',
            onPressed: _nextStep,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Step 4: Emergency Contacts
  Widget _buildEmergencyContactsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Back button
          _buildBackButton(),

          const SizedBox(height: 40),

          // Emoji and title
          const Text('👨‍👩‍👧', style: TextStyle(fontSize: 48)),

          const SizedBox(height: 16),

          const Text(
            'Emergency Contacts',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE0E0E0),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Add people to notify when you send an "I\'m Safe" alert. '
                'You can add up to 3 contacts.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF778DA9),
            ),
          ),

          const SizedBox(height: 24),

          // Display added contacts
          if (_emergencyContacts.isNotEmpty) ...[
            ...List.generate(_emergencyContacts.length, (index) {
              return _buildContactCard(_emergencyContacts[index], index);
            }),
            const SizedBox(height: 16),
          ],

          // Add contact button (if less than 3)
          if (_emergencyContacts.length < 3)
            _buildAddContactButton(),

          const SizedBox(height: 40),

          // Complete button
          _buildPrimaryButton(
            text: _isSaving ? 'Saving...' : 'Complete Setup',
            onPressed: _isSaving ? null : _completeOnboarding,
          ),

          const SizedBox(height: 12),

          // Skip button
          _buildTextButton(
            text: 'Skip and finish',
            onPressed: _isSaving ? null : _completeOnboarding,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // REUSABLE WIDGETS
  // Back button
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: _previousStep,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.arrow_back, color: Color(0xFF778DA9), size: 20),
          SizedBox(width: 8),
          Text(
            'Back',
            style: TextStyle(
              color: Color(0xFF778DA9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Primary action button
  Widget _buildPrimaryButton({
    required String text,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4FC3F7),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Text button for skip actions
  Widget _buildTextButton({
    required String text,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF778DA9),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Counter widget for household members
  Widget _buildCounter({
    required String label,
    required String emoji,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF415A77)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 14,
              ),
            ),
          ),
          // Decrement button
          GestureDetector(
            onTap: onDecrement,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF415A77),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.remove, color: Colors.white, size: 20),
            ),
          ),
          // Value display
          Container(
            width: 48,
            alignment: Alignment.center,
            child: Text(
              value.toString(),
              style: const TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Increment button
          GestureDetector(
            onTap: onIncrement,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // Toggle switch widget
  Widget _buildToggle({
    required String label,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF415A77)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFE0E0E0),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF778DA9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4FC3F7),
            inactiveThumbColor: const Color(0xFF778DA9),
            inactiveTrackColor: const Color(0xFF415A77),
          ),
        ],
      ),
    );
  }

  // Postal Code Input for Location-Based Alerts
  // Collects user's postal code to provide location-filtered emergency alerts.
  Widget _buildPostalCodeInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF415A77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('📍', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your Postal Code',
                  style: TextStyle(
                    color: Color(0xFFE0E0E0),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'For location-specific emergency alerts (optional)',
            style: TextStyle(
              color: Color(0xFF778DA9),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _postalCodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: const TextStyle(
              color: Color(0xFFE0E0E0),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. 520123',
              hintStyle: const TextStyle(color: Color(0xFF778DA9)),
              counterStyle: const TextStyle(color: Color(0xFF778DA9)),
              filled: true,
              fillColor: const Color(0xFF1B263B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF415A77)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF415A77)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps us send you alerts relevant to your area, '
                'like flood warnings for flood-prone zones.',
            style: TextStyle(
              color: Color(0xFF778DA9),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // Contact card displaying added contact
  Widget _buildContactCard(EmergencyContact contact, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF415A77)),
      ),
      child: Row(
        children: [
          // Contact icon
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF388E3C),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Contact details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    color: Color(0xFFE0E0E0),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${contact.relationship} • ${contact.phoneNumber}',
                  style: const TextStyle(
                    color: Color(0xFF778DA9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Delete button
          GestureDetector(
            onTap: () {
              setState(() {
                _emergencyContacts.removeAt(index);
              });
            },
            child: const Icon(Icons.close, color: Color(0xFF778DA9), size: 20),
          ),
        ],
      ),
    );
  }

  // Add contact button
  Widget _buildAddContactButton() {
    return GestureDetector(
      onTap: _showAddContactDialog,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF4FC3F7),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, color: Color(0xFF4FC3F7)),
            SizedBox(width: 8),
            Text(
              'Add Emergency Contact',
              style: TextStyle(
                color: Color(0xFF4FC3F7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog to add a new contact
  void _showAddContactDialog() {
    // Clear previous input
    _contactNameController.clear();
    _contactPhoneController.clear();
    _contactRelationshipController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B263B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Emergency Contact',
            style: TextStyle(
              color: Color(0xFFE0E0E0),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name field
                _buildDialogTextField(
                  controller: _contactNameController,
                  label: 'Name',
                  hint: 'e.g., John Doe',
                ),
                const SizedBox(height: 16),
                // Phone field
                _buildDialogTextField(
                  controller: _contactPhoneController,
                  label: 'Phone Number',
                  hint: 'e.g., 91234567',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                // Relationship field
                _buildDialogTextField(
                  controller: _contactRelationshipController,
                  label: 'Relationship',
                  hint: 'e.g., Spouse, Parent, Friend',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF778DA9)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate input
                if (_contactNameController.text.trim().isEmpty ||
                    _contactPhoneController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in name and phone number'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // Create contact and add to list
                EmergencyContact newContact = EmergencyContact(
                  name: _contactNameController.text.trim(),
                  phoneNumber: _contactPhoneController.text.trim(),
                  relationship: _contactRelationshipController.text.trim().isEmpty
                      ? 'Contact'
                      : _contactRelationshipController.text.trim(),
                  isPrimary: _emergencyContacts.isEmpty, // First contact is primary
                );

                setState(() {
                  _emergencyContacts.add(newContact);
                });

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3F7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  // Text field for dialog
  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF778DA9),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Color(0xFFE0E0E0)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF415A77)),
            filled: true,
            fillColor: const Color(0xFF0D1B2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF415A77)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF415A77)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4FC3F7)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
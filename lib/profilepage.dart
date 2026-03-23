// =============================================================================
// profilepage.dart - User Profile Page
// This page displays the user's profile information collected during onboarding,
// their gamification progress, earned badges, and app settings.
//
// The profile page serves several purposes:
// - Shows user their household information (can be edited)
// - Displays achievement badges earned through app usage
// - Provides access to emergency contacts management
// - Contains app settings and account options
//
// Data displayed is loaded from SQLite database
// =============================================================================

import 'package:flutter/material.dart';
import 'db.dart';
import 'loginpage.dart';
import 'onboardingscreen.dart';

// ProfilePage Widget
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // STATE VARIABLES

  bool _isLoading = true;

  // User profile data
  String _userName = 'Friend';
  int _adultsCount = 1;
  int _childrenCount = 0;
  int _elderlyCount = 0;
  int _petsCount = 0;
  bool _hasSpecialNeeds = false;

  // Gamification stats
  int _totalPoints = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _tasksCompleted = 0;
  double _preparednessLevel = 0.0;

  // Badges
  List<AchievementBadge> _allBadges = [];
  int _unlockedBadgesCount = 0;

  // Emergency contacts
  List<EmergencyContact> _emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Load Profile Data
  Future<void> _loadProfileData() async {
    try {
      // Fetch user profile
      UserProfile? profile = await DatabaseHelper.instance.getUserProfile();

      // Fetch gamification data
      GamificationData? gamification = await DatabaseHelper.instance.getGamificationData();

      // Fetch all badges
      List<AchievementBadge> badges = await DatabaseHelper.instance.getAllBadges();

      // Fetch emergency contacts
      List<EmergencyContact> contacts = await DatabaseHelper.instance.getEmergencyContacts();

      setState(() {
        // Profile data
        if (profile != null) {
          _userName = profile.name;
          _adultsCount = profile.adultsCount;
          _childrenCount = profile.childrenCount;
          _elderlyCount = profile.elderlyCount;
          _petsCount = profile.petsCount;
          _hasSpecialNeeds = profile.hasSpecialNeeds;
        }

        // Gamification data
        if (gamification != null) {
          _totalPoints = gamification.totalPoints;
          _currentStreak = gamification.currentStreak;
          _longestStreak = gamification.longestStreak;
          _tasksCompleted = gamification.tasksCompleted;
          _preparednessLevel = gamification.preparednessLevel;
        }

        // Badges
        _allBadges = badges;
        _unlockedBadgesCount = badges.where((b) => b.isUnlocked).length;

        // Emergency contacts
        _emergencyContacts = contacts;

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading profile data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

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
      backgroundColor: const Color(0xFF1B263B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFFE0E0E0),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
        onRefresh: _loadProfileData,
        color: const Color(0xFF4FC3F7),
        backgroundColor: const Color(0xFF0D1B2A),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile header with avatar and stats
            _buildProfileHeader(),

            const SizedBox(height: 20),

            // Stats cards row
            _buildStatsRow(),

            const SizedBox(height: 24),

            // Badges section
            _buildSectionTitle('Badges', '${_unlockedBadgesCount}/${_allBadges.length} unlocked'),
            const SizedBox(height: 12),
            _buildBadgesGrid(),

            const SizedBox(height: 24),

            // Household section
            _buildSectionTitle('Household', null),
            const SizedBox(height: 12),
            _buildHouseholdCard(),

            const SizedBox(height: 24),

            // Emergency contacts section
            _buildSectionTitle('Emergency Contacts', null),
            const SizedBox(height: 12),
            _buildEmergencyContactsCard(),

            const SizedBox(height: 24),

            // Settings section
            _buildSectionTitle('Settings', null),
            const SizedBox(height: 12),
            _buildSettingsCard(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // UI COMPONENTS
  // ===========================================================================

  // Loading State
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
            'Loading profile...',
            style: TextStyle(
              color: Color(0xFF778DA9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Profile Header
  // Shows avatar, name, and preparedness level
  Widget _buildProfileHeader() {
    int preparednessPercent = (_preparednessLevel * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF415A77), Color(0xFF5C7A99)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Avatar with first letter of name
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF4FC3F7),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // User name
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          // Preparedness level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🛡️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  '$preparednessPercent% Prepared',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Stats Row
  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard('⭐', _totalPoints.toString(), 'Points'),
        const SizedBox(width: 10),
        _buildStatCard('🔥', _currentStreak.toString(), 'Streak'),
        const SizedBox(width: 10),
        _buildStatCard('✅', _tasksCompleted.toString(), 'Tasks'),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF415A77)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0E0E0),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF778DA9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title, String? subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE0E0E0),
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF778DA9),
            ),
          ),
      ],
    );
  }

  // Badges Grid
  Widget _buildBadgesGrid() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF415A77)),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.85,
        ),
        itemCount: _allBadges.length,
        itemBuilder: (context, index) {
          return _buildBadgeItem(_allBadges[index]);
        },
      ),
    );
  }

  Widget _buildBadgeItem(AchievementBadge badge) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(badge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge icon (greyed out if locked)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: badge.isUnlocked
                  ? const Color(0xFF415A77)
                  : const Color(0xFF1B263B),
              shape: BoxShape.circle,
              border: Border.all(
                color: badge.isUnlocked
                    ? const Color(0xFF4FC3F7)
                    : const Color(0xFF415A77),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                badge.iconName,
                style: TextStyle(
                  fontSize: 22,
                  color: badge.isUnlocked ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Badge name (truncated)
          Text(
            badge.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              color: badge.isUnlocked
                  ? const Color(0xFFE0E0E0)
                  : const Color(0xFF778DA9),
            ),
          ),
        ],
      ),
    );
  }

  // Badge Details Dialog
  void _showBadgeDetails(AchievementBadge badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: badge.isUnlocked
                    ? const Color(0xFF415A77)
                    : const Color(0xFF0D1B2A),
                shape: BoxShape.circle,
                border: Border.all(
                  color: badge.isUnlocked
                      ? const Color(0xFF4FC3F7)
                      : const Color(0xFF415A77),
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  badge.iconName,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Badge name
            Text(
              badge.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0E0E0),
              ),
            ),

            const SizedBox(height: 8),

            // Badge description
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF778DA9),
              ),
            ),

            const SizedBox(height: 12),

            // Unlock status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: badge.isUnlocked
                    ? const Color(0xFF4FC3F7).withOpacity(0.2)
                    : const Color(0xFF415A77).withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge.isUnlocked ? '✓ Unlocked' : '🔒 Locked',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: badge.isUnlocked
                      ? const Color(0xFF4FC3F7)
                      : const Color(0xFF778DA9),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF4FC3F7)),
            ),
          ),
        ],
      ),
    );
  }

  // Household Card
  Widget _buildHouseholdCard() {
    // Calculate total household members
    int totalMembers = _adultsCount + _childrenCount + _elderlyCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF415A77)),
      ),
      child: Column(
        children: [
          // Household summary row
          Row(
            children: [
              const Text('🏠', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalMembers household member${totalMembers != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE0E0E0),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _buildHouseholdSummary(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF778DA9),
                      ),
                    ),
                  ],
                ),
              ),
              // Edit button
              IconButton(
                onPressed: () => _showEditHouseholdDialog(),
                icon: const Icon(
                  Icons.edit,
                  color: Color(0xFF778DA9),
                  size: 20,
                ),
              ),
            ],
          ),

          // Special needs indicator
          if (_hasSpecialNeeds) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF415A77).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Text('♿', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text(
                    'Special needs household member',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE0E0E0),
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

  String _buildHouseholdSummary() {
    List<String> parts = [];
    if (_adultsCount > 0) parts.add('$_adultsCount adult${_adultsCount != 1 ? 's' : ''}');
    if (_childrenCount > 0) parts.add('$_childrenCount child${_childrenCount != 1 ? 'ren' : ''}');
    if (_elderlyCount > 0) parts.add('$_elderlyCount elderly');
    if (_petsCount > 0) parts.add('$_petsCount pet${_petsCount != 1 ? 's' : ''}');
    return parts.join(', ');
  }

  // Edit Household Dialog
  void _showEditHouseholdDialog() {
    // Local variables for editing
    int tempAdults = _adultsCount;
    int tempChildren = _childrenCount;
    int tempElderly = _elderlyCount;
    int tempPets = _petsCount;
    bool tempSpecialNeeds = _hasSpecialNeeds;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1B263B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Edit Household',
            style: TextStyle(
              color: Color(0xFFE0E0E0),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCounterRow('Adults (18-64)', '👤', tempAdults, (val) {
                  setDialogState(() => tempAdults = val);
                }),
                const SizedBox(height: 12),
                _buildCounterRow('Children', '👶', tempChildren, (val) {
                  setDialogState(() => tempChildren = val);
                }),
                const SizedBox(height: 12),
                _buildCounterRow('Elderly (65+)', '👴', tempElderly, (val) {
                  setDialogState(() => tempElderly = val);
                }),
                const SizedBox(height: 12),
                _buildCounterRow('Pets', '🐕', tempPets, (val) {
                  setDialogState(() => tempPets = val);
                }),
                const SizedBox(height: 16),
                // Special needs toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Special needs',
                      style: TextStyle(
                        color: Color(0xFFE0E0E0),
                        fontSize: 14,
                      ),
                    ),
                    Switch(
                      value: tempSpecialNeeds,
                      onChanged: (val) {
                        setDialogState(() => tempSpecialNeeds = val);
                      },
                      activeColor: const Color(0xFF4FC3F7),
                    ),
                  ],
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
              onPressed: () async {
                // Save changes to database
                await _updateHousehold(
                  tempAdults,
                  tempChildren,
                  tempElderly,
                  tempPets,
                  tempSpecialNeeds,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3F7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterRow(String label, String emoji, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 14,
              ),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (value > 0) onChanged(value - 1);
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF415A77),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.remove, color: Colors.white, size: 18),
              ),
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                value.toString(),
                style: const TextStyle(
                  color: Color(0xFFE0E0E0),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => onChanged(value + 1),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC3F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.black, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _updateHousehold(
      int adults,
      int children,
      int elderly,
      int pets,
      bool specialNeeds,
      ) async {
    try {
      UserProfile? profile = await DatabaseHelper.instance.getUserProfile();
      if (profile != null) {
        UserProfile updated = profile.copyWith(
          adultsCount: adults,
          childrenCount: children,
          elderlyCount: elderly,
          petsCount: pets,
          hasSpecialNeeds: specialNeeds,
        );
        await DatabaseHelper.instance.updateUserProfile(updated);
        _showSnackBar('Household info updated!');
        _loadProfileData(); // Refresh
      }
    } catch (e) {
      debugPrint('Error updating household: $e');
      _showSnackBar('Error updating household info');
    }
  }

  // Emergency Contacts Card
  Widget _buildEmergencyContactsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF415A77)),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              const Text('👨‍👩‍👧', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${_emergencyContacts.length} contact${_emergencyContacts.length != 1 ? 's' : ''} saved',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFE0E0E0),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _showManageContactsDialog(),
                child: const Text(
                  'Manage',
                  style: TextStyle(
                    color: Color(0xFF4FC3F7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          // Contact list
          if (_emergencyContacts.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF415A77), height: 1),
            const SizedBox(height: 8),
            ...List.generate(_emergencyContacts.length, (index) {
              EmergencyContact contact = _emergencyContacts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF415A77),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          contact.name.isNotEmpty
                              ? contact.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          Text(
                            '${contact.relationship} • ${contact.phoneNumber}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF778DA9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (contact.isPrimary)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4FC3F7).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Primary',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF4FC3F7),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ] else ...[
            const SizedBox(height: 12),
            const Text(
              'No emergency contacts added yet',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF778DA9),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Manage Contacts Dialog
  // Shows a bottom sheet with full contact management capabilities
  void _showManageContactsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Color(0xFF1B263B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF415A77),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Text(
                        'Emergency Contacts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                      const Spacer(),
                      if (_emergencyContacts.length < 3)
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showAddEditContactDialog(null);
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF4FC3F7),
                          ),
                        ),
                    ],
                  ),
                ),

                const Divider(color: Color(0xFF415A77), height: 1),

                // Contact list
                Expanded(
                  child: _emergencyContacts.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '👨‍👩‍👧',
                          style: TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No emergency contacts yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF778DA9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add contacts to notify during emergencies',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF778DA9),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showAddEditContactDialog(null);
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add Contact'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4FC3F7),
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _emergencyContacts.length,
                    itemBuilder: (context, index) {
                      EmergencyContact contact = _emergencyContacts[index];
                      return ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF415A77),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              contact.name.isNotEmpty
                                  ? contact.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              contact.name,
                              style: const TextStyle(
                                color: Color(0xFFE0E0E0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (contact.isPrimary) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4FC3F7).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Primary',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF4FC3F7),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          '${contact.relationship} • ${contact.phoneNumber}',
                          style: const TextStyle(
                            color: Color(0xFF778DA9),
                            fontSize: 12,
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Color(0xFF778DA9),
                          ),
                          color: const Color(0xFF0D1B2A),
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.pop(context);
                              _showAddEditContactDialog(contact);
                            } else if (value == 'delete') {
                              Navigator.pop(context);
                              _confirmDeleteContact(contact);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Color(0xFF4FC3F7), size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit', style: TextStyle(color: Color(0xFFE0E0E0))),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.redAccent, size: 18),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Info text
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'You can add up to 3 emergency contacts',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF778DA9).withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Add/Edit Contact Dialog
  void _showAddEditContactDialog(EmergencyContact? existingContact) {
    final bool isEditing = existingContact != null;
    final nameController = TextEditingController(text: existingContact?.name ?? '');
    final phoneController = TextEditingController(text: existingContact?.phoneNumber ?? '');
    String selectedRelationship = existingContact?.relationship ?? 'Family';
    bool isPrimary = existingContact?.isPrimary ?? (_emergencyContacts.isEmpty);

    final List<String> relationships = [
      'Family',
      'Spouse',
      'Parent',
      'Sibling',
      'Friend',
      'Neighbor',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1B263B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              isEditing ? 'Edit Contact' : 'Add Contact',
              style: const TextStyle(
                color: Color(0xFFE0E0E0),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name field
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Color(0xFFE0E0E0)),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: const TextStyle(color: Color(0xFF778DA9)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF415A77)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF4FC3F7)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Phone field
                  TextField(
                    controller: phoneController,
                    style: const TextStyle(color: Color(0xFFE0E0E0)),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: const TextStyle(color: Color(0xFF778DA9)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF415A77)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF4FC3F7)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Relationship dropdown
                  DropdownButtonFormField<String>(
                    value: selectedRelationship,
                    dropdownColor: const Color(0xFF0D1B2A),
                    style: const TextStyle(color: Color(0xFFE0E0E0)),
                    decoration: InputDecoration(
                      labelText: 'Relationship',
                      labelStyle: const TextStyle(color: Color(0xFF778DA9)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF415A77)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF4FC3F7)),
                      ),
                    ),
                    items: relationships.map((rel) {
                      return DropdownMenuItem(
                        value: rel,
                        child: Text(rel),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRelationship = value ?? 'Family';
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Primary contact checkbox
                  CheckboxListTile(
                    value: isPrimary,
                    onChanged: (value) {
                      setDialogState(() {
                        isPrimary = value ?? false;
                      });
                    },
                    title: const Text(
                      'Primary Contact',
                      style: TextStyle(
                        color: Color(0xFFE0E0E0),
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'First contact to be notified',
                      style: TextStyle(
                        color: Color(0xFF778DA9),
                        fontSize: 11,
                      ),
                    ),
                    activeColor: const Color(0xFF4FC3F7),
                    checkColor: Colors.black,
                    contentPadding: EdgeInsets.zero,
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
                onPressed: () async {
                  // Validate inputs
                  if (nameController.text.trim().isEmpty) {
                    _showSnackBar('Please enter a name');
                    return;
                  }
                  if (phoneController.text.trim().isEmpty) {
                    _showSnackBar('Please enter a phone number');
                    return;
                  }

                  try {
                    if (isEditing) {
                      // Update existing contact
                      EmergencyContact updatedContact = EmergencyContact(
                        id: existingContact.id,
                        name: nameController.text.trim(),
                        phoneNumber: phoneController.text.trim(),
                        relationship: selectedRelationship,
                        isPrimary: isPrimary,
                      );
                      await DatabaseHelper.instance.updateEmergencyContact(updatedContact);
                      _showSnackBar('Contact updated!');
                    } else {
                      // Add new contact
                      EmergencyContact newContact = EmergencyContact(
                        name: nameController.text.trim(),
                        phoneNumber: phoneController.text.trim(),
                        relationship: selectedRelationship,
                        isPrimary: isPrimary,
                      );
                      await DatabaseHelper.instance.addEmergencyContact(newContact);
                      _showSnackBar('Contact added!');
                    }

                    Navigator.pop(context);
                    _refreshContacts();
                  } catch (e) {
                    _showSnackBar('Error saving contact');
                    debugPrint('Error saving contact: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FC3F7),
                  foregroundColor: Colors.black,
                ),
                child: Text(isEditing ? 'Update' : 'Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Delete Contact Confirmation
  void _confirmDeleteContact(EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Contact?',
          style: TextStyle(
            color: Color(0xFFE0E0E0),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${contact.name} from your emergency contacts?',
          style: const TextStyle(color: Color(0xFF778DA9)),
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
            onPressed: () async {
              try {
                await DatabaseHelper.instance.deleteEmergencyContact(contact.id!);
                Navigator.pop(context);
                _refreshContacts();
                _showSnackBar('Contact deleted');
              } catch (e) {
                _showSnackBar('Error deleting contact');
                debugPrint('Error deleting contact: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Refresh Contacts
  Future<void> _refreshContacts() async {
    List<EmergencyContact> contacts = await DatabaseHelper.instance.getEmergencyContacts();
    setState(() {
      _emergencyContacts = contacts;
    });
  }

  // Settings Card
  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF415A77)),
      ),
      child: Column(
        children: [
          // Account option
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Account',
            subtitle: 'Login or create account',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),

          const Divider(color: Color(0xFF415A77), height: 1),

          // About option
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About TogetherSafe',
            subtitle: 'Version 1.0.0',
            onTap: () {
              _showAboutDialog();
            },
          ),

          const Divider(color: Color(0xFF415A77), height: 1),

          // Reset data option
          _buildSettingsTile(
            icon: Icons.refresh,
            title: 'Reset Progress',
            subtitle: 'Clear all data and start fresh',
            isDestructive: true,
            onTap: () {
              _showResetConfirmation();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red[400] : const Color(0xFF778DA9),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isDestructive ? Colors.red[400] : const Color(0xFFE0E0E0),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF778DA9),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? Colors.red[400] : const Color(0xFF778DA9),
        size: 20,
      ),
      onTap: onTap,
    );
  }

  // About Dialog
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🛡️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text(
              'TogetherSafe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0E0E0),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'A gamified disaster preparedness app for Singapore residents. '
                  'Prepare together, stay safe.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF778DA9),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Final Year Project\nCreated by: Riski Linardi',
              textAlign: TextAlign.center,
              style: TextStyle(

                fontSize: 11,
                color: Color(0xFF415A77),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF4FC3F7)),
            ),
          ),
        ],
      ),
    );
  }

  // Reset Confirmation
  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '⚠️ Reset All Progress?',
          style: TextStyle(
            color: Color(0xFFE0E0E0),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'This will delete all your data including:\n\n'
              '• Profile information\n'
              '• Completed tasks\n'
              '• Points and badges\n'
              '• Emergency contacts\n\n'
              'This action cannot be undone.',
          style: TextStyle(
            color: Color(0xFF778DA9),
            fontSize: 14,
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
            onPressed: () async {
              Navigator.pop(context);
              await _performReset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Perform Reset
  Future<void> _performReset() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4FC3F7),
          ),
        ),
      );

      // Reset the database
      await DatabaseHelper.instance.resetDatabase();

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Navigate to onboarding screen and clear navigation stack
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted) Navigator.pop(context);
      _showSnackBar('Error resetting data. Please try again.');
      debugPrint('Reset error: $e');
    }
  }
}
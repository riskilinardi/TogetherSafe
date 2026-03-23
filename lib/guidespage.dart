// =============================================================================
// guidespage.dart - Emergency Response Guides
// =============================================================================
// This page provides comprehensive emergency response guides for different
// disaster types that may occur in Singapore. Each guide contains step-by-step
// instructions on what to do before, during, and after an emergency.

// The information is based on official guidelines from:
// - Singapore Civil Defence Force (SCDF)
// - National Environment Agency (NEA)
// - Public Utilities Board (PUB)
//
// Guide Categories:
// - Flash Floods: Common in low-lying areas like Bukit Timah
// - Haze: Regional issue from forest fires
// - Fire: Home and building fires
// - Earthquake/Tremors: From Sumatran earthquakes
// - Pandemic: Disease outbreaks (COVID-19 experience)
// =============================================================================

import 'package:flutter/material.dart';

// GuidesPage Widget
class GuidesPage extends StatefulWidget {
  const GuidesPage({Key? key}) : super(key: key);

  @override
  State<GuidesPage> createState() => _GuidesPageState();
}

class _GuidesPageState extends State<GuidesPage> {
  // GUIDE DATA
  // Each guide contains information about a specific disaster type.
  // The data structure includes:
  // - Basic info (title, icon, color, description)
  // - Before/During/After steps
  // - Emergency contacts specific to that disaster

  final List<EmergencyGuide> _guides = [
    // Flash Flood Guide
    EmergencyGuide(
      title: 'Flash Flood',
      icon: '🌊',
      color: const Color(0xFF1976D2),
      description: 'Flash floods can occur suddenly in Singapore, especially in low-lying areas like Bukit Timah and Bedok during heavy rainfall.',
      beforeSteps: [
        'Know if your area is flood-prone (check PUB flood maps)',
        'Keep emergency supplies on higher floors',
        'Store important documents in waterproof containers',
        'Know your evacuation routes to higher ground',
        'Install flood barriers if in high-risk area',
      ],
      duringSteps: [
        'Move immediately to higher ground',
        'Do NOT walk or drive through flood waters',
        'Stay away from drains and canals',
        'Turn off electricity at the main switch if flooding',
        'Call 995 if in immediate danger',
        'Listen to radio/TV for official updates',
      ],
      afterSteps: [
        'Return home only when authorities say it\'s safe',
        'Check for structural damage before entering',
        'Document damage with photos for insurance',
        'Discard food that may have been contaminated',
        'Clean and disinfect everything that got wet',
        'Watch for hazards like weakened structures',
      ],
      emergencyContacts: [
        EmergencyContactInfo('SCDF Emergency', '995', '🚒'),
        EmergencyContactInfo('PUB 24hr Hotline', '1800-225-5782', '💧'),
        EmergencyContactInfo('NEA Hotline', '1800-225-5632', '🏛️'),
      ],
    ),

    // Haze Guide
    EmergencyGuide(
      title: 'Haze',
      icon: '😷',
      color: const Color(0xFF795548),
      description: 'Haze from regional forest fires can cause hazardous air quality. Monitor PSI levels and take precautions when levels are elevated.',
      beforeSteps: [
        'Stock up on N95 masks for all household members',
        'Ensure air-conditioning is in good working order',
        'Get a portable air purifier if possible',
        'Keep windows and doors sealed properly',
        'Stock up on eye drops and throat lozenges',
      ],
      duringSteps: [
        'Check PSI levels regularly on NEA website/app',
        'Stay indoors when PSI exceeds 100',
        'Wear N95 mask if you must go outside',
        'Keep all windows and doors closed',
        'Reduce physical activity, especially outdoors',
        'Drink plenty of water to stay hydrated',
        'Seek medical attention if breathing difficulties occur',
      ],
      afterSteps: [
        'Continue monitoring PSI levels',
        'Ventilate your home when air quality improves',
        'Clean or replace air filters',
        'Check on elderly and vulnerable neighbours',
        'Replenish your mask supply',
      ],
      emergencyContacts: [
        EmergencyContactInfo('NEA PSI Hotline', '1800-225-5632', '📊'),
        EmergencyContactInfo('Health Emergency', '995', '🏥'),
        EmergencyContactInfo('MOH Hotline', '1800-333-9999', '⚕️'),
      ],
    ),

    // Fire Guide
    EmergencyGuide(
      title: 'Fire',
      icon: '🔥',
      color: const Color(0xFFD32F2F),
      description: 'House fires can spread rapidly. Knowing what to do in the first few minutes can save lives.',
      beforeSteps: [
        'Install smoke detectors on every floor',
        'Keep a fire extinguisher in the kitchen',
        'Plan and practice escape routes with family',
        'Identify two exits from every room',
        'Teach children to "Stop, Drop, and Roll"',
        'Never leave cooking unattended',
      ],
      duringSteps: [
        'Alert everyone in the building immediately',
        'Call 995 right away',
        'Feel doors before opening - if hot, use another exit',
        'Stay low to avoid smoke inhalation',
        'Cover nose and mouth with wet cloth if possible',
        'Never use lifts during a fire',
        'If clothes catch fire: Stop, Drop, and Roll',
        'Once out, stay out - never go back inside',
      ],
      afterSteps: [
        'Account for all family members at meeting point',
        'Get medical attention for any injuries or smoke inhalation',
        'Do not re-enter until SCDF declares it safe',
        'Contact insurance company to report damage',
        'Arrange temporary accommodation if needed',
        'Keep records of damaged property',
      ],
      emergencyContacts: [
        EmergencyContactInfo('SCDF Emergency', '995', '🚒'),
        EmergencyContactInfo('Police', '999', '👮'),
        EmergencyContactInfo('Town Council', 'Check notice board', '🏢'),
      ],
    ),

    // Earthquake/Tremors Guide
    EmergencyGuide(
      title: 'Earthquake',
      icon: '🏚️',
      color: const Color(0xFF5D4037),
      description: 'Singapore occasionally experiences tremors from earthquakes in Sumatra. While usually mild, it\'s important to know how to respond.',
      beforeSteps: [
        'Secure heavy furniture and appliances to walls',
        'Know safe spots in each room (under sturdy furniture)',
        'Keep emergency supplies easily accessible',
        'Learn how to turn off gas and electricity',
        'Identify safe areas away from windows and heavy objects',
      ],
      duringSteps: [
        'DROP to the ground',
        'Take COVER under sturdy furniture',
        'HOLD ON until shaking stops',
        'Stay away from windows, mirrors, and heavy objects',
        'If outdoors, move to open area away from buildings',
        'If in a car, stop safely and stay inside',
        'Do NOT run outside during shaking',
      ],
      afterSteps: [
        'Check yourself and others for injuries',
        'Expect aftershocks',
        'Check for gas leaks (smell, don\'t use flames)',
        'Inspect your home for damage',
        'Listen to official announcements',
        'Use text messages instead of calls (less network load)',
        'Stay away from damaged buildings',
      ],
      emergencyContacts: [
        EmergencyContactInfo('SCDF Emergency', '995', '🚒'),
        EmergencyContactInfo('Police', '999', '👮'),
        EmergencyContactInfo('Singapore Red Cross', '6664-0500', '➕'),
      ],
    ),

    // Pandemic Guide
    EmergencyGuide(
      title: 'Pandemic',
      icon: '🦠',
      color: const Color(0xFF388E3C),
      description: 'Disease outbreaks require community cooperation. Following health guidelines protects you and others around you.',
      beforeSteps: [
        'Keep a supply of masks and hand sanitiser',
        'Stock essential medications (2-week supply)',
        'Have non-perishable food supplies',
        'Know how to monitor for symptoms',
        'Keep important health documents accessible',
        'Ensure vaccinations are up to date',
      ],
      duringSteps: [
        'Follow all MOH guidelines and advisories',
        'Practice good hand hygiene frequently',
        'Wear masks in crowded places',
        'Maintain physical distancing when required',
        'Monitor for symptoms daily',
        'Get tested if you have symptoms',
        'Self-isolate if unwell or exposed',
        'Keep home well-ventilated',
      ],
      afterSteps: [
        'Continue practicing good hygiene',
        'Complete any required vaccinations',
        'Stay informed about ongoing advisories',
        'Support community recovery efforts',
        'Seek help for mental health if needed',
        'Replenish emergency supplies',
      ],
      emergencyContacts: [
        EmergencyContactInfo('MOH Hotline', '1800-333-9999', '⚕️'),
        EmergencyContactInfo('Health Emergency', '995', '🏥'),
        EmergencyContactInfo('COVID Helpline', '6325-9220', '🦠'),
      ],
    ),
  ];

  // BUILD METHOD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B263B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        title: const Text(
          'Emergency Guides',
          style: TextStyle(
            color: Color(0xFFE0E0E0),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Introduction text
          _buildIntroSection(),

          const SizedBox(height: 20),

          // Guide cards
          ...List.generate(_guides.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGuideCard(_guides[index]),
            );
          }),

          const SizedBox(height: 20),

          // Emergency numbers card
          _buildEmergencyNumbersCard(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ===========================================================================
  // UI COMPONENTS
  // ===========================================================================

  // Introduction Section
  Widget _buildIntroSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF415A77)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('📚', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Text(
                'Be Prepared',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE0E0E0),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Learn what to do before, during, and after emergencies. '
                'Tap on any guide below to learn more. These guides are based on '
                'official Singapore government recommendations.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF778DA9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Guide Card
  Widget _buildGuideCard(EmergencyGuide guide) {
    return GestureDetector(
      onTap: () => _openGuideDetail(guide),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF415A77)),
        ),
        child: Row(
          children: [
            // Icon circle with color
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: guide.color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: guide.color, width: 2),
              ),
              child: Center(
                child: Text(guide.icon, style: const TextStyle(fontSize: 28)),
              ),
            ),

            const SizedBox(width: 16),

            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guide.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE0E0E0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    guide.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF778DA9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Arrow icon
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF778DA9),
            ),
          ],
        ),
      ),
    );
  }

  // Emergency Numbers Card
  Widget _buildEmergencyNumbersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD32F2F).withOpacity(0.3),
            const Color(0xFFD32F2F).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD32F2F).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🚨', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Text(
                'Emergency Numbers',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE0E0E0),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildEmergencyNumber('995', 'SCDF (Fire & Ambulance)', '🚒'),
          const SizedBox(height: 8),
          _buildEmergencyNumber('999', 'Police', '👮'),
          const SizedBox(height: 8),
          _buildEmergencyNumber('1777', 'Non-Emergency Ambulance', '🚑'),
        ],
      ),
    );
  }

  Widget _buildEmergencyNumber(String number, String label, String icon) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFE0E0E0),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFD32F2F),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Open Guide Detail Page
  void _openGuideDetail(EmergencyGuide guide) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuideDetailPage(guide: guide),
      ),
    );
  }
}


// Full Guide View
// Shows the complete guide with Before/During/After sections.
class GuideDetailPage extends StatelessWidget {
  final EmergencyGuide guide;

  const GuideDetailPage({Key? key, required this.guide}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B263B),
      body: CustomScrollView(
        slivers: [
          // Collapsing app bar with guide header
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF0D1B2A),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF778DA9)),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      guide.color.withOpacity(0.4),
                      const Color(0xFF0D1B2A),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(guide.icon, style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        guide.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Guide content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    guide.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF778DA9),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Before section
                  _buildSection(
                    'Before',
                    '🛡️',
                    'Preparation steps',
                    guide.beforeSteps,
                    const Color(0xFF4FC3F7),
                  ),

                  const SizedBox(height: 16),

                  // During section
                  _buildSection(
                    'During',
                    '⚡',
                    'What to do in the moment',
                    guide.duringSteps,
                    const Color(0xFFFFB74D),
                  ),

                  const SizedBox(height: 16),

                  // After section
                  _buildSection(
                    'After',
                    '✅',
                    'Recovery steps',
                    guide.afterSteps,
                    const Color(0xFF81C784),
                  ),

                  const SizedBox(height: 24),

                  // Emergency contacts for this guide
                  _buildContactsSection(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section Builder
  Widget _buildSection(
      String title,
      String emoji,
      String subtitle,
      List<String> steps,
      Color accentColor,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF415A77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    Text(
                      subtitle,
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

          // Steps list
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: List.generate(steps.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step number
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Step text
                      Expanded(
                        child: Text(
                          steps[index],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFE0E0E0),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Emergency Contacts Section
  Widget _buildContactsSection() {
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
          const Row(
            children: [
              Text('📞', style: TextStyle(fontSize: 20)),
              SizedBox(width: 12),
              Text(
                'Related Contacts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE0E0E0),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...List.generate(guide.emergencyContacts.length, (index) {
            EmergencyContactInfo contact = guide.emergencyContacts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(contact.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      contact.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFE0E0E0),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF415A77),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      contact.number,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4FC3F7),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}


// DATA MODELS

// Emergency guide data model
class EmergencyGuide {
  final String title;
  final String icon;
  final Color color;
  final String description;
  final List<String> beforeSteps;
  final List<String> duringSteps;
  final List<String> afterSteps;
  final List<EmergencyContactInfo> emergencyContacts;

  EmergencyGuide({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.beforeSteps,
    required this.duringSteps,
    required this.afterSteps,
    required this.emergencyContacts,
  });
}

// Emergency contact info for guides
class EmergencyContactInfo {
  final String name;
  final String number;
  final String icon;

  EmergencyContactInfo(this.name, this.number, this.icon);
}
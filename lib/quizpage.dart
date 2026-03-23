// =============================================================================
// quizpage.dart - Adaptive Disaster Preparedness Quizzes
// This page provides interactive quizzes to help users learn about disaster
// preparedness.
//
// ADAPTIVE QUIZ SYSTEM
// The quiz system now adapts to user performance:
// - 3 difficulty levels: Beginner, Intermediate, Advanced
// - Difficulty increases after 3 consecutive correct answers
// - Difficulty decreases after 2 wrong answers in 5 questions
// - Points scale with difficulty: 10/15/25 per correct answer
// - Progress tracked separately per category
//
// Quiz Categories:
// - Flash Flood Safety (Flood)
// - Fire Emergency (Fire)
// - Haze Protection (Haze)
// - Earthquake Response (Earthquake)
// - General Preparedness (General)
// =============================================================================

import 'package:flutter/material.dart';
import 'db.dart';

// QuizPage - Quiz Selection Screen
class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // User's current difficulty level for each category
  Map<String, int> _userDifficulties = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDifficulties();
  }

  // Load user's difficulty levels from database
  Future<void> _loadUserDifficulties() async {
    Map<String, UserQuizDifficulty> difficulties =
    await DatabaseHelper.instance.getAllQuizDifficulties();

    setState(() {
      for (var entry in difficulties.entries) {
        _userDifficulties[entry.key] = entry.value.difficultyLevel;
      }
      _isLoading = false;
    });
  }

  // QUIZ DATA WITH DIFFICULTY LEVELS
  // Each quiz now contains questions at 3 difficulty levels:
  // - Beginner (1): Basic facts and emergency numbers
  // - Intermediate (2): Procedures and situational responses
  // - Advanced (3): Complex scenarios and prioritization
  //
  // Questions are based on official Singapore guidelines (SCDF, NEA, PUB).

  final List<QuizCategory> _quizCategories = [
    // Flash Flood Quiz
    QuizCategory(
      title: 'Flash Flood Safety',
      categoryKey: 'Flood', // Matches database category
      icon: '🌊',
      color: const Color(0xFF1976D2),
      description: 'Test your knowledge on flood safety procedures',
      questions: [
        // BEGINNER QUESTIONS (Level 1) - Basic facts
        QuizQuestion(
          question: 'What is the emergency number for SCDF in Singapore?',
          options: ['999', '911', '995', '1800'],
          correctIndex: 2,
          explanation: '995 is the emergency number for SCDF (Singapore Civil Defence Force) for fire and ambulance services.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'Which area in Singapore is known to be flood-prone?',
          options: ['Marina Bay', 'Bukit Timah', 'Changi Airport', 'Sentosa'],
          correctIndex: 1,
          explanation: 'Bukit Timah is a known flood-prone area due to its low-lying terrain. PUB has been upgrading drainage systems in this area.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'Which agency manages flood control in Singapore?',
          options: ['NEA', 'SCDF', 'PUB', 'LTA'],
          correctIndex: 2,
          explanation: 'PUB (Public Utilities Board) is responsible for water management including flood control and drainage systems.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'How deep must water be to knock an adult off their feet?',
          options: ['5cm', '15cm', '50cm', '100cm'],
          correctIndex: 1,
          explanation: 'Just 15cm of fast-moving water can knock an adult off their feet. Never underestimate flood water.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'What colour are flood warning signs in Singapore?',
          options: ['Red', 'Yellow', 'Blue', 'Green'],
          correctIndex: 1,
          explanation: 'Flood warning signs are typically yellow to indicate caution and potential danger ahead.',
          difficulty: 1,
        ),

        // INTERMEDIATE QUESTIONS (Level 2) - Procedures
        QuizQuestion(
          question: 'What should you do if you encounter a flooded road while driving?',
          options: [
            'Drive through slowly',
            'Turn around and find another route',
            'Speed up to get through quickly',
            'Wait for other cars to go first',
          ],
          correctIndex: 1,
          explanation: 'Never drive through flooded roads. Just 15cm of moving water can knock you off your feet, and 60cm can float a car. Turn around, don\'t drown!',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'During a flash flood warning, you should:',
          options: [
            'Go outside to take photos',
            'Move to higher ground immediately',
            'Wait to see if it gets worse',
            'Try to save items from the ground floor',
          ],
          correctIndex: 1,
          explanation: 'Always move to higher ground immediately during a flood warning. Your safety is more important than belongings.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'What should you NOT do during a flood?',
          options: [
            'Turn off electrical appliances',
            'Move to upper floors',
            'Walk through floodwater to check on neighbours',
            'Listen to official announcements',
          ],
          correctIndex: 2,
          explanation: 'Never walk through floodwater - it may be contaminated, have hidden hazards, or have strong currents that can sweep you away.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'If trapped on an upper floor during flooding, you should:',
          options: [
            'Jump into the water to escape',
            'Signal for help and wait for rescue',
            'Try to swim to safety',
            'Break through the roof immediately',
          ],
          correctIndex: 1,
          explanation: 'Stay put, signal for help using bright cloth or lights, and wait for rescue. Do not enter floodwater unless absolutely necessary.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'Before a predicted flood, you should:',
          options: [
            'Move valuables to higher ground and charge devices',
            'Go shopping for supplies',
            'Check on your car parked outside',
            'Continue normal activities',
          ],
          correctIndex: 0,
          explanation: 'Move important items upstairs, charge phones and powerbanks, fill bathtubs with clean water, and prepare emergency kit.',
          difficulty: 2,
        ),

        // ADVANCED QUESTIONS (Level 3) - Complex scenarios
        QuizQuestion(
          question: 'Your car stalls in rising floodwater. Water is at door level. What is the correct sequence of actions?',
          options: [
            'Call 995, then try to restart car, then exit if unsuccessful',
            'Unbuckle seatbelt, lower window, exit through window, move to high ground',
            'Stay in car with seatbelt on and wait for water to recede',
            'Open door immediately and run to nearest building',
          ],
          correctIndex: 1,
          explanation: 'Unbuckle first (you may need to cut it), lower window before electronics fail, exit through window (doors may be stuck), and move to higher ground. Do not wait - act quickly.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'You live in a flood-prone HDB ground floor. Heavy rain is forecast for 3 days. Prioritize these actions:',
          options: [
            'Move valuables up, prepare go-bag, identify evacuation route, inform family',
            'Buy sandbags, check insurance, call neighbours, stock up food',
            'Wait for official warning, then decide on actions',
            'Move car to higher ground, continue normal activities',
          ],
          correctIndex: 0,
          explanation: 'Prioritize: protect irreplaceable items first, prepare emergency bag, know your evacuation options, and ensure family has communication plan.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'During flood evacuation, your elderly neighbour refuses to leave despite rising water. What should you do?',
          options: [
            'Respect their decision and leave',
            'Physically force them to come with you',
            'Inform authorities while continuing to persuade, note their location',
            'Stay with them until they change their mind',
          ],
          correctIndex: 2,
          explanation: 'You cannot force someone to evacuate, but you should inform rescue services of their location and vulnerability. Continue gentle persuasion but prioritize your own safety.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'Floodwater has receded from your home. What hazard should you check for FIRST before entering?',
          options: [
            'Mould growth on walls',
            'Structural damage and gas leaks',
            'Damage to furniture',
            'Whether electricity is working',
          ],
          correctIndex: 1,
          explanation: 'Check for structural damage (cracks, shifting), gas leaks (smell), and electrical hazards BEFORE entering. Never turn on electricity until system is checked by professional.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'You are managing your family during a flood emergency. Who should you prioritize evacuating first?',
          options: [
            'Working adults who can help with evacuation',
            'Elderly, children, those with medical conditions, then pets',
            'Everyone should leave at the same time',
            'Those closest to the exit first',
          ],
          correctIndex: 1,
          explanation: 'Prioritize vulnerable members: elderly, young children, those with medical needs or mobility issues. They need more time and assistance to evacuate safely.',
          difficulty: 3,
        ),
      ],
    ),

    // Fire Emergency Quiz
    QuizCategory(
      title: 'Fire Emergency',
      categoryKey: 'Fire',
      icon: '🔥',
      color: const Color(0xFFD32F2F),
      description: 'Learn essential fire safety knowledge',
      questions: [
        // BEGINNER QUESTIONS (Level 1)
        QuizQuestion(
          question: 'What is the emergency number for fire services in Singapore?',
          options: ['999', '995', '911', '1777'],
          correctIndex: 1,
          explanation: '995 is the emergency number for SCDF including fire and ambulance services.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'What does the acronym PASS stand for in fire extinguisher use?',
          options: [
            'Push, Aim, Spray, Sweep',
            'Pull, Aim, Squeeze, Sweep',
            'Point, Activate, Spray, Stop',
            'Pull, Activate, Spray, Sweep',
          ],
          correctIndex: 1,
          explanation: 'PASS: Pull the pin, Aim at base of fire, Squeeze the handle, Sweep side to side.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'How often should smoke detectors be tested?',
          options: ['Daily', 'Monthly', 'Yearly', 'Only when moving in'],
          correctIndex: 1,
          explanation: 'Test smoke detectors monthly and replace batteries at least once a year.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'What type of fire extinguisher is safe for electrical fires?',
          options: ['Water', 'CO2 or dry powder', 'Foam', 'Any type'],
          correctIndex: 1,
          explanation: 'CO2 or dry powder extinguishers are safe for electrical fires. Never use water on electrical fires.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'Where should fire extinguishers be placed in an HDB flat?',
          options: ['Bedroom', 'Near kitchen exit', 'Bathroom', 'Store room'],
          correctIndex: 1,
          explanation: 'Place extinguishers near the kitchen exit so you can access it while having an escape route behind you.',
          difficulty: 1,
        ),

        // INTERMEDIATE QUESTIONS (Level 2)
        QuizQuestion(
          question: 'What is the first thing you should do if you discover a fire?',
          options: [
            'Try to put it out yourself',
            'Grab your valuables',
            'Alert everyone and call 995',
            'Open windows for ventilation',
          ],
          correctIndex: 2,
          explanation: 'Always alert others and call 995 first. Getting everyone to safety is the priority.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'If your clothes catch fire, you should:',
          options: [
            'Run to find water',
            'Stop, Drop, and Roll',
            'Remove the clothing immediately',
            'Fan the flames with your hands',
          ],
          correctIndex: 1,
          explanation: 'Stop, Drop, and Roll is the correct technique. Running fans the flames and makes it worse.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'During a fire, should you use the lift?',
          options: [
            'Yes, it\'s faster',
            'Only if the fire is on a lower floor',
            'Never use lifts during a fire',
            'Only in HDB buildings',
          ],
          correctIndex: 2,
          explanation: 'Never use lifts during a fire. They may stop at the fire floor or lose power, trapping you inside.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'Before opening a door during a fire, you should:',
          options: [
            'Open it quickly to escape faster',
            'Feel the door with the back of your hand',
            'Look through the keyhole',
            'Kick it down',
          ],
          correctIndex: 1,
          explanation: 'Feel the door with the back of your hand. If it\'s hot, there may be fire on the other side - use another exit.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'What is the best position to move through a smoky area?',
          options: [
            'Stand upright and run',
            'Crawl low under the smoke',
            'Hold your breath and walk normally',
            'Cover your eyes and run',
          ],
          correctIndex: 1,
          explanation: 'Smoke rises, so crawl low where the air is cleaner. Cover your nose and mouth with a wet cloth if possible.',
          difficulty: 2,
        ),

        // ADVANCED QUESTIONS (Level 3)
        QuizQuestion(
          question: 'Fire breaks out in your HDB kitchen. Flames are spreading to curtains. In what order should you act?',
          options: [
            'Call 995, try to fight fire, then evacuate',
            'Alert family, attempt to contain if safe, evacuate and call 995',
            'Evacuate immediately without any other action',
            'Fight the fire until extinguisher is empty',
          ],
          correctIndex: 1,
          explanation: 'Alert everyone first (seconds matter), only fight if small and you have escape route, evacuate closing doors behind you, then call 995 from safe location.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'You smell gas in your HDB flat. What should you NOT do?',
          options: [
            'Open windows for ventilation',
            'Turn off gas supply at meter',
            'Switch on lights to see better',
            'Leave the flat immediately',
          ],
          correctIndex: 2,
          explanation: 'Never operate any electrical switches (on or off) as sparks can ignite gas. Open windows, turn off gas at main, leave, and call for help from outside.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'Your neighbour\'s flat is on fire. Dense smoke is filling the corridor. Your family of 4 needs to evacuate. What is the safest approach?',
          options: [
            'Run through the smoke quickly to the stairwell',
            'Wet towels, crawl low, stay together, use farthest stairwell from fire',
            'Wait in your flat for firefighters',
            'Use the lift as it\'s faster',
          ],
          correctIndex: 1,
          explanation: 'Wet towels to filter smoke, crawl below smoke level, keep family together (hold hands), use stairwell farthest from fire. If smoke too dense, return to flat and seal doors.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'You cannot escape your flat due to fire blocking exits. What should you do?',
          options: [
            'Jump from the window',
            'Hide in bathroom with door closed',
            'Go to room farthest from fire, seal door, signal from window',
            'Try to run through the flames quickly',
          ],
          correctIndex: 2,
          explanation: 'Go to room farthest from fire, close door and seal gaps with wet cloth, open window slightly for air, signal for help with cloth or torch. Firefighters will come.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'An oil fire starts in your frying pan. What is the correct response?',
          options: [
            'Pour water on it to cool it down',
            'Turn off heat, cover with metal lid or wet cloth, do not move pan',
            'Move the pan to the sink',
            'Use a fire extinguisher immediately',
          ],
          correctIndex: 1,
          explanation: 'Never use water on oil fires (causes explosion). Turn off heat, smother with metal lid or damp cloth, leave covered until cool. Do not move - hot oil can spill.',
          difficulty: 3,
        ),
      ],
    ),

    // Haze Protection Quiz
    QuizCategory(
      title: 'Haze Protection',
      categoryKey: 'Haze',
      icon: '😷',
      color: const Color(0xFF795548),
      description: 'Know how to protect yourself during haze',
      questions: [
        // BEGINNER QUESTIONS (Level 1)
        QuizQuestion(
          question: 'What does PSI stand for?',
          options: [
            'Pollution Safety Index',
            'Pollutant Standards Index',
            'Particle Size Indicator',
            'Public Safety Information',
          ],
          correctIndex: 1,
          explanation: 'PSI stands for Pollutant Standards Index, used to measure air quality in Singapore.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'What agency monitors PSI levels in Singapore?',
          options: ['SCDF', 'NEA', 'PUB', 'MOH'],
          correctIndex: 1,
          explanation: 'NEA (National Environment Agency) monitors and reports PSI levels in Singapore.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'Which type of mask is effective against haze particles?',
          options: ['Surgical mask', 'Cloth mask', 'N95 mask', 'Any mask'],
          correctIndex: 2,
          explanation: 'N95 masks filter at least 95% of airborne particles. Surgical and cloth masks are not effective against fine haze particles.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'What PSI range is considered "Unhealthy"?',
          options: ['51-100', '101-200', '201-300', '301+'],
          correctIndex: 1,
          explanation: 'PSI 101-200 is Unhealthy range. Above 200 is Very Unhealthy, above 300 is Hazardous.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'Where does Singapore\'s haze typically originate from?',
          options: [
            'Local factories',
            'Forest fires in Indonesia',
            'Vehicle emissions',
            'Construction sites',
          ],
          correctIndex: 1,
          explanation: 'Singapore\'s haze is primarily caused by forest and peat fires in Sumatra and Kalimantan, Indonesia.',
          difficulty: 1,
        ),

        // INTERMEDIATE QUESTIONS (Level 2)
        QuizQuestion(
          question: 'At what PSI level should you avoid outdoor activities?',
          options: ['Above 50', 'Above 100', 'Above 200', 'Above 300'],
          correctIndex: 1,
          explanation: 'When PSI exceeds 100 (Unhealthy range), you should reduce prolonged outdoor activities, especially if you have health conditions.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'During haze, you should:',
          options: [
            'Open windows for fresh air',
            'Keep windows and doors closed',
            'Use a fan to blow air outside',
            'Exercise outdoors in the morning',
          ],
          correctIndex: 1,
          explanation: 'Keep all windows and doors closed to prevent haze particles from entering your home. Use air conditioning if available.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'Which group is most vulnerable to haze effects?',
          options: [
            'Teenagers',
            'Working adults',
            'Elderly and young children',
            'Everyone is equally affected',
          ],
          correctIndex: 2,
          explanation: 'Elderly, young children, pregnant women, and those with heart/lung conditions are most vulnerable to haze effects.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'How should you properly wear an N95 mask?',
          options: [
            'Cover nose only, mouth can be exposed',
            'Ensure tight seal around nose and chin, no gaps',
            'Wear loosely for comfort',
            'One mask can be shared among family',
          ],
          correctIndex: 1,
          explanation: 'N95 must seal tightly around nose and chin with no gaps. Perform fit check - mask should move when you breathe. One mask per person.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'What should you do if PSI exceeds 300?',
          options: [
            'Continue normal outdoor activities',
            'Minimise all outdoor activity, stay indoors',
            'Exercise indoors only',
            'Wear surgical mask outdoors',
          ],
          correctIndex: 1,
          explanation: 'PSI above 300 is Hazardous. Minimise all outdoor activity, stay indoors with air purifier if possible, and wear N95 if going out is necessary.',
          difficulty: 2,
        ),

        // ADVANCED QUESTIONS (Level 3)
        QuizQuestion(
          question: 'Your elderly parent with COPD lives alone during hazardous haze (PSI 350+). What should you prioritize?',
          options: [
            'Send N95 masks via delivery',
            'Bring them to stay with you in air-conditioned home',
            'Call to remind them to stay indoors',
            'Let them manage as usual',
          ],
          correctIndex: 1,
          explanation: 'People with respiratory conditions are extremely vulnerable. Best to relocate them to air-conditioned environment. N95 masks may be difficult for COPD patients to breathe through.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'Schools are closed due to hazardous PSI. Your children have tuition and enrichment classes scheduled. What should you do?',
          options: [
            'Send them as classes are indoors anyway',
            'Cancel all activities, minimise any outdoor travel',
            'Let them decide based on how they feel',
            'Drive them to activities if distance is short',
          ],
          correctIndex: 1,
          explanation: 'Even brief outdoor exposure during hazardous PSI is harmful. Travel between buildings exposes them to haze. Cancel non-essential activities and keep children indoors.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'You manage outdoor workers. PSI has reached 200 and forecast to worsen. What is the correct protocol?',
          options: [
            'Continue work with N95 masks',
            'Reduce outdoor work, schedule more breaks in air-con, monitor workers\' health',
            'Cancel all work until PSI drops below 100',
            'Workers can decide individually',
          ],
          correctIndex: 1,
          explanation: 'At PSI 200, reduce outdoor work duration, provide regular breaks in air-conditioned areas, supply N95 masks, have medical support on standby, and monitor vulnerable workers closely.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'Your home has no air conditioning and PSI is 280. What is the most effective way to reduce indoor haze exposure?',
          options: [
            'Open windows slightly for ventilation',
            'Seal windows, use portable air purifier with HEPA filter',
            'Use table fan to circulate air',
            'Burn scented candles to mask the smell',
          ],
          correctIndex: 1,
          explanation: 'Seal all gaps, use air purifier with HEPA filter (effective against PM2.5). Avoid creating more particles (candles, cooking). Consider temporary relocation to air-conditioned public spaces.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'After prolonged haze exposure, when should you seek medical attention?',
          options: [
            'Only if you faint',
            'Persistent cough, breathing difficulty, chest tightness, worsening of existing conditions',
            'Mild eye irritation',
            'Feeling slightly tired',
          ],
          correctIndex: 1,
          explanation: 'Seek medical attention for: persistent cough, shortness of breath, chest pain/tightness, severe headache, dizziness, or worsening of asthma/heart conditions. Don\'t wait for symptoms to become severe.',
          difficulty: 3,
        ),
      ],
    ),

    // Earthquake Response Quiz
    // Singapore experiences occasional tremors from earthquakes in
    // neighbouring Indonesia (Sumatra).
    QuizCategory(
      title: 'Earthquake Response',
      categoryKey: 'Earthquake', // Matches database category
      icon: '🏚️',
      color: const Color(0xFF795548),
      description: 'Learn how to respond to earthquake tremors',
      questions: [
        // BEGINNER QUESTIONS (Level 1) - Basic facts
        QuizQuestion(
          question: 'Where do most earthquakes affecting Singapore originate?',
          options: ['Philippines', 'Sumatra, Indonesia', 'Japan', 'India'],
          correctIndex: 1,
          explanation: 'Singapore occasionally feels tremors from earthquakes originating in Sumatra, Indonesia, which lies along the Pacific Ring of Fire.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'What does "Drop, Cover, and Hold On" mean during an earthquake?',
          options: [
            'Run outside immediately',
            'Drop to the ground, take cover under sturdy furniture, hold on until shaking stops',
            'Stand in a doorway',
            'Lie flat on the floor without cover',
          ],
          correctIndex: 1,
          explanation: '"Drop, Cover, and Hold On" is the internationally recommended action: drop to your hands and knees, take cover under a sturdy desk or table, and hold on until the shaking stops.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'Which agency monitors seismic activity affecting Singapore?',
          options: ['NEA', 'MSS (Meteorological Service Singapore)', 'PUB', 'SCDF'],
          correctIndex: 1,
          explanation: 'The Meteorological Service Singapore (MSS) monitors seismic activity and issues information about earthquakes that may affect Singapore.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'What scale is commonly used to measure earthquake magnitude?',
          options: ['Kelvin scale', 'Richter scale', 'PSI scale', 'Beaufort scale'],
          correctIndex: 1,
          explanation: 'The Richter scale (or moment magnitude scale) measures earthquake magnitude. Higher numbers indicate stronger earthquakes.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'In a high-rise building, where is the safest place during an earthquake?',
          options: [
            'Near windows',
            'In the lift/elevator',
            'Away from windows, under sturdy furniture',
            'On the balcony',
          ],
          correctIndex: 2,
          explanation: 'Stay away from windows, mirrors, and heavy objects that could fall. Take cover under sturdy furniture away from exterior walls.',
          difficulty: 1,
        ),

        // INTERMEDIATE QUESTIONS (Level 2) - Procedures
        QuizQuestion(
          question: 'If you are in bed when an earthquake occurs, you should:',
          options: [
            'Run to the nearest exit',
            'Stay in bed and protect your head with a pillow',
            'Stand in the doorway',
            'Go to the window to see what is happening',
          ],
          correctIndex: 1,
          explanation: 'If in bed, stay there and protect your head with a pillow. Moving during shaking increases the risk of injury from falling objects.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'After an earthquake, what should you check first in your HDB flat?',
          options: [
            'Your social media',
            'Gas leaks and structural damage',
            'Whether your car is okay',
            'If the TV is working',
          ],
          correctIndex: 1,
          explanation: 'After shaking stops, check for gas leaks (smell for gas, do not use flames), structural damage (cracks in walls/ceiling), and water leaks. Turn off utilities if you suspect damage.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'During an earthquake, you should NOT:',
          options: [
            'Drop to the ground',
            'Use the lift/elevator to evacuate quickly',
            'Take cover under a sturdy table',
            'Hold on until shaking stops',
          ],
          correctIndex: 1,
          explanation: 'Never use lifts during or immediately after an earthquake. They may become stuck or damaged. Use stairs for evacuation after shaking stops.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'If outdoors during an earthquake, you should:',
          options: [
            'Run inside the nearest building',
            'Move away from buildings, streetlights, and utility wires',
            'Stand next to a wall for support',
            'Get into your car immediately',
          ],
          correctIndex: 1,
          explanation: 'If outdoors, move to an open area away from buildings, trees, streetlights, and utility wires. Drop to the ground if shaking is severe.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'What should you include in your earthquake emergency kit?',
          options: [
            'Only bottled water',
            'Torch, first aid kit, water, battery-powered radio, important documents',
            'Just your phone and charger',
            'Only canned food',
          ],
          correctIndex: 1,
          explanation: 'A complete earthquake kit should include: torch with batteries, first aid kit, 3-day water supply, battery-powered radio, important documents, medications, and non-perishable food.',
          difficulty: 2,
        ),

        // ADVANCED QUESTIONS (Level 3) - Complex scenarios
        QuizQuestion(
          question: 'You are on the 15th floor of an HDB block when tremors start. The shaking lasts 30 seconds. What is your BEST course of action?',
          options: [
            'Immediately run down the stairs',
            'Drop, cover under sturdy furniture, hold on, then assess after shaking stops',
            'Open all windows and stand near them for fresh air',
            'Call 995 while the shaking continues',
          ],
          correctIndex: 1,
          explanation: 'In a high-rise, attempting to move during shaking is dangerous. Drop, cover, and hold on. After shaking stops, check for hazards, then calmly evacuate via stairs if necessary. Do not use lifts.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'After a significant earthquake, you smell gas in your HDB flat. What is the correct sequence of actions?',
          options: [
            'Turn on lights to see better, then open windows',
            'Do NOT use electrical switches, open windows, turn off gas supply, evacuate, call for help from outside',
            'Call 995 immediately using your mobile phone inside the flat',
            'Ignore it if you do not see any fire',
          ],
          correctIndex: 1,
          explanation: 'Gas + electrical spark = explosion risk. Do not operate any switches. Open windows for ventilation, turn off the gas supply at the mains, evacuate, then call emergency services from outside.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'You are driving on the expressway when you feel your car shaking from an earthquake. What should you do?',
          options: [
            'Speed up to get off the expressway quickly',
            'Stop suddenly and get out of the car',
            'Gradually slow down, pull over safely away from overpasses, stay in the car until shaking stops',
            'Continue driving at normal speed',
          ],
          correctIndex: 2,
          explanation: 'Gradually reduce speed and pull over to a safe area, avoiding overpasses, bridges, power lines, and signs. Stay in the car with seatbelt fastened until shaking stops. The car\'s suspension provides some protection.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'In the event of a major earthquake affecting Singapore, which of these is the PRIMARY risk for high-rise residents?',
          options: [
            'The building will definitely collapse',
            'Non-structural damage: falling objects, broken glass, lift failures',
            'Immediate flooding',
            'Fire from volcanic activity',
          ],
          correctIndex: 1,
          explanation: 'Singapore buildings are built to code and unlikely to collapse from distant earthquakes. The main risks are non-structural: falling objects, shattered glass, furniture tipping, and lift malfunctions. Secure heavy items at home.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'After an earthquake, you discover cracks in your HDB walls. What should you do?',
          options: [
            'Immediately fill them with cement',
            'Post photos online and wait for responses',
            'Document with photos, report to Town Council/BCA, avoid using affected rooms until assessed',
            'Ignore hairline cracks as they are cosmetic',
          ],
          correctIndex: 2,
          explanation: 'Document any structural damage with photos. Report to your Town Council and BCA (Building and Construction Authority). Avoid affected rooms until a professional assessment is done. Even hairline cracks should be reported after seismic events.',
          difficulty: 3,
        ),
      ],
    ),

    // General Preparedness Quiz
    QuizCategory(
      title: 'General Preparedness',
      categoryKey: 'General',
      icon: '🎒',
      color: const Color(0xFF388E3C),
      description: 'Test your overall emergency preparedness',
      questions: [
        // BEGINNER QUESTIONS (Level 1)
        QuizQuestion(
          question: 'What is the police emergency number in Singapore?',
          options: ['995', '999', '911', '1800'],
          correctIndex: 1,
          explanation: '999 is for police emergencies. 995 is for SCDF (fire and ambulance).',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'What is the non-emergency ambulance number in Singapore?',
          options: ['995', '999', '1777', '1800'],
          correctIndex: 2,
          explanation: '1777 is for non-emergency ambulance services. Use 995 only for life-threatening emergencies.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'How much water should you store per person per day for emergencies?',
          options: ['500ml', '1 litre', '2-3 litres', '5 litres'],
          correctIndex: 2,
          explanation: 'Store at least 2-3 litres of water per person per day. A minimum 3-day supply is recommended.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'How long should your emergency food supply last?',
          options: ['1 day', '3 days minimum', '1 week', '1 month'],
          correctIndex: 1,
          explanation: 'Store at least 3 days supply of non-perishable food. This gives time for help to arrive in most emergencies.',
          difficulty: 1,
        ),
        QuizQuestion(
          question: 'What type of radio is best for emergencies?',
          options: [
            'Smartphone radio app',
            'Car radio',
            'Battery or hand-crank radio',
            'Internet streaming',
          ],
          correctIndex: 2,
          explanation: 'Battery or hand-crank radios work without electricity or internet, which may fail during emergencies.',
          difficulty: 1,
        ),

        // INTERMEDIATE QUESTIONS (Level 2)
        QuizQuestion(
          question: 'What should be included in an emergency kit?',
          options: [
            'Only food and water',
            'Flashlight, first aid kit, water, and important documents',
            'Just a phone and charger',
            'Only medications',
          ],
          correctIndex: 1,
          explanation: 'A complete emergency kit includes water, food, flashlight, first aid kit, medications, important documents, radio, and batteries.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'How often should you check and update your emergency kit?',
          options: [
            'Once every 5 years',
            'Every 6-12 months',
            'Only when there\'s a warning',
            'Never, once prepared is enough',
          ],
          correctIndex: 1,
          explanation: 'Check your emergency kit every 6-12 months to replace expired items and update contents based on your family\'s needs.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'Your family emergency plan should include:',
          options: [
            'Only emergency numbers',
            'Meeting points, contact numbers, and evacuation routes',
            'Just a map of your house',
            'Only the location of the nearest hospital',
          ],
          correctIndex: 1,
          explanation: 'A complete family emergency plan includes meeting points, emergency contacts, evacuation routes, and roles for each family member.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'Where should you keep copies of important documents?',
          options: [
            'Only in your home',
            'Waterproof container at home AND digital backup/off-site copy',
            'On your phone only',
            'With a neighbour',
          ],
          correctIndex: 1,
          explanation: 'Keep originals in waterproof container, store copies off-site (relative\'s house or safe deposit), and maintain digital backups in cloud storage.',
          difficulty: 2,
        ),
        QuizQuestion(
          question: 'How should you prepare if a family member has medical needs?',
          options: [
            'Rely on hospitals during emergencies',
            'Keep extra medication supply, medical info card, and backup power for devices',
            'Just bring IC and hospital card',
            'No special preparation needed',
          ],
          correctIndex: 1,
          explanation: 'Keep 7-day medication supply, medical information card with conditions and allergies, backup batteries for medical devices, and doctor contact information.',
          difficulty: 2,
        ),

        // ADVANCED QUESTIONS (Level 3)
        QuizQuestion(
          question: 'You live with 2 young children, elderly parent, and a dog. Prioritize these emergency kit items given limited space:',
          options: [
            'Adult food, torch, radio, cash',
            'Children\'s needs, medications, water, first aid, pet supplies, torch',
            'Equal amounts of everything',
            'Focus only on food and water',
          ],
          correctIndex: 1,
          explanation: 'Prioritize: children\'s specific needs (formula, diapers), elderly medications, water (heaviest but essential), first aid, pet supplies, then general items. Tailor to your household.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'During a prolonged power outage, in what order should you consume food from your home?',
          options: [
            'Start with canned food to save fridge items',
            'Fridge items first, then freezer, then non-perishables',
            'Non-perishables first, save fridge for last',
            'Order doesn\'t matter',
          ],
          correctIndex: 1,
          explanation: 'Eat fridge items first (spoil in 4 hours), then freezer (24-48 hours if full), then non-perishables. Keep freezer closed to maintain temperature.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'Your emergency contact is overseas. What alternative arrangements should you make?',
          options: [
            'No alternatives needed',
            'Local emergency contact, out-of-area contact who can relay messages, backup meeting point',
            'Just use social media',
            'Wait until they return',
          ],
          correctIndex: 1,
          explanation: 'Have local emergency contact, out-of-area contact (less affected by local disaster) who family can check in with, physical meeting points, and agreed communication protocol.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'A major emergency has disrupted utilities for 48+ hours. Mobile networks are congested. How should you communicate with family?',
          options: [
            'Keep calling until it works',
            'Use SMS (works better than calls), designated check-in times, physical meeting point as backup',
            'Wait for networks to recover',
            'Use social media only',
          ],
          correctIndex: 1,
          explanation: 'SMS uses less bandwidth than calls (more likely to go through). Agree on check-in times to avoid congesting networks. Have physical backup meeting point. Conserve phone battery.',
          difficulty: 3,
        ),
        QuizQuestion(
          question: 'You receive conflicting emergency information from social media and official channels. What should you do?',
          options: [
            'Trust social media as it\'s faster',
            'Verify with official sources (gov.sg, CNA), be cautious of unverified claims',
            'Believe whichever has more shares',
            'Ignore all information and rely on instinct',
          ],
          correctIndex: 1,
          explanation: 'Trust official channels (gov.sg, SCDF, NEA, CNA). Be sceptical of unverified social media. Check multiple official sources. Report misinformation. Act on confirmed information only.',
          difficulty: 3,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B263B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF778DA9)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quizzes',
          style: TextStyle(
            color: Color(0xFFE0E0E0),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4FC3F7)))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          _buildHeaderCard(),

          const SizedBox(height: 20),

          // Quiz categories
          ...List.generate(_quizCategories.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildQuizCard(_quizCategories[index]),
            );
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
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
              Text('🧠', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Text(
                'Adaptive Quizzes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE0E0E0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Quizzes adapt to your skill level! Answer correctly to unlock '
                'harder questions with bonus points.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF778DA9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          // Difficulty legend
          Row(
            children: [
              _buildDifficultyChip('Beginner', '10 pts', const Color(0xFF81C784)),
              const SizedBox(width: 8),
              _buildDifficultyChip('Intermediate', '15 pts', const Color(0xFFFFB74D)),
              const SizedBox(width: 8),
              _buildDifficultyChip('Advanced', '25 pts', const Color(0xFFE57373)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(String label, String points, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        '$label: $points',
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildQuizCard(QuizCategory quiz) {
    // Get user's current difficulty for this category
    int userDifficulty = _userDifficulties[quiz.categoryKey] ?? 1;
    String difficultyName = DatabaseHelper.instance.getDifficultyName(userDifficulty);
    int pointsPerQuestion = DatabaseHelper.instance.getPointsForDifficulty(userDifficulty);

    // Count questions at user's difficulty level
    int questionCount = quiz.questions.where((q) => q.difficulty == userDifficulty).length;

    // Difficulty colors
    Color difficultyColor;
    switch (userDifficulty) {
      case 1:
        difficultyColor = const Color(0xFF81C784); // Green
        break;
      case 2:
        difficultyColor = const Color(0xFFFFB74D); // Orange
        break;
      case 3:
        difficultyColor = const Color(0xFFE57373); // Red
        break;
      default:
        difficultyColor = const Color(0xFF81C784);
    }

    return GestureDetector(
      onTap: () => _startQuiz(quiz),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF415A77)),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: quiz.color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: quiz.color, width: 2),
              ),
              child: Center(
                child: Text(quiz.icon, style: const TextStyle(fontSize: 28)),
              ),
            ),

            const SizedBox(width: 16),

            // Title, description, and difficulty
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE0E0E0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF778DA9),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Difficulty badge and question count
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: difficultyColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          difficultyName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: difficultyColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$questionCount questions • $pointsPerQuestion pts each',
                        style: TextStyle(
                          fontSize: 10,
                          color: quiz.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.play_circle_fill,
              color: quiz.color,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  void _startQuiz(QuizCategory quiz) async {
    // Get user's current difficulty for this category
    int userDifficulty = await DatabaseHelper.instance.getUserDifficulty(quiz.categoryKey);

    // Filter questions by difficulty
    List<QuizQuestion> filteredQuestions = quiz.questions
        .where((q) => q.difficulty == userDifficulty)
        .toList();

    // If no questions at this difficulty (shouldn't happen), fallback to all
    if (filteredQuestions.isEmpty) {
      filteredQuestions = quiz.questions.where((q) => q.difficulty == 1).toList();
      userDifficulty = 1;
    }

    // Navigate to quiz play page with filtered questions
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPlayPage(
          quiz: quiz,
          questions: filteredQuestions,
          difficultyLevel: userDifficulty,
        ),
      ),
    );

    // Refresh difficulty levels after quiz completion
    if (result == true) {
      _loadUserDifficulties();
    }
  }
}

// QuizPlayPage - Active Quiz Screen
class QuizPlayPage extends StatefulWidget {
  final QuizCategory quiz;
  final List<QuizQuestion> questions;
  final int difficultyLevel;

  const QuizPlayPage({
    Key? key,
    required this.quiz,
    required this.questions,
    required this.difficultyLevel,
  }) : super(key: key);

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _selectedOption = -1;
  bool _hasAnswered = false;

  // Track for difficulty adaptation
  int _consecutiveCorrect = 0;

  QuizQuestion get _currentQuestion => widget.questions[_currentQuestionIndex];
  bool get _isLastQuestion => _currentQuestionIndex == widget.questions.length - 1;
  int get _pointsPerQuestion => DatabaseHelper.instance.getPointsForDifficulty(widget.difficultyLevel);

  // QUIZ LOGIC

  void _selectOption(int index) {
    if (_hasAnswered) return;

    setState(() {
      _selectedOption = index;
      _hasAnswered = true;

      if (index == _currentQuestion.correctIndex) {
        _correctAnswers++;
        _consecutiveCorrect++;
      } else {
        _consecutiveCorrect = 0; // Reset on wrong answer
      }
    });
  }

  void _nextQuestion() {
    if (_isLastQuestion) {
      _showResults();
    } else {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = -1;
        _hasAnswered = false;
      });
    }
  }

  Future<void> _showResults() async {
    // Calculate points earned based on difficulty
    int pointsEarned = _correctAnswers * _pointsPerQuestion;

    // Add points to database
    if (pointsEarned > 0) {
      await DatabaseHelper.instance.addPoints(pointsEarned);
    }

    // Save quiz result to database (for Knowledge Score calculation)
    await DatabaseHelper.instance.saveQuizResult(
      category: widget.quiz.categoryKey,
      score: _correctAnswers,
      totalQuestions: widget.questions.length,
      difficultyLevel: widget.difficultyLevel,
    );

    // Update difficulty based on performance (Adaptive Quiz System)
    await DatabaseHelper.instance.updateDifficultyAfterQuiz(
      category: widget.quiz.categoryKey,
      correctAnswers: _correctAnswers,
      totalQuestions: widget.questions.length,
    );

    // Check if difficulty changed
    int newDifficulty = await DatabaseHelper.instance.getUserDifficulty(widget.quiz.categoryKey);
    bool difficultyChanged = newDifficulty != widget.difficultyLevel;
    bool difficultyIncreased = newDifficulty > widget.difficultyLevel;

    // Show results dialog
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Result emoji
            Text(
              _getResultEmoji(),
              style: const TextStyle(fontSize: 64),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              _getResultTitle(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0E0E0),
              ),
            ),

            const SizedBox(height: 8),

            // Score
            Text(
              '$_correctAnswers out of ${widget.questions.length} correct',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF778DA9),
              ),
            ),

            const SizedBox(height: 16),

            // Points earned
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3F7).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    '+$pointsEarned points',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4FC3F7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Difficulty change notification
            if (difficultyChanged)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: difficultyIncreased
                      ? const Color(0xFF81C784).withOpacity(0.2)
                      : const Color(0xFFFFB74D).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: difficultyIncreased
                        ? const Color(0xFF81C784)
                        : const Color(0xFFFFB74D),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      difficultyIncreased ? '⬆️' : '⬇️',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      difficultyIncreased
                          ? 'Level Up! Now: ${DatabaseHelper.instance.getDifficultyName(newDifficulty)}'
                          : 'Adjusted to: ${DatabaseHelper.instance.getDifficultyName(newDifficulty)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: difficultyIncreased
                            ? const Color(0xFF81C784)
                            : const Color(0xFFFFB74D),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Encouragement
            Text(
              _getResultMessage(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF778DA9),
              ),
            ),
          ],
        ),
        actions: [
          // Retry button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentQuestionIndex = 0;
                _correctAnswers = 0;
                _selectedOption = -1;
                _hasAnswered = false;
                _consecutiveCorrect = 0;
              });
            },
            child: const Text(
              'Try Again',
              style: TextStyle(color: Color(0xFF778DA9)),
            ),
          ),
          // Done button
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Go back to quiz list, signal refresh
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3F7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  String _getResultEmoji() {
    double percentage = _correctAnswers / widget.questions.length;
    if (percentage == 1.0) return '🏆';
    if (percentage >= 0.8) return '🌟';
    if (percentage >= 0.6) return '👍';
    if (percentage >= 0.4) return '📚';
    return '💪';
  }

  String _getResultTitle() {
    double percentage = _correctAnswers / widget.questions.length;
    if (percentage == 1.0) return 'Perfect Score!';
    if (percentage >= 0.8) return 'Excellent!';
    if (percentage >= 0.6) return 'Good Job!';
    if (percentage >= 0.4) return 'Keep Learning!';
    return 'Nice Try!';
  }

  String _getResultMessage() {
    double percentage = _correctAnswers / widget.questions.length;
    if (percentage == 1.0) return 'You\'re a disaster preparedness expert!';
    if (percentage >= 0.8) return 'You\'re well prepared for emergencies!';
    if (percentage >= 0.6) return 'Good knowledge, keep practising!';
    if (percentage >= 0.4) return 'Review the guides to improve your score!';
    return 'Check out our guides to learn more!';
  }

  @override
  Widget build(BuildContext context) {
    String difficultyName = DatabaseHelper.instance.getDifficultyName(widget.difficultyLevel);

    return Scaffold(
      backgroundColor: const Color(0xFF1B263B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        title: Column(
          children: [
            Text(
              widget.quiz.title,
              style: const TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$difficultyName • $_pointsPerQuestion pts each',
              style: const TextStyle(
                color: Color(0xFF778DA9),
                fontSize: 11,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF778DA9)),
          onPressed: () => _showExitConfirmation(),
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          _buildProgressBar(),

          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question number
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${widget.questions.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF778DA9),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Question text
                  Text(
                    _currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE0E0E0),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Options
                  ...List.generate(
                    _currentQuestion.options.length,
                        (index) => _buildOptionButton(index),
                  ),

                  // Explanation (shown after answering)
                  if (_hasAnswered) ...[
                    const SizedBox(height: 20),
                    _buildExplanation(),
                  ],
                ],
              ),
            ),
          ),

          // Next button (shown after answering)
          if (_hasAnswered) _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    double progress = (_currentQuestionIndex + 1) / widget.questions.length;

    return Container(
      height: 4,
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: const Color(0xFF415A77),
        valueColor: AlwaysStoppedAnimation<Color>(widget.quiz.color),
      ),
    );
  }

  Widget _buildOptionButton(int index) {
    bool isSelected = _selectedOption == index;
    bool isCorrect = index == _currentQuestion.correctIndex;

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (!_hasAnswered) {
      // Before answering
      backgroundColor = const Color(0xFF0D1B2A);
      borderColor = isSelected ? widget.quiz.color : const Color(0xFF415A77);
      textColor = const Color(0xFFE0E0E0);
    } else {
      // After answering
      if (isCorrect) {
        backgroundColor = const Color(0xFF388E3C).withOpacity(0.2);
        borderColor = const Color(0xFF388E3C);
        textColor = const Color(0xFF81C784);
      } else if (isSelected && !isCorrect) {
        backgroundColor = const Color(0xFFD32F2F).withOpacity(0.2);
        borderColor = const Color(0xFFD32F2F);
        textColor = const Color(0xFFEF5350);
      } else {
        backgroundColor = const Color(0xFF0D1B2A);
        borderColor = const Color(0xFF415A77);
        textColor = const Color(0xFF778DA9);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _selectOption(index),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              // Option letter
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Option text
              Expanded(
                child: Text(
                  _currentQuestion.options[index],
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
              ),

              // Result icon
              if (_hasAnswered && (isCorrect || isSelected))
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect
                      ? const Color(0xFF81C784)
                      : const Color(0xFFEF5350),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanation() {
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
              Text('💡', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                'Explanation',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE0E0E0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentQuestion.explanation,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF778DA9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1B2A),
        border: Border(
          top: BorderSide(color: Color(0xFF415A77)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _nextQuestion,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.quiz.color,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _isLastQuestion ? 'See Results' : 'Next Question',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Exit Quiz?',
          style: TextStyle(
            color: Color(0xFFE0E0E0),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Your progress will be lost if you exit now.',
          style: TextStyle(
            color: Color(0xFF778DA9),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Continue Quiz',
              style: TextStyle(color: Color(0xFF4FC3F7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit quiz
            },
            child: const Text(
              'Exit',
              style: TextStyle(color: Color(0xFF778DA9)),
            ),
          ),
        ],
      ),
    );
  }
}

// DATA MODELS

class QuizCategory {
  final String title;
  final String categoryKey;
  final String icon;
  final Color color;
  final String description;
  final List<QuizQuestion> questions;

  QuizCategory({
    required this.title,
    required this.categoryKey,
    required this.icon,
    required this.color,
    required this.description,
    required this.questions,
  });
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int difficulty;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.difficulty = 1, // Default to Beginner
  });
}
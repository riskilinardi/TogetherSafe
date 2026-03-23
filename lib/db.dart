// =============================================================================
// db.dart - Database Helper
// =============================================================================
// This file handles all local database operations using SQLite. It stores
// user data locally on the device so the app works offline.
//
// The database stores:
// - User profile (name, household info, onboarding status)
// - Emergency contacts (family members to notify during emergencies)
// - Gamification data (points, streaks, badges, completed tasks)
// - Flood reports (community-submitted sightings)
// - Quiz results (for Preparedness Score Algorithm)
// - Quiz difficulty settings (for Adaptive Quiz System)
// - Preparedness Score Algorithm: Weighted calculation considering task
//   completion, quiz scores, recency, and household coverage
// - Adaptive Quiz System: Difficulty adjustment based on user performance
// =============================================================================

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// =============================================================================
// DATA MODELS
// =============================================================================
// These classes represent the structure of data stored in the database.
// Each class has:
// - Properties matching database columns
// - toMap() method to convert object to database format
// - fromMap() factory to create object from database query result

// UserProfile - Stores user's personal information
// This is collected during onboarding and used throughout the app.
class UserProfile {
  final int? id;
  final String name;
  final String? location; // Optional - for location-based alerts
  final String? postalCode; // For risk modifier calculation
  final int adultsCount; // Number of adults in household
  final int childrenCount; // Number of children
  final int elderlyCount; // Number of elderly (65+)
  final int petsCount; // Number of pets
  final bool hasSpecialNeeds; // Anyone with mobility/medical needs
  final String? specialNeedsNotes; // Details about special needs
  final bool onboardingCompleted; // Flag to skip onboarding next time
  final DateTime createdAt;

  UserProfile({
    this.id,
    required this.name,
    this.location,
    this.postalCode,
    this.adultsCount = 1,
    this.childrenCount = 0,
    this.elderlyCount = 0,
    this.petsCount = 0,
    this.hasSpecialNeeds = false,
    this.specialNeedsNotes,
    this.onboardingCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert UserProfile object to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'postal_code': postalCode,
      'adults_count': adultsCount,
      'children_count': childrenCount,
      'elderly_count': elderlyCount,
      'pets_count': petsCount,
      'has_special_needs': hasSpecialNeeds ? 1 : 0, // SQLite doesn't have boolean
      'special_needs_notes': specialNeedsNotes,
      'onboarding_completed': onboardingCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create UserProfile object from database query result
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      postalCode: map['postal_code'],
      adultsCount: map['adults_count'] ?? 1,
      childrenCount: map['children_count'] ?? 0,
      elderlyCount: map['elderly_count'] ?? 0,
      petsCount: map['pets_count'] ?? 0,
      hasSpecialNeeds: map['has_special_needs'] == 1,
      specialNeedsNotes: map['special_needs_notes'],
      onboardingCompleted: map['onboarding_completed'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // Create a copy of UserProfile with some fields updated
  // This is useful when updating user data
  UserProfile copyWith({
    int? id,
    String? name,
    String? location,
    String? postalCode,
    int? adultsCount,
    int? childrenCount,
    int? elderlyCount,
    int? petsCount,
    bool? hasSpecialNeeds,
    String? specialNeedsNotes,
    bool? onboardingCompleted,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      postalCode: postalCode ?? this.postalCode,
      adultsCount: adultsCount ?? this.adultsCount,
      childrenCount: childrenCount ?? this.childrenCount,
      elderlyCount: elderlyCount ?? this.elderlyCount,
      petsCount: petsCount ?? this.petsCount,
      hasSpecialNeeds: hasSpecialNeeds ?? this.hasSpecialNeeds,
      specialNeedsNotes: specialNeedsNotes ?? this.specialNeedsNotes,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt,
    );
  }
}

// EmergencyContact - Stores emergency contact information
// Users can add up to 3 emergency contacts who will be notified when they
// press the "I'm Safe" button during emergencies.
class EmergencyContact {
  final int? id;
  final String name;
  final String phoneNumber;
  final String relationship; // e.g., "Spouse", "Parent", "Friend"
  final bool isPrimary; // Primary contact is notified first

  EmergencyContact({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    this.isPrimary = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'relationship': relationship,
      'is_primary': isPrimary ? 1 : 0,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phone_number'],
      relationship: map['relationship'],
      isPrimary: map['is_primary'] == 1,
    );
  }
}

// GamificationData - Stores user's progress and achievements
// This tracks all the gamification elements: points, streaks, badges, etc.
class GamificationData {
  final int? id;
  final int totalPoints;
  final int currentStreak; // Consecutive days of app usage
  final int longestStreak; // Best streak ever achieved
  final DateTime? lastActiveDate; // To calculate streak
  final int tasksCompleted;
  final int challengesCompleted;
  final double preparednessLevel; // 0.0 to 1.0

  GamificationData({
    this.id,
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.tasksCompleted = 0,
    this.challengesCompleted = 0,
    this.preparednessLevel = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_points': totalPoints,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_active_date': lastActiveDate?.toIso8601String(),
      'tasks_completed': tasksCompleted,
      'challenges_completed': challengesCompleted,
      'preparedness_level': preparednessLevel,
    };
  }

  factory GamificationData.fromMap(Map<String, dynamic> map) {
    return GamificationData(
      id: map['id'],
      totalPoints: map['total_points'] ?? 0,
      currentStreak: map['current_streak'] ?? 0,
      longestStreak: map['longest_streak'] ?? 0,
      lastActiveDate: map['last_active_date'] != null
          ? DateTime.parse(map['last_active_date'])
          : null,
      tasksCompleted: map['tasks_completed'] ?? 0,
      challengesCompleted: map['challenges_completed'] ?? 0,
      preparednessLevel: map['preparedness_level'] ?? 0.0,
    );
  }
}

// AchievementBadge - Represents an achievement badge
// Badges are earned by completing specific actions or milestones.
class AchievementBadge {
  final int? id;
  final String name;
  final String description;
  final String iconName; // Name of the icon/emoji to display
  final bool isUnlocked;
  final DateTime? unlockedAt;

  AchievementBadge({
    this.id,
    required this.name,
    required this.description,
    required this.iconName,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_name': iconName,
      'is_unlocked': isUnlocked ? 1 : 0,
      'unlocked_at': unlockedAt?.toIso8601String(),
    };
  }

  factory AchievementBadge.fromMap(Map<String, dynamic> map) {
    return AchievementBadge(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      iconName: map['icon_name'],
      isUnlocked: map['is_unlocked'] == 1,
      unlockedAt: map['unlocked_at'] != null
          ? DateTime.parse(map['unlocked_at'])
          : null,
    );
  }
}

// FloodReport - Community-submitted flood sightings
// Users can report floods they see in their area to help others.
class FloodReport {
  final int? id;
  final String? photo; // Base64 encoded image
  final String description;
  final String location;
  final DateTime reportedAt;
  final double? latitude;
  final double? longitude;

  FloodReport({
    this.id,
    this.photo,
    required this.description,
    required this.location,
    DateTime? reportedAt,
    this.latitude,
    this.longitude,
  }) : reportedAt = reportedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photo': photo,
      'description': description,
      'location': location,
      'reported_at': reportedAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory FloodReport.fromMap(Map<String, dynamic> map) {
    return FloodReport(
      id: map['id'],
      photo: map['photo'],
      description: map['description'],
      location: map['location'],
      reportedAt: DateTime.parse(map['reported_at']),
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}

// PreparednessTasks - Checklist items for emergency preparedness
// These are the tasks users complete to improve their preparedness level.
class PreparednessTask {
  final int? id;
  final String title;
  final String description;
  final String category; // e.g., "Emergency Kit", "Home Safety", "Documents"
  final int points; // Points awarded when completed
  final bool isCompleted;
  final DateTime? completedAt;

  PreparednessTask({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    this.points = 10,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'points': points,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory PreparednessTask.fromMap(Map<String, dynamic> map) {
    return PreparednessTask(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      points: map['points'] ?? 10,
      isCompleted: map['is_completed'] == 1,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
    );
  }
}

// QuizResult - Stores quiz completion history (NEW)
// This model stores the results of each quiz attempt. Used by the Preparedness
// Score Algorithm to calculate the Knowledge Score component (25% weight).
class QuizResult {
  final int? id;
  final String category; // 'Flood', 'Fire', 'Haze', 'Earthquake', 'General'
  final int score; // Number of correct answers
  final int totalQuestions; // Total questions in quiz
  final int difficultyLevel; // 1=Beginner, 2=Intermediate, 3=Advanced
  final DateTime completedAt;

  QuizResult({
    this.id,
    required this.category,
    required this.score,
    required this.totalQuestions,
    this.difficultyLevel = 1,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();

  // Calculate percentage score for this quiz
  double get percentage => totalQuestions > 0 ? score / totalQuestions : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'score': score,
      'total_questions': totalQuestions,
      'difficulty_level': difficultyLevel,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'],
      category: map['category'],
      score: map['score'],
      totalQuestions: map['total_questions'],
      difficultyLevel: map['difficulty_level'] ?? 1,
      completedAt: DateTime.parse(map['completed_at']),
    );
  }
}

// UserQuizDifficulty
// This model implements the Adaptive Quiz System. It stores the current
// difficulty level for each quiz category and tracks recent performance
// to determine when to adjust difficulty.
//
// Adaptation rules (based on educational technology research):
// - After 3 consecutive correct answers: increase difficulty
// - After 2 wrong answers in last 5 questions: decrease difficulty
// - Difficulty ranges from 1 (Beginner) to 3 (Advanced)
class UserQuizDifficulty {
  final int? id;
  final String category; // 'Flood', 'Fire', 'Haze', 'Earthquake', 'General'
  final int difficultyLevel; // 1=Beginner, 2=Intermediate, 3=Advanced
  final int consecutiveCorrect; // Track consecutive correct answers
  final int recentWrongCount; // Wrong answers in last 5 questions
  final DateTime? lastUpdated;

  UserQuizDifficulty({
    this.id,
    required this.category,
    this.difficultyLevel = 1,
    this.consecutiveCorrect = 0,
    this.recentWrongCount = 0,
    this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'difficulty_level': difficultyLevel,
      'consecutive_correct': consecutiveCorrect,
      'recent_wrong_count': recentWrongCount,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  factory UserQuizDifficulty.fromMap(Map<String, dynamic> map) {
    return UserQuizDifficulty(
      id: map['id'],
      category: map['category'],
      difficultyLevel: map['difficulty_level'] ?? 1,
      consecutiveCorrect: map['consecutive_correct'] ?? 0,
      recentWrongCount: map['recent_wrong_count'] ?? 0,
      lastUpdated: map['last_updated'] != null
          ? DateTime.parse(map['last_updated'])
          : null,
    );
  }
}


// =============================================================================
// DATABASE HELPER CLASS
// =============================================================================
// This class manages all database operations. It uses the singleton pattern
// to ensure only one database connection exists throughout the app.
class DatabaseHelper {
  // Singleton instance - only one DatabaseHelper exists in the app
  static final DatabaseHelper instance = DatabaseHelper._instance();

  // Private database reference
  static Database? _database;

  // Private constructor - prevents creating new instances with DatabaseHelper()
  DatabaseHelper._instance();

  // Flood-prone postal codes in Singapore
  // These postal codes are known flood-prone areas based on PUB data.
  // Used by the risk modifier in the Preparedness Score Algorithm.
  static const List<String> floodPronePostalPrefixes = [
    '58', '59', // Bukit Timah area
    '46', '47', // Bedok area
    '52', '53', // Tampines low-lying areas
    '72', '73', // Jurong low-lying areas
  ];

  // Database Getter
  // Returns the database instance, creating it if it doesn't exist.
  // Using async/await because database operations are asynchronous.
  Future<Database> get db async {
    // If database already exists, return it
    // The ??= operator assigns only if _database is null
    _database ??= await initDb();
    return _database!;
  }

  // Initialize Database
  // Creates the database file and tables if they don't exist.
  // Called automatically the first time the database is accessed.
  Future<Database> initDb() async {
    // Get the default database location for the platform
    String databasesPath = await getDatabasesPath();

    // Create the full path for our database file
    String path = join(databasesPath, 'togethersafe.db');

    // Open the database (creates it if it doesn't exist)
    // Version 2 adds quiz_results and user_quiz_difficulty tables
    return await openDatabase(
      path,
      version: 2, // Incremented for new tables
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create Tables (Version 2)
  // This method is called when the database is first created.
  // It sets up all the tables
  Future _onCreate(Database db, int version) async {
    // User profile table - stores onboarding data
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        location TEXT,
        postal_code TEXT,
        adults_count INTEGER DEFAULT 1,
        children_count INTEGER DEFAULT 0,
        elderly_count INTEGER DEFAULT 0,
        pets_count INTEGER DEFAULT 0,
        has_special_needs INTEGER DEFAULT 0,
        special_needs_notes TEXT,
        onboarding_completed INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Emergency contacts table
    await db.execute('''
      CREATE TABLE emergency_contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        relationship TEXT NOT NULL,
        is_primary INTEGER DEFAULT 0
      )
    ''');

    // Gamification data table
    await db.execute('''
      CREATE TABLE gamification_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_points INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        last_active_date TEXT,
        tasks_completed INTEGER DEFAULT 0,
        challenges_completed INTEGER DEFAULT 0,
        preparedness_level REAL DEFAULT 0.0
      )
    ''');

    // Badges table
    await db.execute('''
      CREATE TABLE badges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        is_unlocked INTEGER DEFAULT 0,
        unlocked_at TEXT
      )
    ''');

    // Flood reports table
    await db.execute('''
      CREATE TABLE flood_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        photo TEXT,
        description TEXT NOT NULL,
        location TEXT NOT NULL,
        reported_at TEXT NOT NULL,
        latitude REAL,
        longitude REAL
      )
    ''');

    // Preparedness tasks table
    await db.execute('''
      CREATE TABLE preparedness_tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        points INTEGER DEFAULT 10,
        is_completed INTEGER DEFAULT 0,
        completed_at TEXT
      )
    ''');

    // Users table - for optional account features
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        displayname TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Quiz Results
    // Stores quiz completion history for Knowledge Score calculation.
    await db.execute('''
      CREATE TABLE quiz_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        score INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        difficulty_level INTEGER DEFAULT 1,
        completed_at TEXT NOT NULL
      )
    ''');

    // User Quiz Difficulty (v2)
    // Tracks difficulty level per category for Adaptive Quiz System.
    // Each category (Flood, Fire, Haze, Earthquake, General) has its own difficulty.
    await db.execute('''
      CREATE TABLE user_quiz_difficulty (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL UNIQUE,
        difficulty_level INTEGER DEFAULT 1,
        consecutive_correct INTEGER DEFAULT 0,
        recent_wrong_count INTEGER DEFAULT 0,
        last_updated TEXT
      )
    ''');

    // Initialize default data after creating tables
    await _initializeDefaultData(db);
  }

  // Database Upgrade Handler
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new tables for v2 features
      await db.execute('''
        CREATE TABLE IF NOT EXISTS quiz_results (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          score INTEGER NOT NULL,
          total_questions INTEGER NOT NULL,
          difficulty_level INTEGER DEFAULT 1,
          completed_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_quiz_difficulty (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL UNIQUE,
          difficulty_level INTEGER DEFAULT 1,
          consecutive_correct INTEGER DEFAULT 0,
          recent_wrong_count INTEGER DEFAULT 0,
          last_updated TEXT
        )
      ''');

      // Add postal_code column to user_profile if it doesn't exist
      await db.execute('''
        ALTER TABLE user_profile ADD COLUMN postal_code TEXT
      ''');

      // Initialize quiz difficulty for existing users
      await _initializeQuizDifficulty(db);
    }
  }

  // Initialize Default Data
  // Populates the database with initial data like badges and tasks.
  // This runs once when the database is first created.
  Future<void> _initializeDefaultData(Database db) async {
    // Create initial gamification record
    await db.insert('gamification_data', {
      'total_points': 0,
      'current_streak': 0,
      'longest_streak': 0,
      'tasks_completed': 0,
      'challenges_completed': 0,
      'preparedness_level': 0.0,
    });

    // Insert default badges
    List<Map<String, dynamic>> defaultBadges = [
      {
        'name': 'First Steps',
        'description': 'Complete the onboarding process',
        'icon_name': '🎯',
        'is_unlocked': 0,
      },
      {
        'name': 'Kit Builder',
        'description': 'Complete your emergency kit checklist',
        'icon_name': '🎒',
        'is_unlocked': 0,
      },
      {
        'name': 'Week Warrior',
        'description': 'Maintain a 7-day streak',
        'icon_name': '🔥',
        'is_unlocked': 0,
      },
      {
        'name': 'Safety Pro',
        'description': 'Complete all safety quizzes',
        'icon_name': '🛡️',
        'is_unlocked': 0,
      },
      {
        'name': 'Community Hero',
        'description': 'Submit your first flood report',
        'icon_name': '🦸',
        'is_unlocked': 0,
      },
      {
        'name': 'Family First',
        'description': 'Add all emergency contacts',
        'icon_name': '👨‍👩‍👧',
        'is_unlocked': 0,
      },
      {
        'name': 'Point Master',
        'description': 'Earn 1000 points',
        'icon_name': '⭐',
        'is_unlocked': 0,
      },
      {
        'name': 'Fully Prepared',
        'description': 'Reach 100% preparedness level',
        'icon_name': '🏆',
        'is_unlocked': 0,
      },
      // Quiz mastery badge
      {
        'name': 'Quiz Master',
        'description': 'Reach Advanced level in any quiz category',
        'icon_name': '🧠',
        'is_unlocked': 0,
      },
    ];

    for (var badge in defaultBadges) {
      await db.insert('badges', badge);
    }

    // Insert default preparedness tasks
    List<Map<String, dynamic>> defaultTasks = [
      // Emergency Kit category
      {
        'title': 'Get a flashlight',
        'description': 'Keep a working flashlight with extra batteries',
        'category': 'Emergency Kit',
        'points': 10,
        'is_completed': 0,
      },
      {
        'title': 'Store bottled water',
        'description': 'Keep at least 3 days supply (4L per person per day)',
        'category': 'Emergency Kit',
        'points': 15,
        'is_completed': 0,
      },
      {
        'title': 'Prepare first aid kit',
        'description': 'Include bandages, antiseptic, medications, etc.',
        'category': 'Emergency Kit',
        'points': 20,
        'is_completed': 0,
      },
      {
        'title': 'Get a portable radio',
        'description': 'Battery or hand-crank radio for emergency broadcasts',
        'category': 'Emergency Kit',
        'points': 15,
        'is_completed': 0,
      },
      {
        'title': 'Store non-perishable food',
        'description': 'Keep at least 3 days supply of canned/dry food',
        'category': 'Emergency Kit',
        'points': 15,
        'is_completed': 0,
      },
      // Home Safety category
      {
        'title': 'Check smoke detectors',
        'description': 'Test smoke detectors and replace batteries if needed',
        'category': 'Home Safety',
        'points': 10,
        'is_completed': 0,
      },
      {
        'title': 'Know your circuit breaker',
        'description': 'Locate and label your electrical panel',
        'category': 'Home Safety',
        'points': 10,
        'is_completed': 0,
      },
      {
        'title': 'Create evacuation plan',
        'description': 'Plan two exit routes from every room',
        'category': 'Home Safety',
        'points': 25,
        'is_completed': 0,
      },
      {
        'title': 'Set meeting point',
        'description': 'Agree on a meeting point outside your home',
        'category': 'Home Safety',
        'points': 15,
        'is_completed': 0,
      },
      // Documents category
      {
        'title': 'Copy important documents',
        'description': 'Make copies of IC, passport, insurance papers',
        'category': 'Documents',
        'points': 20,
        'is_completed': 0,
      },
      {
        'title': 'Store documents safely',
        'description': 'Keep copies in waterproof container or cloud storage',
        'category': 'Documents',
        'points': 15,
        'is_completed': 0,
      },
      {
        'title': 'List emergency contacts',
        'description': 'Write down important phone numbers',
        'category': 'Documents',
        'points': 10,
        'is_completed': 0,
      },
    ];

    for (var task in defaultTasks) {
      await db.insert('preparedness_tasks', task);
    }

    // Initialize quiz difficulty settings for all categories
    await _initializeQuizDifficulty(db);
  }

  // Initialize Quiz Difficulty Settings (NEW)
  // Sets up default difficulty level (Beginner) for each quiz category.
  // Part of the Adaptive Quiz System.
  Future<void> _initializeQuizDifficulty(Database db) async {
    List<String> categories = ['Flood', 'Fire', 'Haze', 'Earthquake', 'General'];

    for (String category in categories) {
      // Check if already exists (for upgrade scenario)
      List<Map<String, dynamic>> existing = await db.query(
        'user_quiz_difficulty',
        where: 'category = ?',
        whereArgs: [category],
      );

      if (existing.isEmpty) {
        await db.insert('user_quiz_difficulty', {
          'category': category,
          'difficulty_level': 1, // Start at Beginner
          'consecutive_correct': 0,
          'recent_wrong_count': 0,
          'last_updated': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  // Initialize Users
  Future<void> initializeUsers() async {
    // Currently empty - users are created through signup
  }

  // ===========================================================================
  // USER PROFILE OPERATIONS
  // ===========================================================================

  // Get user profile
  Future<UserProfile?> getUserProfile() async {
    Database db = await instance.db;
    List<Map<String, dynamic>> result = await db.query('user_profile', limit: 1);

    if (result.isEmpty) {
      return null;
    }
    return UserProfile.fromMap(result.first);
  }

  // Insert or update user profile (unified method)
  Future<int> saveUserProfile(UserProfile profile) async {
    Database db = await instance.db;

    // Check if profile exists
    List<Map<String, dynamic>> existing = await db.query('user_profile', limit: 1);

    if (existing.isEmpty) {
      // Insert new profile
      return await db.insert('user_profile', profile.toMap());
    } else {
      // Update existing profile
      return await db.update(
        'user_profile',
        profile.toMap(),
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
  }

  // Insert user profile (for onboarding)
  Future<int> insertUserProfile(UserProfile profile) async {
    return await saveUserProfile(profile);
  }

  // Update user profile (for profile page)
  Future<int> updateUserProfile(UserProfile profile) async {
    return await saveUserProfile(profile);
  }

  // Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    UserProfile? profile = await getUserProfile();
    return profile?.onboardingCompleted ?? false;
  }

  // Mark onboarding as completed
  Future<void> completeOnboarding() async {
    Database db = await instance.db;
    UserProfile? profile = await getUserProfile();

    if (profile != null) {
      await db.update(
        'user_profile',
        {'onboarding_completed': 1},
        where: 'id = ?',
        whereArgs: [profile.id],
      );

      // Unlock First Steps badge
      await unlockBadge('First Steps');
    }
  }


  // ===========================================================================
  // EMERGENCY CONTACTS OPERATIONS
  // ===========================================================================

  // Get all emergency contacts
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    Database db = await instance.db;
    List<Map<String, dynamic>> result = await db.query(
      'emergency_contacts',
      orderBy: 'is_primary DESC, id ASC', // Primary contact first
    );
    return result.map((map) => EmergencyContact.fromMap(map)).toList();
  }

  // Add emergency contact
  Future<int> addEmergencyContact(EmergencyContact contact) async {
    Database db = await instance.db;
    int result = await db.insert('emergency_contacts', contact.toMap());

    // Check if user has 3 contacts for Family First badge
    List<EmergencyContact> allContacts = await getEmergencyContacts();
    if (allContacts.length >= 3) {
      await unlockBadge('Family First');
    }

    return result;
  }

  // Insert emergency contact (alias for addEmergencyContact)
  Future<int> insertEmergencyContact(EmergencyContact contact) async {
    return await addEmergencyContact(contact);
  }

  // Update emergency contact
  Future<int> updateEmergencyContact(EmergencyContact contact) async {
    Database db = await instance.db;
    return await db.update(
      'emergency_contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  // Delete emergency contact
  Future<int> deleteEmergencyContact(int id) async {
    Database db = await instance.db;
    return await db.delete(
      'emergency_contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Check if user has any emergency contacts
  Future<bool> hasEmergencyContacts() async {
    List<EmergencyContact> contacts = await getEmergencyContacts();
    return contacts.isNotEmpty;
  }


  // ===========================================================================
  // GAMIFICATION OPERATIONS
  // ===========================================================================

  // Get gamification data
  Future<GamificationData?> getGamificationData() async {
    Database db = await instance.db;
    List<Map<String, dynamic>> result = await db.query('gamification_data', limit: 1);

    if (result.isEmpty) {
      return null;
    }
    return GamificationData.fromMap(result.first);
  }

  // Add points to user's total
  Future<void> addPoints(int points) async {
    Database db = await instance.db;
    GamificationData? data = await getGamificationData();

    if (data != null) {
      int newTotal = data.totalPoints + points;
      await db.update(
        'gamification_data',
        {'total_points': newTotal},
        where: 'id = ?',
        whereArgs: [data.id],
      );

      // Check if user earned Point Master badge (1000 points)
      if (newTotal >= 1000) {
        await unlockBadge('Point Master');
      }
    }
  }

  // Update streak
  Future<void> updateStreak() async {
    Database db = await instance.db;
    GamificationData? data = await getGamificationData();

    if (data == null) return;

    DateTime today = DateTime.now();
    DateTime? lastActive = data.lastActiveDate;

    int newStreak = data.currentStreak;

    if (lastActive == null) {
      // First time using app
      newStreak = 1;
    } else {
      // Check if last active was yesterday
      DateTime yesterday = today.subtract(const Duration(days: 1));

      if (_isSameDay(lastActive, yesterday)) {
        // Consecutive day - increase streak
        newStreak = data.currentStreak + 1;
      } else if (!_isSameDay(lastActive, today)) {
        // Missed a day - reset streak
        newStreak = 1;
      }
      // If same day, don't change streak
    }

    // Update longest streak if current is higher
    int longestStreak = newStreak > data.longestStreak
        ? newStreak
        : data.longestStreak;

    await db.update(
      'gamification_data',
      {
        'current_streak': newStreak,
        'longest_streak': longestStreak,
        'last_active_date': today.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [data.id],
    );

    // Check if user earned Week Warrior badge (7-day streak)
    if (newStreak >= 7) {
      await unlockBadge('Week Warrior');
    }
  }

  // Helper to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Update Preparedness Level
  // This method implements the custom Preparedness Score Algorithm that
  // calculates a personalized readiness percentage based on multiple factors.
  //
  // The algorithm considers four weighted components:
  // - Task Completion (40%): Completion across Emergency Kit, Home Safety, Documents
  // - Knowledge Score (25%): Average quiz performance across all categories
  // - Recency Factor (20%): Decay if inactive for over 14 days
  // - Household Coverage (15%): Emergency contacts and evacuation planning
  //
  // Risk modifiers are applied based on:
  // - Postal code in flood-prone area: +10% weight on flood-related tasks
  // - Elderly in household: +10% weight on medical preparedness
  Future<void> updatePreparednessLevel() async {
    Database db = await instance.db;

    // Component 1: Task Completion Score (40% weight)
    // Calculate completion rate for each category separately
    double taskScore = await _calculateTaskCompletionScore(db);

    // Component 2: Knowledge Score (25% weight)
    // Average quiz performance across all completed quizzes
    double knowledgeScore = await _calculateKnowledgeScore(db);

    // Component 3: Recency Factor (20% weight)
    // Apply decay if user hasn't been active recently
    double recencyFactor = await _calculateRecencyFactor(db);

    // Component 4: Household Coverage (15% weight)
    // Check emergency contacts and evacuation planning
    double householdCoverage = await _calculateHouseholdCoverage(db);

    // Calculate weighted total
    double level = (taskScore * 0.40) +
        (knowledgeScore * 0.25) +
        (recencyFactor * 0.20) +
        (householdCoverage * 0.15);

    // Ensure level is between 0.0 and 1.0
    level = level.clamp(0.0, 1.0);

    await db.update(
      'gamification_data',
      {'preparedness_level': level},
      where: 'id = ?',
      whereArgs: [1], // There's only one record
    );

    // Check if user earned Fully Prepared badge
    if (level >= 1.0) {
      await unlockBadge('Fully Prepared');
    }
  }

  // Calculate Task Completion Score (Internal helper)
  // Calculates weighted task completion across categories.
  // Emergency Kit: 15%, Home Safety: 15%, Documents: 10%
  Future<double> _calculateTaskCompletionScore(Database db) async {
    // Get task completion by category
    Map<String, double> categoryScores = {};

    List<String> categories = ['Emergency Kit', 'Home Safety', 'Documents'];
    Map<String, double> categoryWeights = {
      'Emergency Kit': 0.375,  // 15% of 40% = 0.15/0.40 = 0.375
      'Home Safety': 0.375,    // 15% of 40% = 0.15/0.40 = 0.375
      'Documents': 0.25,       // 10% of 40% = 0.10/0.40 = 0.25
    };

    for (String category in categories) {
      List<Map<String, dynamic>> allTasks = await db.query(
        'preparedness_tasks',
        where: 'category = ?',
        whereArgs: [category],
      );

      List<Map<String, dynamic>> completedTasks = await db.query(
        'preparedness_tasks',
        where: 'category = ? AND is_completed = 1',
        whereArgs: [category],
      );

      double categoryScore = allTasks.isEmpty
          ? 0.0
          : completedTasks.length / allTasks.length;

      categoryScores[category] = categoryScore;
    }

    // Apply risk modifiers based on user profile
    await _applyRiskModifiers(db, categoryScores);

    // Calculate weighted total
    double totalScore = 0.0;
    for (String category in categories) {
      totalScore += (categoryScores[category] ?? 0.0) * (categoryWeights[category] ?? 0.0);
    }

    return totalScore;
  }

  // Apply Risk Modifiers (Internal helper)
  // Adjusts category weights based on user's risk profile.
  Future<void> _applyRiskModifiers(Database db, Map<String, double> categoryScores) async {
    UserProfile? profile = await getUserProfile();
    if (profile == null) return;

    // Check if user is in flood-prone area
    if (profile.postalCode != null) {
      String postalPrefix = profile.postalCode!.substring(0, 2);
      if (floodPronePostalPrefixes.contains(postalPrefix)) {
        // Boost Emergency Kit importance for flood-prone areas
      }
    }

    // Check for elderly in household (affects medical preparedness)
    if (profile.elderlyCount > 0) {
      // For households with elderly, first aid kit completion is more critical
    }
  }

  // Calculate Knowledge Score (Internal helper)
  // Calculates average quiz performance across all completed quizzes.
  // Returns 0.0 if no quizzes completed, otherwise average percentage.
  Future<double> _calculateKnowledgeScore(Database db) async {
    List<Map<String, dynamic>> results = await db.query('quiz_results');

    if (results.isEmpty) {
      return 0.0; // No quizzes completed yet
    }

    double totalPercentage = 0.0;
    for (var result in results) {
      int score = result['score'] ?? 0;
      int total = result['total_questions'] ?? 1;
      totalPercentage += (score / total);
    }

    return totalPercentage / results.length;
  }

  // Calculate Recency Factor (Internal helper)
  // Returns a multiplier based on how recently the user was active.
  // - Active within 14 days: 1.0 (full credit)
  // - Inactive for longer: decay by 0.05 per day (minimum 0.5)
  Future<double> _calculateRecencyFactor(Database db) async {
    GamificationData? data = await getGamificationData();

    if (data == null || data.lastActiveDate == null) {
      return 0.5; // Default to half credit if no activity data
    }

    DateTime now = DateTime.now();
    int daysSinceActive = now.difference(data.lastActiveDate!).inDays;

    if (daysSinceActive <= 14) {
      return 1.0; // Full credit for recent activity
    }

    // Decay after 14 days: lose 0.05 per day, minimum 0.5
    int daysOverThreshold = daysSinceActive - 14;
    double decayedValue = 1.0 - (daysOverThreshold * 0.05);
    return decayedValue.clamp(0.5, 1.0);
  }

  // Calculate Household Coverage
  // Checks completion of family-oriented preparedness tasks:
  // - Has emergency contacts: 33%
  // - Evacuation plan complete: 33%
  // - Meeting point set: 33%
  Future<double> _calculateHouseholdCoverage(Database db) async {
    double score = 0.0;

    // Check for emergency contacts (33%)
    List<Map<String, dynamic>> contacts = await db.query('emergency_contacts');
    if (contacts.isNotEmpty) {
      score += 0.33;
    }

    // Check for evacuation plan task (33%)
    List<Map<String, dynamic>> evacPlan = await db.query(
      'preparedness_tasks',
      where: 'title = ? AND is_completed = 1',
      whereArgs: ['Create evacuation plan'],
    );
    if (evacPlan.isNotEmpty) {
      score += 0.33;
    }

    // Check for meeting point task (33%)
    List<Map<String, dynamic>> meetingPoint = await db.query(
      'preparedness_tasks',
      where: 'title = ? AND is_completed = 1',
      whereArgs: ['Set meeting point'],
    );
    if (meetingPoint.isNotEmpty) {
      score += 0.34; // 0.34 to make total exactly 1.0
    }

    return score;
  }


  // ===========================================================================
  // BADGE OPERATIONS
  // ===========================================================================

  // Get all badges
  Future<List<AchievementBadge>> getAllBadges() async {
    Database db = await instance.db;
    List<Map<String, dynamic>> result = await db.query('badges');
    return result.map((map) => AchievementBadge.fromMap(map)).toList();
  }

  // Get unlocked badges only
  Future<List<AchievementBadge>> getUnlockedBadges() async {
    Database db = await instance.db;
    List<Map<String, dynamic>> result = await db.query(
      'badges',
      where: 'is_unlocked = 1',
    );
    return result.map((map) => AchievementBadge.fromMap(map)).toList();
  }

  // Unlock a badge by name
  Future<void> unlockBadge(String badgeName) async {
    Database db = await instance.db;

    // Check if badge exists and is not already unlocked
    List<Map<String, dynamic>> result = await db.query(
      'badges',
      where: 'name = ? AND is_unlocked = 0',
      whereArgs: [badgeName],
    );

    if (result.isNotEmpty) {
      await db.update(
        'badges',
        {
          'is_unlocked': 1,
          'unlocked_at': DateTime.now().toIso8601String(),
        },
        where: 'name = ?',
        whereArgs: [badgeName],
      );
    }
  }


  // ===========================================================================
  // PREPAREDNESS TASKS OPERATIONS
  // ===========================================================================

  // Get all tasks
  Future<List<PreparednessTask>> getAllTasks() async {
    Database db = await instance.db;
    List<Map<String, dynamic>> result = await db.query('preparedness_tasks');
    return result.map((map) => PreparednessTask.fromMap(map)).toList();
  }

  // Get tasks by category
  Future<List<PreparednessTask>> getTasksByCategory(String category) async {
    Database db = await instance.db;
    List<Map<String, dynamic>> result = await db.query(
      'preparedness_tasks',
      where: 'category = ?',
      whereArgs: [category],
    );
    return result.map((map) => PreparednessTask.fromMap(map)).toList();
  }

  // Mark task as completed
  Future<void> completeTask(int taskId) async {
    Database db = await instance.db;

    // Get task to find its points value
    List<Map<String, dynamic>> result = await db.query(
      'preparedness_tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );

    if (result.isNotEmpty) {
      int points = result.first['points'] ?? 10;

      // Mark task as completed
      await db.update(
        'preparedness_tasks',
        {
          'is_completed': 1,
          'completed_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [taskId],
      );

      // Add points
      await addPoints(points);

      // Update tasks completed count
      GamificationData? data = await getGamificationData();
      if (data != null) {
        await db.update(
          'gamification_data',
          {'tasks_completed': data.tasksCompleted + 1},
          where: 'id = ?',
          whereArgs: [data.id],
        );
      }

      // Update preparedness level (now uses weighted algorithm)
      await updatePreparednessLevel();

      // Check for Kit Builder badge (all Emergency Kit tasks completed)
      List<PreparednessTask> kitTasks = await getTasksByCategory('Emergency Kit');
      bool allKitComplete = kitTasks.every((task) => task.isCompleted);
      if (allKitComplete) {
        await unlockBadge('Kit Builder');
      }
    }
  }


  // ===========================================================================
  // QUIZ RESULTS OPERATIONS (NEW - Preparedness Score Algorithm)
  // ===========================================================================

  // Save Quiz Result
  // Stores the result of a completed quiz. Called from QuizPlayPage after
  // user finishes a quiz. Used by Knowledge Score calculation.
  Future<int> saveQuizResult({
    required String category,
    required int score,
    required int totalQuestions,
    required int difficultyLevel,
  }) async {
    Database db = await instance.db;

    QuizResult result = QuizResult(
      category: category,
      score: score,
      totalQuestions: totalQuestions,
      difficultyLevel: difficultyLevel,
    );

    int id = await db.insert('quiz_results', result.toMap());

    // Update preparedness level after quiz completion
    await updatePreparednessLevel();

    // Check for Safety Pro badge (completed all quiz categories)
    await _checkSafetyProBadge(db);

    return id;
  }

  // Get Average Quiz Score
  // Returns the average percentage score across all completed quizzes.
  // Used by the Preparedness Score Algorithm (Knowledge Score component).
  Future<double> getAverageQuizScore() async {
    Database db = await instance.db;
    return await _calculateKnowledgeScore(db);
  }

  // Get Quiz Score by Category
  // Returns the most recent quiz score for a specific category.
  Future<QuizResult?> getLatestQuizResultByCategory(String category) async {
    Database db = await instance.db;

    List<Map<String, dynamic>> result = await db.query(
      'quiz_results',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'completed_at DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }
    return QuizResult.fromMap(result.first);
  }

  // Get All Quiz Results
  // Returns all quiz results, ordered by most recent first.
  Future<List<QuizResult>> getAllQuizResults() async {
    Database db = await instance.db;
    List<Map<String, dynamic>> result = await db.query(
      'quiz_results',
      orderBy: 'completed_at DESC',
    );
    return result.map((map) => QuizResult.fromMap(map)).toList();
  }

  // Check Safety Pro Badge
  // Awards badge if user has completed quizzes in all categories.
  Future<void> _checkSafetyProBadge(Database db) async {
    List<String> requiredCategories = ['Flood', 'Fire', 'Haze', 'Earthquake', 'General'];

    for (String category in requiredCategories) {
      List<Map<String, dynamic>> results = await db.query(
        'quiz_results',
        where: 'category = ?',
        whereArgs: [category],
        limit: 1,
      );

      if (results.isEmpty) {
        return; // Missing at least one category
      }
    }

    // User has completed all categories
    await unlockBadge('Safety Pro');
  }


  // ===========================================================================
  // ADAPTIVE QUIZ SYSTEM OPERATIONS
  // ===========================================================================

  // Get User's Difficulty Level for Category
  // Returns the current difficulty level (1-3) for a specific quiz category.
  Future<int> getUserDifficulty(String category) async {
    Database db = await instance.db;

    List<Map<String, dynamic>> result = await db.query(
      'user_quiz_difficulty',
      where: 'category = ?',
      whereArgs: [category],
      limit: 1,
    );

    if (result.isEmpty) {
      return 1; // Default to Beginner if not found
    }

    return result.first['difficulty_level'] ?? 1;
  }

  // Get User Quiz Difficulty Data
  // Returns the full difficulty data for a category including tracking stats.
  Future<UserQuizDifficulty?> getUserQuizDifficultyData(String category) async {
    Database db = await instance.db;

    List<Map<String, dynamic>> result = await db.query(
      'user_quiz_difficulty',
      where: 'category = ?',
      whereArgs: [category],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }
    return UserQuizDifficulty.fromMap(result.first);
  }

  // Update Difficulty After Quiz
  // Implements the adaptive algorithm that adjusts difficulty based on
  // user performance. Called after each quiz completion.
  Future<void> updateDifficultyAfterQuiz({
    required String category,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    Database db = await instance.db;

    // Get current difficulty data
    UserQuizDifficulty? currentData = await getUserQuizDifficultyData(category);

    if (currentData == null) {
      // Initialize if missing
      await _initializeQuizDifficulty(db);
      currentData = await getUserQuizDifficultyData(category);
    }

    int currentLevel = currentData?.difficultyLevel ?? 1;
    int consecutiveCorrect = currentData?.consecutiveCorrect ?? 0;
    int recentWrongCount = currentData?.recentWrongCount ?? 0;

    // Calculate wrong answers in this quiz
    int wrongAnswers = totalQuestions - correctAnswers;

    // Update tracking variables
    if (wrongAnswers == 0) {
      // Perfect score - add to consecutive correct
      consecutiveCorrect += totalQuestions;
      recentWrongCount = 0; // Reset wrong count on perfect quiz
    } else {
      // Had some wrong answers
      consecutiveCorrect = 0; // Reset consecutive correct
      recentWrongCount += wrongAnswers;

      // Cap recent wrong count at 5
      if (recentWrongCount > 5) {
        recentWrongCount = 5;
      }
    }

    // Apply adaptation rules
    int newLevel = currentLevel;

    // Rule 1: Increase difficulty after 3+ consecutive correct
    if (consecutiveCorrect >= 3 && currentLevel < 3) {
      newLevel = currentLevel + 1;
      consecutiveCorrect = 0; // Reset after level change
      recentWrongCount = 0;
    }

    // Rule 2: Decrease difficulty after 2+ wrong in recent questions
    if (recentWrongCount >= 2 && currentLevel > 1) {
      newLevel = currentLevel - 1;
      consecutiveCorrect = 0; // Reset after level change
      recentWrongCount = 0;
    }

    // Update database
    await db.update(
      'user_quiz_difficulty',
      {
        'difficulty_level': newLevel,
        'consecutive_correct': consecutiveCorrect,
        'recent_wrong_count': recentWrongCount,
        'last_updated': DateTime.now().toIso8601String(),
      },
      where: 'category = ?',
      whereArgs: [category],
    );

    // Check for Quiz Master badge (reached Advanced in any category)
    if (newLevel >= 3) {
      await unlockBadge('Quiz Master');
    }
  }

  // Get Points for Difficulty Level
  // Returns the point value for correct answers at a given difficulty.
  // - Beginner (1): 10 points
  // - Intermediate (2): 15 points
  // - Advanced (3): 25 points
  int getPointsForDifficulty(int difficultyLevel) {
    switch (difficultyLevel) {
      case 1:
        return 10; // Beginner
      case 2:
        return 15; // Intermediate
      case 3:
        return 25; // Advanced
      default:
        return 10;
    }
  }

  // Get Difficulty Name
  // Returns human-readable name for difficulty level.
  String getDifficultyName(int difficultyLevel) {
    switch (difficultyLevel) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Intermediate';
      case 3:
        return 'Advanced';
      default:
        return 'Beginner';
    }
  }

  // Get All Quiz Difficulties
  // Returns difficulty data for all categories.
  Future<Map<String, UserQuizDifficulty>> getAllQuizDifficulties() async {
    Database db = await instance.db;

    List<Map<String, dynamic>> results = await db.query('user_quiz_difficulty');

    Map<String, UserQuizDifficulty> difficulties = {};
    for (var result in results) {
      UserQuizDifficulty data = UserQuizDifficulty.fromMap(result);
      difficulties[data.category] = data;
    }

    return difficulties;
  }


  // ===========================================================================
  // FLOOD REPORTS OPERATIONS
  // ===========================================================================

  // Insert a flood report
  Future<int> insertFloodReport(FloodReport report) async {
    Database db = await instance.db;
    int result = await db.insert(
      'flood_reports',
      report.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Unlock Community Hero badge for first report
    await unlockBadge('Community Hero');

    return result;
  }

  // Get all flood reports
  Future<List<FloodReport>> getAllFloodReports() async {
    Database db = await instance.db;
    List<Map<String, dynamic>> result = await db.query(
      'flood_reports',
      orderBy: 'reported_at DESC', // Most recent first
    );
    return result.map((map) => FloodReport.fromMap(map)).toList();
  }

  // Delete a flood report
  Future<int> deleteFloodReport(int id) async {
    Database db = await instance.db;
    return await db.delete(
      'flood_reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  // ===========================================================================
  // USER ACCOUNT OPERATIONS
  // ===========================================================================

  // Insert a new user (sign up)
  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await instance.db;

    // Add created_at timestamp if not present
    if (!user.containsKey('created_at')) {
      user['created_at'] = DateTime.now().toIso8601String();
    }

    return await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.abort, // Fail if username/email exists
    );
  }

  // Query all users (for login validation)
  Future<List<Map<String, dynamic>>> queryAllUsers() async {
    Database db = await instance.db;
    return await db.query('users');
  }

  // Query single user by ID
  Future<Map<String, dynamic>?> queryUserById(int id) async {
    Database db = await instance.db;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Query user by username
  Future<Map<String, dynamic>?> queryUserByUsername(String username) async {
    Database db = await instance.db;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Update user display name
  Future<int> updateUserDisplayName(int id, String displayname) async {
    Database db = await instance.db;
    return await db.update(
      'users',
      {'displayname': displayname},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete user account
  Future<int> deleteUser(int id) async {
    Database db = await instance.db;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Reset Database
  // Deletes all data and re-initializes with defaults.
  // Used when user wants to start fresh from the profile settings.
  Future<void> resetDatabase() async {
    Database db = await instance.db;

    // Clear all tables
    await db.delete('user_profile');
    await db.delete('emergency_contacts');
    await db.delete('gamification_data');
    await db.delete('badges');
    await db.delete('preparedness_tasks');
    await db.delete('quiz_results');
    await db.delete('user_quiz_difficulty');
    await db.delete('flood_reports');

    // Re-initialize default data (badges, tasks, gamification)
    await _initializeDefaultData(db);
  }
}
# TogetherSafe 🛡️

A gamified mobile application for disaster preparedness in Singapore.
**Final Year Project** - **University of London**

## About

TogetherSafe helps Singapore residents prepare for emergencies through gamification and real-time alerts. The app transforms disaster preparedness from an abstract obligation into an engaging daily practice.

## Features

### Gamification System
- Points for completing preparedness tasks
- Streak tracking for daily engagement
- 9 unlockable achievement badges
- Preparedness score with 4 weighted components

### Dual-Mode Interface
- **Calm Mode**: Engaging interface with gamification elements for everyday use
- **Emergency Mode**: High-contrast, simplified interface for crisis situations

### Real-Time Alerts
- Integrates with Singapore government APIs (data.gov.sg)
- PSI readings and haze alerts
- Rainfall data for flood warnings
- Location-based alert filtering using postal code

### Educational Content
- 75 quiz questions across 5 disaster categories
- Adaptive difficulty system (Beginner → Intermediate → Advanced)
- 5 emergency guides (Flood, Haze, Fire, Earthquake, Pandemic)
- 12 preparedness tasks with step-by-step guidance

## Tech Stack

- **Framework**: Flutter (Dart)
- **Database**: SQLite (sqflite)
- **APIs**: Singapore Government data.gov.sg
- **IDE**: VS Code

## Project Structure

```
lib/
├── main.dart              # App entry point and navigation
├── db.dart                # SQLite database helper
├── api_service.dart       # Government API integration
├── homepage.dart          # Calm Mode home page
├── emergencyhomepage.dart # Emergency Mode interface
├── quizpage.dart          # Adaptive quiz system
├── guidespage.dart        # Emergency response guides
├── checklistpage.dart     # Preparedness tasks
├── profilepage.dart       # User profile and settings
├── onboardingscreen.dart  # New user setup
├── reportpage.dart        # Community flood reporting
├── loginpage.dart         # Optional login
└── signuppage.dart        # Optional sign up
```

## Key Algorithms

### Preparedness Score
Calculates user readiness using weighted components:
- Task Completion (40%)
- Knowledge Score (25%)
- Recency Factor (20%)
- Household Coverage (15%)

### Adaptive Quiz System
- 3 difficulty levels with different point values (10/15/25)
- Level increases after 3 consecutive correct answers
- Level decreases after 2 wrong answers in 5 questions

## APIs Used

| API | Purpose |
|-----|---------|
| 2-hour weather forecast | Current weather conditions |
| 24-hour weather forecast | Weather predictions |
| PSI readings | Air quality monitoring |
| Air temperature | Temperature data |
| Rainfall data | Flood risk detection |

## Screenshots

<img width="1527" height="3289" alt="image" src="https://github.com/user-attachments/assets/2316cdce-0233-4e1e-93a4-158ea77338b0" />

## Author

**Riski Linardi**  

## License

This project is submitted as part of the University of London BSc Computer Science programme.

// =============================================================================
// checklistpage.dart - Preparedness Checklist Page
// =============================================================================
// This page displays all preparedness tasks organised by category. Users can
// mark tasks as complete to earn points and increase their preparedness level.
//
// The checklist is a core feature of the gamification system. Each task has:
// - A title and description explaining what to do
// - A point value (harder tasks = more points)
// - Completion status (saved to database)
//
// Tasks are organised into categories:
// - Emergency Kit: Items to gather for your emergency supplies
// - Home Safety: Things to check/prepare around your home
// - Documents: Important paperwork to organise
//
// When a task is completed:
// 1. Task marked as complete in database
// 2. Points added to user's total
// 3. Preparedness level recalculated
// 4. Badge checks triggered (e.g., "Kit Builder" badge)
// =============================================================================

import 'package:flutter/material.dart';
import 'db.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({Key? key}) : super(key: key);

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  // ===========================================================================
  // STATE VARIABLES
  // ===========================================================================

  // Loading state while fetching tasks from database
  bool _isLoading = true;

  // All tasks from database, organised by category
  // Map structure: { "Emergency Kit": [task1, task2], "Home Safety": [task3] }
  Map<String, List<PreparednessTask>> _tasksByCategory = {};
  Map<String, bool> _categoryExpanded = {};
  int _totalTasks = 0;
  int _completedTasks = 0;
  int _totalPoints = 0;
  int _earnedPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Load Tasks From Database
  // Fetches all preparedness tasks and organises them by category.
  // Also calculates summary statistics for the header.
  Future<void> _loadTasks() async {
    try {
      // Fetch all tasks from database
      List<PreparednessTask> allTasks = await DatabaseHelper.instance.getAllTasks();

      // Organise tasks by category
      Map<String, List<PreparednessTask>> organised = {};

      for (PreparednessTask task in allTasks) {
        // Create category list if it doesn't exist
        if (!organised.containsKey(task.category)) {
          organised[task.category] = [];
        }
        // Add task to its category
        organised[task.category]!.add(task);
      }

      // Calculate statistics
      int total = allTasks.length;
      int completed = allTasks.where((t) => t.isCompleted).length;
      int totalPts = allTasks.fold(0, (sum, t) => sum + t.points);
      int earnedPts = allTasks.where((t) => t.isCompleted).fold(0, (sum, t) => sum + t.points);

      // Initialise expansion state for each category
      Map<String, bool> expanded = {};
      for (String category in organised.keys) {
        expanded[category] = true;
      }

      // Update state
      setState(() {
        _tasksByCategory = organised;
        _categoryExpanded = expanded;
        _totalTasks = total;
        _completedTasks = completed;
        _totalPoints = totalPts;
        _earnedPoints = earnedPts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle Task Completion
  // Called when user taps on a task to mark it complete.
  // Updates the database and refreshes the UI.
  Future<void> _completeTask(PreparednessTask task) async {
    // Don't allow uncompleting tasks
    if (task.isCompleted) {
      _showSnackBar('Task already completed!');
      return;
    }

    try {
      // Mark task as complete in database
      // This also adds points and updates preparedness level
      await DatabaseHelper.instance.completeTask(task.id!);

      // Show success message with points earned
      _showSnackBar('+${task.points} points! Task completed!');

      // Reload tasks to update UI
      await _loadTasks();

      // Check if user just completed all tasks in a category
      _checkCategoryCompletion(task.category);

    } catch (e) {
      debugPrint('Error completing task: $e');
      _showSnackBar('Error completing task. Please try again.');
    }
  }

  // Check Category Completion
  // Shows a special message when user completes all tasks in a category.
  void _checkCategoryCompletion(String category) {
    List<PreparednessTask>? tasks = _tasksByCategory[category];
    if (tasks == null) return;

    bool allComplete = tasks.every((t) => t.isCompleted);
    if (allComplete) {
      // Show celebration dialog
      _showCelebrationDialog(category);
    }
  }

  // Show Celebration Dialog
  // Displayed when user completes all tasks in a category.
  // This is a gamification technique to reward milestone achievements.
  void _showCelebrationDialog(String category) {
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
            const Text('🎊', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Category Complete!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0E0E0),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ve completed all tasks in "$category"!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF778DA9),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your badges - you might have unlocked something new!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF4FC3F7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Awesome!',
              style: TextStyle(
                color: Color(0xFF4FC3F7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show Snackbar
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

      // App bar with title
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        title: const Text(
          'Preparedness Checklist',
          style: TextStyle(
            color: Color(0xFFE0E0E0),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF778DA9)),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: _isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
        onRefresh: _loadTasks,
        color: const Color(0xFF4FC3F7),
        backgroundColor: const Color(0xFF0D1B2A),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Progress summary card at top
            _buildProgressSummary(),

            const SizedBox(height: 20),

            // Task categories
            ..._buildCategoryList(),

            // Bottom padding
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // UI COMPONENTS
  // ===========================================================================

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
            'Loading checklist...',
            style: TextStyle(
              color: Color(0xFF778DA9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Progress Summary Card
  // Shows overall progress at the top of the page.
  // Displays: tasks completed, points earned, progress bar.
  Widget _buildProgressSummary() {
    double progress = _totalTasks > 0 ? _completedTasks / _totalTasks : 0;
    int percentComplete = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
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
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tasks count
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tasks Completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_completedTasks / $_totalTasks',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              // Points display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '$_earnedPoints / $_totalPoints pts',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
              minHeight: 10,
            ),
          ),

          const SizedBox(height: 8),

          // Percentage text
          Text(
            '$percentComplete% complete',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // Category List Builder
  // Builds expandable sections for each category.
  List<Widget> _buildCategoryList() {
    List<Widget> widgets = [];

    // Define category order and icons
    Map<String, String> categoryIcons = {
      'Emergency Kit': '🎒',
      'Home Safety': '🏠',
      'Documents': '📄',
    };

    // Build each category section
    for (String category in _tasksByCategory.keys) {
      List<PreparednessTask> tasks = _tasksByCategory[category]!;
      String icon = categoryIcons[category] ?? '📋';
      int completedInCategory = tasks.where((t) => t.isCompleted).length;

      widgets.add(
        _buildCategorySection(
          category: category,
          icon: icon,
          tasks: tasks,
          completedCount: completedInCategory,
        ),
      );

      widgets.add(const SizedBox(height: 12));
    }

    return widgets;
  }

  // Category Section
  // Expandable section containing all tasks for a category.
  Widget _buildCategorySection({
    required String category,
    required String icon,
    required List<PreparednessTask> tasks,
    required int completedCount,
  }) {
    bool isExpanded = _categoryExpanded[category] ?? true;
    bool isComplete = completedCount == tasks.length;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isComplete ? const Color(0xFF4FC3F7) : const Color(0xFF415A77),
          width: isComplete ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Category header (tappable to expand/collapse)
          GestureDetector(
            onTap: () {
              setState(() {
                _categoryExpanded[category] = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Category icon
                  Text(icon, style: const TextStyle(fontSize: 24)),

                  const SizedBox(width: 12),

                  // Category name and count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$completedCount of ${tasks.length} completed',
                          style: TextStyle(
                            fontSize: 12,
                            color: isComplete
                                ? const Color(0xFF4FC3F7)
                                : const Color(0xFF778DA9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Completion checkmark or expand arrow
                  if (isComplete)
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4FC3F7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.black,
                        size: 18,
                      ),
                    )
                  else
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: const Color(0xFF778DA9),
                    ),
                ],
              ),
            ),
          ),

          // Task list (shown when expanded)
          if (isExpanded) ...[
            const Divider(color: Color(0xFF415A77), height: 1),
            ...tasks.map((task) => _buildTaskItem(task)).toList(),
          ],
        ],
      ),
    );
  }

  // Individual Task Item
  // Displays a single task with checkbox, title, description, and points.
  Widget _buildTaskItem(PreparednessTask task) {
    return GestureDetector(
      onTap: () => _completeTask(task),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF415A77), width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? const Color(0xFF4FC3F7)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: task.isCompleted
                      ? const Color(0xFF4FC3F7)
                      : const Color(0xFF778DA9),
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, color: Colors.black, size: 16)
                  : null,
            ),

            const SizedBox(width: 12),

            // Task details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task title
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: task.isCompleted
                          ? const Color(0xFF778DA9)
                          : const Color(0xFFE0E0E0),
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Task description
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: task.isCompleted
                          ? const Color(0xFF415A77)
                          : const Color(0xFF778DA9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Points badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? const Color(0xFF415A77).withOpacity(0.5)
                    : const Color(0xFF415A77),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${task.points}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: task.isCompleted
                      ? const Color(0xFF778DA9)
                      : const Color(0xFF4FC3F7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'activity_screen.dart';
import 'insights_screen.dart';
import 'plan_screen.dart';
import 'profile_screen.dart';
import 'today_screen.dart';
import 'workout_session_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _screens = [
    TodayScreen(),
    PlanScreen(),
    ActivityScreen(),
    InsightsScreen(),
    ProfileScreen(),
  ];

  void _startWorkout() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const WorkoutSessionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: _startWorkout,
              backgroundColor: AppTheme.ink,
              foregroundColor: Colors.white,
              elevation: 5,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start workout'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Today'),
          NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center_rounded),
              label: 'Train'),
          NavigationDestination(
              icon: Icon(Icons.history_rounded),
              selectedIcon: Icon(Icons.history_toggle_off_rounded),
              label: 'Activity'),
          NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded),
              label: 'Insights'),
          NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'You'),
        ],
      ),
    );
  }
}

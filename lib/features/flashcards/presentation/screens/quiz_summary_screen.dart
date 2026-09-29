import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/deck.dart';
import '../../domain/entities/quiz_stat.dart';

class QuizSummaryScreen extends StatelessWidget {
  const QuizSummaryScreen({
    super.key,
    required this.deck,
    required this.stat,
  });

  final Deck deck;
  final QuizStat stat;

  String get _durationLabel {
    final minutes = stat.durationSeconds ~/ 60;
    final seconds = stat.durationSeconds % 60;
    if (minutes == 0) {
      return '${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }

  String get _headline {
    final accuracy = stat.accuracy;
    if (accuracy >= 0.9) {
      return 'Amazing work!';
    }
    if (accuracy >= 0.7) {
      return 'Great job!';
    }
    if (accuracy >= 0.5) {
      return 'Nice progress!';
    }
    return 'Keep practicing!';
  }

  String get _message {
    final accuracy = stat.accuracy;
    if (accuracy >= 0.9) {
      return 'You really know this deck.';
    }
    if (accuracy >= 0.7) {
      return 'A quick review will make it even stronger.';
    }
    if (accuracy >= 0.5) {
      return 'You are getting there — another round will help.';
    }
    return 'Review the cards you forgot and try again soon.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accuracy = (stat.accuracy * 100).round();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Self assessment complete'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FF),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 126,
                            height: 126,
                            child: CircularProgressIndicator(
                              value: stat.accuracy,
                              strokeWidth: 12,
                              strokeCap: StrokeCap.round,
                              color: AppTheme.purple,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.85,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '$accuracy%',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontSize: 34,
                                  color: AppTheme.purple,
                                ),
                              ),
                              Text(
                                'accuracy',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(_headline, style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 7),
                      Text(
                        _message,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.mutedInk,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        deck.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.purple,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: 'Remembered',
                        value: '${stat.correct}',
                        icon: Icons.check_rounded,
                        background: AppTheme.successLight,
                        foreground: const Color(0xFF19825C),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        label: 'Forgot',
                        value: '${stat.incorrect}',
                        icon: Icons.close_rounded,
                        background: AppTheme.errorLight,
                        foreground: AppTheme.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MetricCard(
                  label: 'Time taken',
                  value: _durationLabel,
                  icon: Icons.timer_rounded,
                  background: const Color(0xFFE4F2FF),
                  foreground: AppTheme.blue,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to deck'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: foreground, size: 22),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

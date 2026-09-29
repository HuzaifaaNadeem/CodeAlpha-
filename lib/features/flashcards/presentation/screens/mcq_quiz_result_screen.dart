import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/deck.dart';
import '../../domain/entities/mcq_question.dart';
import '../../domain/entities/quiz_stat.dart';
import '../providers/mcq_quiz_provider.dart';
import 'mcq_quiz_screen.dart';
import 'mcq_review_screen.dart';

class McqQuizResultScreen extends ConsumerWidget {
  const McqQuizResultScreen({
    super.key,
    required this.deck,
    required this.stat,
    required this.attempts,
  });

  final Deck deck;
  final QuizStat stat;
  final List<McqAttempt> attempts;

  String get _durationLabel {
    final minutes = stat.durationSeconds ~/ 60;
    final seconds = stat.durationSeconds % 60;
    if (minutes == 0) {
      return '${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }

  String get _headline {
    if (stat.accuracy >= 0.9) {
      return 'Quiz master!';
    }
    if (stat.accuracy >= 0.7) {
      return 'Great score!';
    }
    if (stat.accuracy >= 0.5) {
      return 'Good progress!';
    }
    return 'Keep going!';
  }

  String get _message {
    if (stat.accuracy >= 0.9) {
      return 'You crushed this deck. That knowledge is sticking.';
    }
    if (stat.accuracy >= 0.7) {
      return 'Strong result. Review the misses and you are almost there.';
    }
    if (stat.accuracy >= 0.5) {
      return 'A quick review of your mistakes should lift your next score.';
    }
    return 'Review the missed answers, then give the quiz another shot.';
  }

  void _retry(BuildContext context, WidgetRef ref) {
    ref.invalidate(mcqQuizSessionProvider(deck.id));
    ref.invalidate(mcqQuestionsProvider(deck.id));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => McqQuizScreen(deck: deck),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accuracy = (stat.accuracy * 100).round();
    final wrongAttempts =
        attempts.where((attempt) => !attempt.isCorrect).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('MCQ complete'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFEDE9FF),
                        Color(0xFFE4F2FF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 132,
                            height: 132,
                            child: CircularProgressIndicator(
                              value: stat.accuracy,
                              strokeWidth: 12,
                              strokeCap: StrokeCap.round,
                              color: AppTheme.purple,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.86,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '$accuracy%',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontSize: 35,
                                  color: AppTheme.purple,
                                ),
                              ),
                              Text(
                                '${stat.correct}/${stat.total} correct',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        _headline,
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        _message,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.mutedInk,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 9),
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
                        label: 'Correct',
                        value: '${stat.correct}',
                        icon: Icons.check_rounded,
                        background: AppTheme.successLight,
                        foreground: const Color(0xFF19825C),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        label: 'Wrong',
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
                  background: const Color(0xFFFFF1CB),
                  foreground: AppTheme.orange,
                ),
                const SizedBox(height: 22),
                if (wrongAttempts.isNotEmpty) ...[
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => McqReviewScreen(attempts: attempts),
                      ),
                    ),
                    icon: const Icon(Icons.fact_check_outlined),
                    label: Text(
                      'Review ${wrongAttempts.length} mistake${wrongAttempts.length == 1 ? '' : 's'}',
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                FilledButton.icon(
                  onPressed: () => _retry(context, ref),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Retry MCQ quiz'),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
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
              color: Colors.white.withValues(alpha: 0.74),
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

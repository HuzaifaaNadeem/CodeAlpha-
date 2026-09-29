import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/mcq_question.dart';

class McqReviewScreen extends StatelessWidget {
  const McqReviewScreen({
    super.key,
    required this.attempts,
  });

  final List<McqAttempt> attempts;

  @override
  Widget build(BuildContext context) {
    final wrongAttempts =
        attempts.where((attempt) => !attempt.isCorrect).toList();

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review mistakes'),
      ),
      body: wrongAttempts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: const BoxDecoration(
                        color: AppTheme.successLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        size: 42,
                        color: AppTheme.green,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Nothing to review!',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'You answered every MCQ correctly.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 760,
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    30,
                  ),
                  itemCount: wrongAttempts.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: 14,
                    );
                  },
                  itemBuilder: (context, index) {
                    final attempt = wrongAttempts[index];

                    return _ReviewCard(
                      number: index + 1,
                      attempt: attempt,
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.number,
    required this.attempt,
  });

  final int number;
  final McqAttempt attempt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE8E9F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE6EF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  '$number',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.pink,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FF),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  attempt.question.card.category,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.purple,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            attempt.question.card.question,
            style: theme.textTheme.titleMedium?.copyWith(
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _ReviewAnswer(
            label: 'Your answer',
            value: attempt.selectedAnswer,
            background: AppTheme.errorLight,
            foreground: AppTheme.red,
            icon: Icons.close_rounded,
          ),
          const SizedBox(height: 9),
          _ReviewAnswer(
            label: 'Correct answer',
            value: attempt.question.correctAnswer,
            background: AppTheme.successLight,
            foreground: const Color(0xFF19825C),
            icon: Icons.check_rounded,
          ),
        ],
      ),
    );
  }
}

class _ReviewAnswer extends StatelessWidget {
  const _ReviewAnswer({
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final String label;
  final String value;
  final Color background;
  final Color foreground;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: foreground,
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w700,
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

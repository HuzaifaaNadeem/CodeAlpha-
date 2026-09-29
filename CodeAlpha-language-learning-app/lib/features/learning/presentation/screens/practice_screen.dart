import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/learning_providers.dart';
import 'flashcard_practice_screen.dart';
import 'matching_practice_screen.dart';
import 'mcq_practice_screen.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(allItemsProvider);
    final progress = ref.watch(progressControllerProvider);
    final accuracy =
        progress.maybeWhen(data: (state) => state.accuracy, orElse: () => 0.0);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
            children: [
              Text('Practice', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 7),
              Text(
                  'Short sessions designed for recall, recognition, and speed.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppTheme.muted)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppTheme.ink,
                    borderRadius: BorderRadius.circular(26)),
                child: Row(
                  children: [
                    Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                            color: Colors.white10, shape: BoxShape.circle),
                        child: const Icon(Icons.auto_graph_rounded,
                            color: AppTheme.yellow)),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          const Text('Practice accuracy',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 3),
                          Text('${(accuracy * 100).round()}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800))
                        ])),
                    Text('${items.length} items',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _ModeCard(
                icon: Icons.style_rounded,
                color: const Color(0xFFE8E7FF),
                title: 'Flashcards',
                subtitle:
                    'Flip through Spanish words and phrases at your own pace.',
                badge: 'RECALL',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                        builder: (_) => const FlashcardPracticeScreen())),
              ),
              const SizedBox(height: 12),
              _ModeCard(
                icon: Icons.quiz_rounded,
                color: const Color(0xFFE2F6EA),
                title: 'Multiple choice',
                subtitle:
                    'Choose the correct Spanish translation from four options.',
                badge: 'QUIZ',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                        builder: (_) => const McqPracticeScreen())),
              ),
              const SizedBox(height: 12),
              _ModeCard(
                icon: Icons.grid_view_rounded,
                color: const Color(0xFFFFEBC2),
                title: 'Match pairs',
                subtitle:
                    'Match English prompts with their Spanish equivalents.',
                badge: 'SPEED',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                        builder: (_) => const MatchingPracticeScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle,
      required this.badge,
      required this.onTap});
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              border: Border.all(color: AppTheme.outline),
              borderRadius: BorderRadius.circular(24)),
          child: Row(children: [
            Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(18)),
                child: Icon(icon, color: AppTheme.ink)),
            const SizedBox(width: 15),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Expanded(
                        child: Text(title,
                            style: Theme.of(context).textTheme.titleMedium)),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(99)),
                        child: Text(badge,
                            style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7)))
                  ]),
                  const SizedBox(height: 5),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium)
                ])),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, color: AppTheme.primary),
          ]),
        ),
      ),
    );
  }
}

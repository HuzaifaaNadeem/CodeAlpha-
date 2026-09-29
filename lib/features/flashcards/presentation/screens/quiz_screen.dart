import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/deck.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/entities/quiz_stat.dart';
import '../providers/flashcard_providers.dart';
import '../providers/quiz_session_provider.dart';
import '../widgets/card_stack.dart';
import '../widgets/flip_flashcard.dart';
import 'quiz_summary_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({
    super.key,
    required this.deck,
    required this.cards,
  });

  final Deck deck;
  final List<Flashcard> cards;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  bool _savingResult = false;

  void _reveal() {
    final session = ref.read(quizSessionProvider(widget.deck.id));
    if (session.answerRevealed) return;
    HapticFeedback.selectionClick();
    ref.read(quizSessionProvider(widget.deck.id).notifier).revealAnswer();
  }

  Future<void> _mark(bool remembered) async {
    final controller = ref.read(quizSessionProvider(widget.deck.id).notifier);
    final before = ref.read(quizSessionProvider(widget.deck.id));
    if (!before.answerRevealed || _savingResult) return;

    if (remembered) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
    }

    controller.markAnswer(
      remembered: remembered,
      totalCards: widget.cards.length,
    );
    final after = ref.read(quizSessionProvider(widget.deck.id));

    if (after.finished) {
      setState(() => _savingResult = true);
      final duration = DateTime.now().difference(after.startedAt);
      final stat = QuizStat(
        id: const Uuid().v4(),
        deckId: widget.deck.id,
        correct: after.correct,
        incorrect: after.incorrect,
        durationSeconds: duration.inSeconds,
        completedAt: DateTime.now(),
      );

      await ref.read(flashcardRepositoryProvider).saveQuizStat(stat);
      ref.invalidate(statsProvider(widget.deck.id));

      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizSummaryScreen(deck: widget.deck, stat: stat),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(quizSessionProvider(widget.deck.id));
    final theme = Theme.of(context);
    final card = widget.cards[session.index];
    final progress = (session.index + 1) / widget.cards.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Self assessment'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F2FF),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 16, color: AppTheme.green),
                    const SizedBox(width: 5),
                    Text(
                      '${session.correct}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardHeight = constraints.maxHeight < 700 ? 335.0 : 400.0;

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Question ${session.index + 1} of ${widget.cards.length}',
                        style: theme.textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Text(
                        '${(progress * 100).round()}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.blue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      minHeight: 9,
                      value: progress,
                      color: AppTheme.blue,
                      backgroundColor: const Color(0xFFDDEBFA),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: GestureDetector(
                          onTap: _reveal,
                          child: CardStack(
                            height: cardHeight,
                            child: FlipFlashcard(
                              card: card,
                              height: cardHeight,
                              tapEnabled: false,
                              showAnswerSignal: session.answerRevealed ? 1 : 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: !session.answerRevealed
                          ? Column(
                              key: const ValueKey('reveal'),
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppTheme.blue,
                                    ),
                                    onPressed: _reveal,
                                    icon: const Icon(Icons.visibility_rounded),
                                    label: const Text('Show answer'),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Think of the answer first, then reveal it.',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(fontSize: 12.5),
                                ),
                              ],
                            )
                          : Column(
                              key: const ValueKey('assessment'),
                              children: [
                                Text(
                                  'How did you do?',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 11),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _AssessmentButton(
                                        label: 'Forgot',
                                        subtitle: 'Review again',
                                        icon: Icons.close_rounded,
                                        background: AppTheme.errorLight,
                                        foreground: AppTheme.red,
                                        onPressed: _savingResult
                                            ? null
                                            : () => _mark(false),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _AssessmentButton(
                                        label: 'Got it!',
                                        subtitle: 'Remembered',
                                        icon: Icons.check_rounded,
                                        background: AppTheme.successLight,
                                        foreground: const Color(0xFF19825C),
                                        onPressed: _savingResult
                                            ? null
                                            : () => _mark(true),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AssessmentButton extends StatelessWidget {
  const _AssessmentButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: foreground),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: foreground,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: foreground.withValues(alpha: 0.75),
                            fontSize: 11.5,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

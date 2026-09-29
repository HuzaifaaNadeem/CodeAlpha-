import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/deck.dart';
import '../../domain/entities/mcq_question.dart';
import '../../domain/entities/quiz_stat.dart';
import '../providers/flashcard_providers.dart';
import '../providers/mcq_quiz_provider.dart';
import 'mcq_quiz_result_screen.dart';

class McqQuizScreen extends ConsumerStatefulWidget {
  const McqQuizScreen({
    super.key,
    required this.deck,
  });

  final Deck deck;

  @override
  ConsumerState<McqQuizScreen> createState() => _McqQuizScreenState();
}

class _McqQuizScreenState extends ConsumerState<McqQuizScreen> {
  bool _savingResult = false;

  void _selectAnswer(McqQuestion question, String answer) {
    final session = ref.read(mcqQuizSessionProvider(widget.deck.id));
    if (session.hasAnswered || session.finished) {
      return;
    }

    final isCorrect = question.isCorrect(answer);
    if (isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
    }

    ref.read(mcqQuizSessionProvider(widget.deck.id).notifier).selectAnswer(
          question: question,
          answer: answer,
        );
  }

  Future<void> _next(List<McqQuestion> questions) async {
    if (_savingResult) {
      return;
    }

    final controller =
        ref.read(mcqQuizSessionProvider(widget.deck.id).notifier);
    final before = ref.read(mcqQuizSessionProvider(widget.deck.id));
    if (!before.hasAnswered) {
      return;
    }

    final isLast = before.index >= questions.length - 1;
    controller.next(totalQuestions: questions.length);

    if (!isLast) {
      HapticFeedback.selectionClick();
      return;
    }

    setState(() => _savingResult = true);
    final completed = ref.read(mcqQuizSessionProvider(widget.deck.id));
    final duration = DateTime.now().difference(completed.startedAt);
    final stat = QuizStat(
      id: const Uuid().v4(),
      deckId: widget.deck.id,
      correct: completed.correct,
      incorrect: completed.incorrect,
      durationSeconds: duration.inSeconds,
      completedAt: DateTime.now(),
    );

    await ref.read(flashcardRepositoryProvider).saveQuizStat(stat);
    ref.invalidate(statsProvider(widget.deck.id));

    if (!mounted) {
      return;
    }

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => McqQuizResultScreen(
          deck: widget.deck,
          stat: stat,
          attempts: completed.attempts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(mcqQuestionsProvider(widget.deck.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('MCQ Quiz'),
      ),
      body: questions.when(
        loading: () => const _QuizLoadingView(),
        error: (error, _) => _QuizUnavailableView(
          title: 'Could not build the quiz',
          message: error.toString(),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const _QuizUnavailableView(
              title: 'Not enough answers yet',
              message:
                  'MCQ mode needs at least four distinct answers across your local flashcard library. Add a few more cards and try again.',
            );
          }

          return _QuizBody(
            deckId: widget.deck.id,
            questions: items,
            savingResult: _savingResult,
            onSelectAnswer: _selectAnswer,
            onNext: () => _next(items),
          );
        },
      ),
    );
  }
}

class _QuizBody extends ConsumerWidget {
  const _QuizBody({
    required this.deckId,
    required this.questions,
    required this.savingResult,
    required this.onSelectAnswer,
    required this.onNext,
  });

  final String deckId;
  final List<McqQuestion> questions;
  final bool savingResult;
  final void Function(McqQuestion question, String answer) onSelectAnswer;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(mcqQuizSessionProvider(deckId));
    final question = questions[session.index];
    final progress = (session.index + 1) / questions.length;
    final selected = session.selectedAnswer;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FF),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'Question ${session.index + 1} of ${questions.length}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.purple,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.stars_rounded,
                    size: 19,
                    color: AppTheme.orange,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${session.correct}/${questions.length}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 9,
                  value: progress,
                  color: AppTheme.purple,
                  backgroundColor: const Color(0xFFE8E5FA),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFEDE9FF),
                      Color(0xFFE4F2FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            question.card.category,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.purple,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.quiz_rounded,
                          color: AppTheme.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Text(
                      question.card.question,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Choose the best answer below.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              for (var index = 0; index < question.options.length; index++) ...[
                _AnswerOption(
                  index: index,
                  answer: question.options[index],
                  correctAnswer: question.correctAnswer,
                  selectedAnswer: selected,
                  onTap: () => onSelectAnswer(
                    question,
                    question.options[index],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: selected == null
                    ? const SizedBox.shrink()
                    : _AnswerFeedback(
                        key: ValueKey('${question.card.id}-$selected'),
                        correct: question.isCorrect(selected),
                        correctAnswer: question.correctAnswer,
                      ),
              ),
              if (selected != null) ...[
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: savingResult ? null : onNext,
                  icon: Icon(
                    session.index == questions.length - 1
                        ? Icons.emoji_events_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                  label: Text(
                    session.index == questions.length - 1
                        ? 'See results'
                        : 'Next question',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.index,
    required this.answer,
    required this.correctAnswer,
    required this.selectedAnswer,
    required this.onTap,
  });

  final int index;
  final String answer;
  final String correctAnswer;
  final String? selectedAnswer;
  final VoidCallback onTap;

  bool _same(String first, String second) =>
      first.trim().toLowerCase() == second.trim().toLowerCase();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final answered = selectedAnswer != null;
    final isCorrect = _same(answer, correctAnswer);
    final isSelected = selectedAnswer != null && _same(answer, selectedAnswer!);

    Color background = Colors.white;
    Color border = const Color(0xFFE5E6EE);
    Color accent = AppTheme.purple;
    IconData? statusIcon;

    if (answered && isCorrect) {
      background = AppTheme.successLight;
      border = AppTheme.green;
      accent = const Color(0xFF19825C);
      statusIcon = Icons.check_circle_rounded;
    } else if (answered && isSelected) {
      background = AppTheme.errorLight;
      border = AppTheme.red;
      accent = AppTheme.red;
      statusIcon = Icons.cancel_rounded;
    } else if (answered) {
      background = const Color(0xFFF4F5F8);
      border = const Color(0xFFE7E8EE);
      accent = AppTheme.mutedInk;
    }

    final letters = ['A', 'B', 'C', 'D'];

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: answered ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border, width: answered ? 1.5 : 1.0),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: answered
                      ? Colors.white.withValues(alpha: 0.78)
                      : const Color(0xFFEDE9FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  letters[index],
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  answer,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: answered && !isCorrect && !isSelected
                        ? AppTheme.mutedInk
                        : AppTheme.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (statusIcon != null) ...[
                const SizedBox(width: 10),
                Icon(statusIcon, color: accent),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerFeedback extends StatelessWidget {
  const _AnswerFeedback({
    super.key,
    required this.correct,
    required this.correctAnswer,
  });

  final bool correct;
  final String correctAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = correct ? const Color(0xFF19825C) : AppTheme.red;
    final background = correct ? AppTheme.successLight : AppTheme.errorLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correct ? Icons.celebration_rounded : Icons.lightbulb_rounded,
            color: foreground,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  correct ? 'Correct!' : 'Not quite',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: foreground,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  correct
                      ? 'Nice work — you picked the right answer.'
                      : 'Correct answer: $correctAnswer',
                  style: theme.textTheme.bodyMedium?.copyWith(
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

class _QuizLoadingView extends StatelessWidget {
  const _QuizLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Building your quiz…'),
        ],
      ),
    );
  }
}

class _QuizUnavailableView extends StatelessWidget {
  const _QuizUnavailableView({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1CB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.quiz_outlined,
                  size: 36,
                  color: AppTheme.orange,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back to deck'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

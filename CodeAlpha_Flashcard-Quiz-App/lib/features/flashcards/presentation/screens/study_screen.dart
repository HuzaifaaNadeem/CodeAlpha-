import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/deck.dart';
import '../../domain/entities/flashcard.dart';
import '../widgets/card_stack.dart';
import '../widgets/flip_flashcard.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({
    super.key,
    required this.deck,
    required this.cards,
  });

  final Deck deck;
  final List<Flashcard> cards;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  int _index = 0;
  int _showAnswerSignal = 0;

  bool get _hasPrevious => _index > 0;
  bool get _hasNext => _index < widget.cards.length - 1;

  void _previous() {
    if (!_hasPrevious) return;
    HapticFeedback.selectionClick();
    setState(() => _index--);
  }

  void _next() {
    if (!_hasNext) return;
    HapticFeedback.selectionClick();
    setState(() => _index++);
  }

  void _onSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -250) _next();
    if (velocity > 250) _previous();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = widget.cards[_index];
    final progress = (_index + 1) / widget.cards.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study mode'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FF),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  widget.deck.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.purple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardHeight = constraints.maxHeight < 700 ? 350.0 : 410.0;

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Card ${_index + 1} of ${widget.cards.length}',
                        style: theme.textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Text(
                        '${(progress * 100).round()}% complete',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.purple,
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
                      backgroundColor: const Color(0xFFE9E7F5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onHorizontalDragEnd: _onSwipe,
                          child: CardStack(
                            height: cardHeight,
                            child: FlipFlashcard(
                              card: card,
                              height: cardHeight,
                              showAnswerSignal: _showAnswerSignal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD166),
                              foregroundColor: AppTheme.ink,
                            ),
                            onPressed: () =>
                                setState(() => _showAnswerSignal++),
                            icon: const Icon(Icons.flip_rounded),
                            label: const Text('Flip card'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _hasPrevious ? _previous : null,
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: const Text('Previous'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _hasNext
                                    ? _next
                                    : () => Navigator.pop(context),
                                icon: Icon(
                                  _hasNext
                                      ? Icons.arrow_forward_rounded
                                      : Icons.check_rounded,
                                ),
                                label: Text(_hasNext ? 'Next card' : 'Finish'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tip: swipe left or right to move between cards.',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontSize: 12.5),
                        ),
                      ],
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

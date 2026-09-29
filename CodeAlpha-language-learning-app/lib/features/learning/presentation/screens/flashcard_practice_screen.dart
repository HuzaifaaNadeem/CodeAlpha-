import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/sources/practice_factory.dart';
import '../../domain/entities/learning_item.dart';
import '../providers/learning_providers.dart';

class FlashcardPracticeScreen extends ConsumerStatefulWidget {
  const FlashcardPracticeScreen({super.key});

  @override
  ConsumerState<FlashcardPracticeScreen> createState() =>
      _FlashcardPracticeScreenState();
}

class _FlashcardPracticeScreenState
    extends ConsumerState<FlashcardPracticeScreen> {
  late List<LearningItem> _cards;
  var _index = 0;
  var _showBack = false;

  @override
  void initState() {
    super.initState();
    _cards = PracticeFactory.flashcards(ref.read(allItemsProvider));
    ref.read(progressControllerProvider.notifier).touchStudyDay();
  }

  void _next() {
    if (_index >= _cards.length - 1) {
      setState(() {
        _cards = PracticeFactory.flashcards(_cards);
        _index = 0;
        _showBack = false;
      });
      return;
    }
    setState(() {
      _index++;
      _showBack = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = _cards[_index];
    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  Row(children: [
                    Text('Card ${_index + 1} of ${_cards.length}',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const Spacer(),
                    TextButton.icon(
                        onPressed: () => setState(() {
                              _cards = PracticeFactory.flashcards(_cards);
                              _index = 0;
                              _showBack = false;
                            }),
                        icon: const Icon(Icons.shuffle_rounded),
                        label: const Text('Shuffle'))
                  ]),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _showBack = !_showBack);
                      },
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: _showBack ? math.pi : 0),
                        duration: const Duration(milliseconds: 360),
                        curve: Curves.easeOutCubic,
                        builder: (context, angle, child) {
                          final back = angle > math.pi / 2;
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..rotateY(back ? math.pi : 0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: back
                                          ? const [
                                              Color(0xFFE2F6EA),
                                              Color(0xFFF7FCF9)
                                            ]
                                          : const [
                                              Color(0xFFE8E7FF),
                                              Color(0xFFF8F7FF)
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight),
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(color: AppTheme.outline),
                                ),
                                padding: const EdgeInsets.all(30),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                          back
                                              ? Icons.translate_rounded
                                              : Icons.touch_app_rounded,
                                          color: AppTheme.primary,
                                          size: 30),
                                      const SizedBox(height: 24),
                                      Text(back ? item.target : item.source,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(fontSize: 38)),
                                      const SizedBox(height: 12),
                                      Text(
                                          back
                                              ? item.pronunciation
                                              : 'Tap to reveal the Spanish answer',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                  color: AppTheme.muted)),
                                      if (back) ...[
                                        const SizedBox(height: 24),
                                        Text(item.example,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge)
                                      ],
                                    ]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                        child: OutlinedButton.icon(
                            onPressed: () {
                              if (_index > 0) {
                                setState(() {
                                  _index--;
                                  _showBack = false;
                                });
                              }
                            },
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Previous'))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: FilledButton.icon(
                            onPressed: _next,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: Text(_index == _cards.length - 1
                                ? 'Restart'
                                : 'Next'))),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

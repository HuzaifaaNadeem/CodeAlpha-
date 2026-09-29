import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/sources/practice_factory.dart';
import '../../domain/entities/practice_question.dart';
import '../providers/learning_providers.dart';

class McqPracticeScreen extends ConsumerStatefulWidget {
  const McqPracticeScreen({super.key});

  @override
  ConsumerState<McqPracticeScreen> createState() => _McqPracticeScreenState();
}

class _McqPracticeScreenState extends ConsumerState<McqPracticeScreen> {
  late List<PracticeQuestion> _questions;
  var _index = 0;
  var _correct = 0;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _questions = PracticeFactory.mcqQuestions(ref.read(allItemsProvider));
    ref.read(progressControllerProvider.notifier).touchStudyDay();
  }

  Future<void> _choose(String option) async {
    if (_selected != null) {
      return;
    }
    final isCorrect = option == _questions[_index].answer;
    await HapticFeedback.selectionClick();
    await ref
        .read(progressControllerProvider.notifier)
        .recordAnswer(correct: isCorrect);
    if (!mounted) {
      return;
    }
    setState(() {
      _selected = option;
      if (isCorrect) {
        _correct++;
      }
    });
  }

  void _advance() {
    if (_index == _questions.length - 1) {
      _showResults();
      return;
    }
    setState(() {
      _index++;
      _selected = null;
    });
  }

  void _showResults() {
    final score = (_correct / _questions.length * 100).round();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isDismissible: false,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 78,
              height: 78,
              decoration: const BoxDecoration(
                  color: Color(0xFFE2F6EA), shape: BoxShape.circle),
              child: Center(
                  child: Text('$score%',
                      style: const TextStyle(
                          color: AppTheme.mintStrong,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)))),
          const SizedBox(height: 16),
          Text(score >= 75 ? 'Strong session' : 'Good practice',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text('You answered $_correct of ${_questions.length} correctly.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          FilledButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                Navigator.pop(context);
              },
              child: const Text('Done')),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
          body: Center(child: Text('Not enough content for a quiz.')));
    }
    final question = _questions[_index];
    return Scaffold(
      appBar: AppBar(title: const Text('Multiple choice')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              children: [
                Row(children: [
                  Text('Question ${_index + 1} of ${_questions.length}',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const Spacer(),
                  Text('$_correct correct',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.mintStrong,
                          fontWeight: FontWeight.w800))
                ]),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                    value: (_index + 1) / _questions.length,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(99),
                    color: AppTheme.primary,
                    backgroundColor: const Color(0xFFE9EBE5)),
                const SizedBox(height: 30),
                Text('Choose the Spanish translation',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Text(question.prompt,
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 26),
                for (final option in question.options) ...[
                  _OptionTile(
                      option: option,
                      selected: _selected == option,
                      revealed: _selected != null,
                      correct: option == question.answer,
                      onTap: () => _choose(option)),
                  const SizedBox(height: 11),
                ],
                if (_selected != null) ...[
                  const SizedBox(height: 8),
                  Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: _selected == question.answer
                              ? const Color(0xFFE2F6EA)
                              : const Color(0xFFFFE7E3),
                          borderRadius: BorderRadius.circular(18)),
                      child: Row(children: [
                        Icon(
                            _selected == question.answer
                                ? Icons.check_circle_rounded
                                : Icons.info_rounded,
                            color: _selected == question.answer
                                ? AppTheme.mintStrong
                                : AppTheme.coral),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(
                                _selected == question.answer
                                    ? 'Exactly right.'
                                    : 'Correct answer: ${question.answer}',
                                style: Theme.of(context).textTheme.bodyLarge))
                      ])),
                  const SizedBox(height: 14),
                  FilledButton(
                      onPressed: _advance,
                      child: Text(_index == _questions.length - 1
                          ? 'See results'
                          : 'Next question')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile(
      {required this.option,
      required this.selected,
      required this.revealed,
      required this.correct,
      required this.onTap});
  final String option;
  final bool selected;
  final bool revealed;
  final bool correct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color background = Colors.white;
    Color border = AppTheme.outline;
    IconData? icon;
    if (revealed && correct) {
      background = const Color(0xFFE2F6EA);
      border = AppTheme.mintStrong;
      icon = Icons.check_rounded;
    }
    if (revealed && selected && !correct) {
      background = const Color(0xFFFFE7E3);
      border = AppTheme.coral;
      icon = Icons.close_rounded;
    }
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: revealed ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border, width: 1.4)),
            child: Row(children: [
              Expanded(
                  child: Text(option,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w700))),
              if (icon != null) Icon(icon, color: border)
            ])),
      ),
    );
  }
}

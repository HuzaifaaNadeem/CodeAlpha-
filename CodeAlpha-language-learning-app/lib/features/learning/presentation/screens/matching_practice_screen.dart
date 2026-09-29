import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/sources/practice_factory.dart';
import '../../domain/entities/learning_item.dart';
import '../providers/learning_providers.dart';

class MatchingPracticeScreen extends ConsumerStatefulWidget {
  const MatchingPracticeScreen({super.key});

  @override
  ConsumerState<MatchingPracticeScreen> createState() =>
      _MatchingPracticeScreenState();
}

class _MatchingPracticeScreenState
    extends ConsumerState<MatchingPracticeScreen> {
  late List<LearningItem> _items;
  late List<LearningItem> _targets;
  final Set<String> _matched = {};
  LearningItem? _selectedSource;
  LearningItem? _selectedTarget;
  var _attempts = 0;

  @override
  void initState() {
    super.initState();
    _restart();
    ref.read(progressControllerProvider.notifier).touchStudyDay();
  }

  void _restart() {
    _items = PracticeFactory.matchingItems(ref.read(allItemsProvider));
    _targets = [..._items]..shuffle();
    _matched.clear();
    _selectedSource = null;
    _selectedTarget = null;
    _attempts = 0;
  }

  Future<void> _check() async {
    final source = _selectedSource;
    final target = _selectedTarget;
    if (source == null || target == null) {
      return;
    }

    final correct = source.id == target.id;
    _attempts++;
    await ref
        .read(progressControllerProvider.notifier)
        .recordAnswer(correct: correct);
    await HapticFeedback.selectionClick();
    if (!mounted) {
      return;
    }

    if (correct) {
      setState(() {
        _matched.add(source.id);
        _selectedSource = null;
        _selectedTarget = null;
      });
      if (_matched.length == _items.length) {
        _showComplete();
      }
    } else {
      setState(() {
        _selectedSource = null;
        _selectedTarget = null;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
            const SnackBar(content: Text('Not quite — try another pair.')));
    }
  }

  void _showComplete() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration_rounded,
                size: 48, color: AppTheme.primary),
            const SizedBox(height: 14),
            Text('Pairs complete',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text('You matched ${_items.length} pairs in $_attempts attempts.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                setState(_restart);
              },
              child: const Text('Play again'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match pairs')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              children: [
                Text('Match each English prompt with its Spanish translation.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppTheme.muted)),
                const SizedBox(height: 18),
                Row(children: [
                  Expanded(
                      child: Text('ENGLISH',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text('SPANISH',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8)))
                ]),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          for (final item in _items) ...[
                            _MatchTile(
                                text: item.source,
                                matched: _matched.contains(item.id),
                                selected: _selectedSource?.id == item.id,
                                onTap: _matched.contains(item.id)
                                    ? null
                                    : () {
                                        setState(() => _selectedSource = item);
                                        _check();
                                      }),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          for (final item in _targets) ...[
                            _MatchTile(
                                text: item.target,
                                matched: _matched.contains(item.id),
                                selected: _selectedTarget?.id == item.id,
                                onTap: _matched.contains(item.id)
                                    ? null
                                    : () {
                                        setState(() => _selectedTarget = item);
                                        _check();
                                      }),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile(
      {required this.text,
      required this.matched,
      required this.selected,
      required this.onTap});
  final String text;
  final bool matched;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: matched
          ? const Color(0xFFE2F6EA)
          : selected
              ? const Color(0xFFE8E7FF)
              : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: matched
                    ? AppTheme.mintStrong
                    : selected
                        ? AppTheme.primary
                        : AppTheme.outline,
                width: 1.4),
          ),
          child: Text(text,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.ink, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

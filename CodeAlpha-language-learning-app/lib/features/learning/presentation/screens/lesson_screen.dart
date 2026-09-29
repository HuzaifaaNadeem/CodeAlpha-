import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/sources/starter_course.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/learning_item.dart';
import '../providers/learning_providers.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  final _pageController = PageController();
  var _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    await ref
        .read(progressControllerProvider.notifier)
        .completeLesson(widget.lesson.id);
    if (!mounted) {
      return;
    }
    await HapticFeedback.mediumImpact();
    if (!mounted) {
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                    color: Color(0xFFE2F6EA), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded,
                    color: AppTheme.mintStrong, size: 36)),
            const SizedBox(height: 16),
            Text('Lesson complete',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text('Nice work. A short practice session will help lock it in.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            FilledButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  Navigator.pop(context);
                },
                child: const Text('Continue')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: LinearProgressIndicator(
            value: (_index + 1) / lesson.items.length,
            minHeight: 5,
            color: AppTheme.primary,
            backgroundColor: const Color(0xFFE9EBE5),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Row(children: [
                Text('Card ${_index + 1} of ${lesson.items.length}',
                    style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                Text(lesson.emoji, style: const TextStyle(fontSize: 24))
              ]),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) => setState(() => _index = value),
                itemCount: lesson.items.length,
                itemBuilder: (context, index) => _LessonItemCard(
                    item: lesson.items[index],
                    color: StarterCourse.lessonColor(lesson)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  IconButton.filledTonal(
                      onPressed: _index == 0
                          ? null
                          : () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut),
                      icon: const Icon(Icons.arrow_back_rounded)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _index == lesson.items.length - 1
                          ? _complete
                          : () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut),
                      child: Text(_index == lesson.items.length - 1
                          ? 'Complete lesson'
                          : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonItemCard extends ConsumerWidget {
  const _LessonItemCard({required this.item, required this.color});
  final LearningItem item;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorite = ref.watch(progressControllerProvider).maybeWhen(
        data: (state) => state.favoriteItemIds.contains(item.id),
        orElse: () => false);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.outline)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                        color: color, borderRadius: BorderRadius.circular(99)),
                    child: Text(
                        item.kind == LearningItemKind.phrase
                            ? 'PHRASE'
                            : 'VOCABULARY',
                        style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.9))),
                const SizedBox(height: 28),
                Text(item.target,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontSize: 38)),
                const SizedBox(height: 8),
                Text(item.pronunciation,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primary, fontWeight: FontWeight.w800)),
                const SizedBox(height: 18),
                Text(item.source,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 28),
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F1),
                        borderRadius: BorderRadius.circular(18)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('IN CONTEXT',
                              style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.muted,
                                  letterSpacing: 0.8)),
                          const SizedBox(height: 6),
                          Text(item.example,
                              style: Theme.of(context).textTheme.bodyLarge)
                        ])),
                const SizedBox(height: 22),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Pronunciation cue shown above. Audio can be added later.')));
                      },
                      icon: const Icon(Icons.volume_up_outlined),
                      label: const Text('Pronounce')),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                      onPressed: () => ref
                          .read(progressControllerProvider.notifier)
                          .toggleFavorite(item.id),
                      icon: Icon(
                          favorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: favorite ? AppTheme.coral : null)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

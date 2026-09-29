import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/sources/starter_course.dart';
import '../providers/learning_providers.dart';
import 'lesson_screen.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(lessonsProvider);
    final progress = ref.watch(progressControllerProvider);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
            children: [
              Text('Learn', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 7),
              Text('Five short lessons. Useful language first.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppTheme.muted)),
              const SizedBox(height: 24),
              for (var i = 0; i < lessons.length; i++) ...[
                _LessonTile(
                  index: i + 1,
                  title: lessons[i].title,
                  subtitle: lessons[i].subtitle,
                  emoji: lessons[i].emoji,
                  color: StarterCourse.lessonColor(lessons[i]),
                  completed: progress.maybeWhen(
                      data: (state) =>
                          state.completedLessonIds.contains(lessons[i].id),
                      orElse: () => false),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (_) => LessonScreen(lesson: lessons[i]))),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile(
      {required this.index,
      required this.title,
      required this.subtitle,
      required this.emoji,
      required this.color,
      required this.completed,
      required this.onTap});
  final int index;
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final bool completed;
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
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.outline)),
          child: Row(
            children: [
              Container(
                  width: 62,
                  height: 62,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(19)),
                  child: Text(emoji, style: const TextStyle(fontSize: 30))),
              const SizedBox(width: 15),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('LESSON $index',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 10.5,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8)),
                    const SizedBox(height: 4),
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyMedium)
                  ])),
              Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: completed
                          ? const Color(0xFFE2F6EA)
                          : const Color(0xFFF1F2EE),
                      shape: BoxShape.circle),
                  child: Icon(
                      completed
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      color: completed ? AppTheme.mintStrong : AppTheme.ink,
                      size: 19)),
            ],
          ),
        ),
      ),
    );
  }
}

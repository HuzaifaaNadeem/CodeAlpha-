import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/sources/starter_course.dart';
import '../../domain/entities/progress_state.dart';
import '../providers/learning_providers.dart';
import '../widgets/brand_header.dart';
import 'lesson_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressControllerProvider);
    final lessons = ref.watch(lessonsProvider);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              const BrandHeader(),
              const SizedBox(height: 30),
              Text('Hola! Ready for\na small win today?',
                  style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 10),
              Text(
                'A focused Spanish course built around useful words, phrases, and short practice sessions.',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppTheme.muted),
              ),
              const SizedBox(height: 24),
              progress.when(
                loading: () => const _ProgressSkeleton(),
                error: (error, _) => Text('Could not load progress: $error'),
                data: (state) => _ProgressHero(
                    progress: state, totalLessons: lessons.length),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Text('Continue learning',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  Text('${lessons.length} lessons',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 12),
              progress.maybeWhen(
                data: (state) {
                  final lesson = lessons.firstWhere(
                    (lesson) => !state.completedLessonIds.contains(lesson.id),
                    orElse: () => lessons.first,
                  );
                  return _ContinueCard(
                    lessonTitle: lesson.title,
                    subtitle: lesson.subtitle,
                    emoji: lesson.emoji,
                    color: StarterCourse.lessonColor(lesson),
                    completed: state.completedLessonIds.contains(lesson.id),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (_) => LessonScreen(lesson: lesson)),
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: 26),
              Text('Today’s focus',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                      child: _FocusCard(
                          icon: Icons.style_rounded,
                          title: 'Flashcards',
                          caption: 'Quick recall',
                          color: Color(0xFFE8E7FF))),
                  SizedBox(width: 12),
                  Expanded(
                      child: _FocusCard(
                          icon: Icons.quiz_rounded,
                          title: 'MCQ quiz',
                          caption: 'Check yourself',
                          color: Color(0xFFE2F6EA))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({required this.progress, required this.totalLessons});

  final ProgressState progress;
  final int totalLessons;

  @override
  Widget build(BuildContext context) {
    final ratio = totalLessons == 0
        ? 0.0
        : progress.completedLessonIds.length / totalLessons;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.ink,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            height: 82,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  color: AppTheme.yellow,
                  backgroundColor: Colors.white12,
                ),
                Text('${(ratio * 100).round()}%',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Spanish journey',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                    '${progress.completedLessonIds.length} of $totalLessons lessons completed',
                    style:
                        const TextStyle(color: Colors.white70, height: 1.35)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _DarkPill(
                        icon: Icons.local_fire_department_rounded,
                        text: '${progress.currentStreak} day streak'),
                    _DarkPill(
                        icon: Icons.favorite_rounded,
                        text: '${progress.favoriteItemIds.length} saved'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkPill extends StatelessWidget {
  const _DarkPill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
          color: Colors.white10, borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: AppTheme.yellow, size: 15),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w700))
      ]),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard(
      {required this.lessonTitle,
      required this.subtitle,
      required this.emoji,
      required this.color,
      required this.completed,
      required this.onTap});
  final String lessonTitle;
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
              border: Border.all(color: AppTheme.outline),
              borderRadius: BorderRadius.circular(24)),
          child: Row(
            children: [
              Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(18)),
                  child: Text(emoji, style: const TextStyle(fontSize: 28))),
              const SizedBox(width: 15),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(lessonTitle,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyMedium)
                  ])),
              Icon(
                  completed
                      ? Icons.replay_rounded
                      : Icons.arrow_forward_rounded,
                  color: AppTheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard(
      {required this.icon,
      required this.title,
      required this.caption,
      required this.color});
  final IconData icon;
  final String title;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(22)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppTheme.ink),
        const SizedBox(height: 20),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 3),
        Text(caption,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12))
      ]),
    );
  }
}

class _ProgressSkeleton extends StatelessWidget {
  const _ProgressSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 140,
        decoration: BoxDecoration(
            color: const Color(0xFFECEFEA),
            borderRadius: BorderRadius.circular(28)));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/sources/starter_course.dart';
import '../../domain/entities/learning_item.dart';
import '../providers/learning_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressControllerProvider);
    final items = ref.watch(allItemsProvider);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
            children: [
              Text('Profile', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 7),
              Text('Your learning progress stays offline on this device.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppTheme.muted)),
              const SizedBox(height: 24),
              progress.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text('$error'),
                data: (state) {
                  final favorites = items
                      .where((item) => state.favoriteItemIds.contains(item.id))
                      .toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                            color: AppTheme.ink,
                            borderRadius: BorderRadius.circular(28)),
                        child: Column(children: [
                          Row(children: [
                            Container(
                                width: 52,
                                height: 52,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    color: Colors.white12,
                                    shape: BoxShape.circle),
                                child: const Text('ES',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800))),
                            const SizedBox(width: 14),
                            const Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text('Spanish · Beginner',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800)),
                                  SizedBox(height: 3),
                                  Text('Offline starter course',
                                      style: TextStyle(
                                          color: Colors.white60, fontSize: 12))
                                ]))
                          ]),
                          const SizedBox(height: 20),
                          Row(children: [
                            Expanded(
                                child: _Stat(
                                    value: '${state.currentStreak}',
                                    label: 'Day streak')),
                            Expanded(
                                child: _Stat(
                                    value:
                                        '${state.completedLessonIds.length}/${StarterCourse.lessons.length}',
                                    label: 'Lessons')),
                            Expanded(
                                child: _Stat(
                                    value: '${(state.accuracy * 100).round()}%',
                                    label: 'Accuracy'))
                          ]),
                        ]),
                      ),
                      const SizedBox(height: 26),
                      Row(children: [
                        Text('Saved words & phrases',
                            style: Theme.of(context).textTheme.titleLarge),
                        const Spacer(),
                        Text('${favorites.length}',
                            style: Theme.of(context).textTheme.bodyMedium)
                      ]),
                      const SizedBox(height: 12),
                      if (favorites.isEmpty)
                        const _EmptyFavorites()
                      else
                        for (final item in favorites.take(8)) ...[
                          _FavoriteTile(
                              item: item,
                              onRemove: () => ref
                                  .read(progressControllerProvider.notifier)
                                  .toggleFavorite(item.id)),
                          const SizedBox(height: 10),
                        ],
                      const SizedBox(height: 26),
                      Text('Course settings',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Material(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                          side: const BorderSide(color: AppTheme.outline),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(children: [
                          const ListTile(
                              leading: Icon(Icons.language_rounded),
                              title: Text('Learning language'),
                              subtitle: Text('Spanish'),
                              trailing: Text('ES',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primary))),
                          const Divider(height: 1),
                          ListTile(
                              leading: const Icon(Icons.restart_alt_rounded),
                              title: const Text('Reset learning progress'),
                              subtitle: const Text(
                                  'Clears lessons, favorites, streak and quiz stats'),
                              onTap: () => _confirmReset(context, ref)),
                        ]),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final reset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text(
            'This clears local lesson completion, favorites, streak, and quiz statistics.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Reset'))
        ],
      ),
    );
    if (reset == true) {
      await ref.read(progressControllerProvider.notifier).reset();
    }
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 3),
      Text(label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white60, fontSize: 10.5))
    ]);
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({required this.item, required this.onRemove});
  final LearningItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.outline)),
      child: Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.target, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(item.source, style: Theme.of(context).textTheme.bodyMedium)
        ])),
        IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.favorite_rounded, color: AppTheme.coral))
      ]),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            color: const Color(0xFFF0F1ED),
            borderRadius: BorderRadius.circular(20)),
        child: Column(children: [
          const Icon(Icons.favorite_border_rounded, color: AppTheme.muted),
          const SizedBox(height: 8),
          Text('Save useful words during lessons.',
              style: Theme.of(context).textTheme.bodyMedium)
        ]));
  }
}

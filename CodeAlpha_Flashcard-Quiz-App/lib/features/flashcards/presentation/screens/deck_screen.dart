import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../domain/entities/deck.dart';
import '../../domain/entities/flashcard.dart';
import '../providers/flashcard_providers.dart';
import '../widgets/empty_state.dart';
import 'add_edit_flashcard_screen.dart';
import 'mcq_quiz_screen.dart';
import 'quiz_screen.dart';
import 'study_screen.dart';

class DeckScreen extends ConsumerWidget {
  const DeckScreen({super.key, required this.deck});

  final Deck deck;

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    Flashcard? card,
  }) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditFlashcardScreen(deckId: deck.id, card: card),
      ),
    );
    ref.invalidate(cardsProvider(deck.id));
  }

  Future<void> _deleteCard(
    BuildContext context,
    WidgetRef ref,
    Flashcard card,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.red),
        title: const Text('Delete flashcard?'),
        content: const Text(
          'This question and answer will be permanently removed.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(flashcardRepositoryProvider).deleteCard(card.id);
    ref.invalidate(cardsProvider(deck.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardsProvider(deck.id));
    final stats = ref.watch(statsProvider(deck.id));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.title),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE8E9F0)),
            ),
            child: IconButton(
              tooltip: 'Add card',
              onPressed: () => _openEditor(context, ref),
              icon: const Icon(Icons.add_rounded),
            ),
          ),
        ],
      ),
      body: cards.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            LoadingSkeleton(height: 220, borderRadius: 28),
            SizedBox(height: 24),
            LoadingSkeleton(height: 112),
            SizedBox(height: 12),
            LoadingSkeleton(height: 112),
          ],
        ),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.style_rounded,
              title: 'Your deck is ready',
              message:
                  'Add a few question-and-answer cards, then jump into Study or Quiz mode.',
              actionLabel: 'Add first flashcard',
              onAction: () => _openEditor(context, ref),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              _DeckHero(
                deck: deck,
                cards: items,
                lastAccuracy: stats.maybeWhen(
                  data: (values) =>
                      values.isEmpty ? null : values.first.accuracy,
                  orElse: () => null,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Text('Flashcards', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  Text(
                    '${items.length} cards',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              for (var index = 0; index < items.length; index++) ...[
                _FlashcardListTile(
                  card: items[index],
                  index: index,
                  onEdit: () => _openEditor(context, ref, card: items[index]),
                  onDelete: () => _deleteCard(context, ref, items[index]),
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add card'),
      ),
    );
  }
}

class _DeckHero extends StatelessWidget {
  const _DeckHero({
    required this.deck,
    required this.cards,
    required this.lastAccuracy,
  });

  final Deck deck;
  final List<Flashcard> cards;
  final double? lastAccuracy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F2FF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.auto_stories_rounded,
                    color: AppTheme.blue),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Study this deck', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      '${cards.length} cards • ${lastAccuracy == null ? 'No quiz yet' : '${(lastAccuracy! * 100).round()}% last score'}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Choose a learning mode',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _StudyModeButton(
            title: 'Study cards',
            subtitle: 'Flip through cards at your own pace',
            icon: Icons.style_rounded,
            background: Colors.white,
            foreground: AppTheme.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudyScreen(deck: deck, cards: cards),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _StudyModeButton(
            title: 'Self assessment',
            subtitle: 'Reveal answers and mark what you remembered',
            icon: Icons.psychology_alt_rounded,
            background: const Color(0xFFE8F3FF),
            foreground: AppTheme.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizScreen(deck: deck, cards: cards),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _StudyModeButton(
            title: 'MCQ quiz',
            subtitle: 'Pick from 4 choices and get instant feedback',
            icon: Icons.quiz_rounded,
            background: const Color(0xFFFFF1CB),
            foreground: AppTheme.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => McqQuizScreen(deck: deck),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyModeButton extends StatelessWidget {
  const _StudyModeButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: foreground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: foreground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlashcardListTile extends StatelessWidget {
  const _FlashcardListTile({
    required this.card,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  final Flashcard card;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppTheme.deckAccents[index % AppTheme.deckAccents.length];
    final tint = AppTheme.deckColors[index % AppTheme.deckColors.length];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9EAF1)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 54,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: theme.textTheme.titleMedium?.copyWith(color: accent),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: tint,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        card.category,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: accent,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        card.answer,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 10),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: AppTheme.red),
                    SizedBox(width: 10),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../domain/entities/deck.dart';
import '../providers/flashcard_providers.dart';
import 'deck_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _createDeck(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();

    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create a new deck'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Deck name',
            hintText: 'e.g. Computer Architecture',
            prefixIcon: Icon(Icons.collections_bookmark_rounded),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.pop(context, value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(context, value);
            },
            child: const Text('Create deck'),
          ),
        ],
      ),
    );

    controller.dispose();
    if (title == null) return;

    await ref.read(flashcardRepositoryProvider).createDeck(title);
    ref.invalidate(decksProvider);
  }

  Future<void> _deleteDeck(
    BuildContext context,
    WidgetRef ref,
    Deck deck,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.red),
        title: const Text('Delete this deck?'),
        content: Text(
          '“${deck.title}” and all of its flashcards and quiz history will be removed.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep deck'),
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
    await ref.read(flashcardRepositoryProvider).deleteDeck(deck.id);
    ref.invalidate(decksProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decks = ref.watch(decksProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.purple,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.style_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 11),
            const Text('Fliply'),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8E9F0)),
            ),
            child: IconButton(
              tooltip: 'Create deck',
              onPressed: () => _createDeck(context, ref),
              icon: const Icon(Icons.add_rounded),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(decksProvider.future).then<void>((_) {}),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
            children: [
              _WelcomeHero(
                deckCount: decks.maybeWhen(
                  data: (items) => items.length,
                  orElse: () => 0,
                ),
                onCreate: () => _createDeck(context, ref),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Text('My decks', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  decks.maybeWhen(
                    data: (items) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '${items.length} total',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              decks.when(
                loading: () => const Column(
                  children: [
                    LoadingSkeleton(height: 150, borderRadius: 26),
                    SizedBox(height: 14),
                    LoadingSkeleton(height: 150, borderRadius: 26),
                    SizedBox(height: 14),
                    LoadingSkeleton(height: 150, borderRadius: 26),
                  ],
                ),
                error: (error, _) => _ErrorCard(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(decksProvider),
                ),
                data: (items) => Column(
                  children: [
                    for (var index = 0; index < items.length; index++) ...[
                      _DeckCard(
                        deck: items[index],
                        colorIndex: index,
                        onDelete: () => _deleteDeck(context, ref, items[index]),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createDeck(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New deck'),
      ),
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({
    required this.deckCount,
    required this.onCreate,
  });

  final int deckCount;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  '✨ READY TO LEARN',
                  style: TextStyle(
                    color: AppTheme.purple,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Make studying\nfeel easy.',
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 10),
              Text(
                deckCount == 0
                    ? 'Create your first colorful deck and start flipping.'
                    : '$deckCount ${deckCount == 1 ? 'deck' : 'decks'} ready for quick study and quiz sessions.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF625F76),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: compact ? double.infinity : 180,
                child: FilledButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create deck'),
                ),
              ),
            ],
          );

          final illustration = SizedBox(
            width: 154,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 20,
                  left: 20,
                  child: Transform.rotate(
                    angle: -0.16,
                    child: _MiniCard(
                      color: AppTheme.yellow,
                      icon: Icons.lightbulb_rounded,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 14,
                  child: Transform.rotate(
                    angle: 0.13,
                    child: _MiniCard(
                      color: const Color(0xFFE4F2FF),
                      icon: Icons.quiz_rounded,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  left: 42,
                  child: _MiniCard(
                    color: Colors.white,
                    icon: Icons.style_rounded,
                    large: true,
                  ),
                ),
              ],
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text,
                const SizedBox(height: 18),
                Align(alignment: Alignment.centerRight, child: illustration),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: text),
              const SizedBox(width: 18),
              illustration,
            ],
          );
        },
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.color,
    required this.icon,
    this.large = false,
  });

  final Color color;
  final IconData icon;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: large ? 88 : 76,
      height: large ? 98 : 86,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ink.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: AppTheme.purple, size: large ? 34 : 29),
    );
  }
}

class _DeckCard extends ConsumerWidget {
  const _DeckCard({
    required this.deck,
    required this.colorIndex,
    required this.onDelete,
  });

  final Deck deck;
  final int colorIndex;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardsProvider(deck.id));
    final stats = ref.watch(statsProvider(deck.id));
    final theme = Theme.of(context);
    final background =
        AppTheme.deckColors[colorIndex % AppTheme.deckColors.length];
    final accent =
        AppTheme.deckAccents[colorIndex % AppTheme.deckAccents.length];

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DeckScreen(deck: deck)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.style_rounded, color: accent, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deck.title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoPill(
                          icon: Icons.layers_rounded,
                          text: cards.maybeWhen(
                            data: (items) => '${items.length} cards',
                            orElse: () => 'Loading…',
                          ),
                        ),
                        _InfoPill(
                          icon: Icons.auto_graph_rounded,
                          text: stats.maybeWhen(
                            data: (items) => items.isEmpty
                                ? 'No score yet'
                                : '${(items.first.accuracy * 100).round()}% last quiz',
                            orElse: () => 'Stats…',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Deck options',
                icon: const Icon(Icons.more_horiz_rounded),
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, color: AppTheme.red),
                        SizedBox(width: 10),
                        Text('Delete deck'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppTheme.mutedInk),
          const SizedBox(width: 5),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12.5,
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.errorLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppTheme.red, size: 34),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/flashcard.dart';
import '../providers/flashcard_providers.dart';

class AddEditFlashcardScreen extends ConsumerStatefulWidget {
  const AddEditFlashcardScreen({
    super.key,
    required this.deckId,
    this.card,
  });

  final String deckId;
  final Flashcard? card;

  @override
  ConsumerState<AddEditFlashcardScreen> createState() =>
      _AddEditFlashcardScreenState();
}

class _AddEditFlashcardScreenState
    extends ConsumerState<AddEditFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionController;
  late final TextEditingController _answerController;
  late final TextEditingController _categoryController;
  bool _saving = false;

  bool get _editing => widget.card != null;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.card?.question);
    _answerController = TextEditingController(text: widget.card?.answer);
    _categoryController = TextEditingController(
      text: widget.card?.category ?? 'General',
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);

    final repository = ref.read(flashcardRepositoryProvider);
    if (_editing) {
      final updated = widget.card!.copyWith(
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
        category: _categoryController.text.trim(),
        updatedAt: DateTime.now(),
      );
      await repository.updateCard(updated);
    } else {
      await repository.createCard(
        deckId: widget.deckId,
        question: _questionController.text,
        answer: _answerController.text,
        category: _categoryController.text,
      );
    }

    ref.invalidate(cardsProvider(widget.deckId));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar:
          AppBar(title: Text(_editing ? 'Edit flashcard' : 'New flashcard')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1CB),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.lightbulb_rounded,
                            color: AppTheme.orange,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _editing
                                    ? 'Polish this card'
                                    : 'Make it easy to remember',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'One focused question + one clear answer works best.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Question', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _questionController,
                    minLines: 3,
                    maxLines: 6,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'What do you want to remember?',
                      prefixIcon: Icon(Icons.help_outline_rounded),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Question is required'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  Text('Answer', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _answerController,
                    minLines: 3,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      hintText: 'Write the answer clearly and concisely.',
                      prefixIcon: Icon(Icons.lightbulb_outline_rounded),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Answer is required'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  Text('Category', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _categoryController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Formulas, Definitions, Chapter 1',
                      prefixIcon: Icon(Icons.sell_outlined),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            _editing ? Icons.check_rounded : Icons.add_rounded),
                    label: Text(_editing ? 'Save changes' : 'Add flashcard'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

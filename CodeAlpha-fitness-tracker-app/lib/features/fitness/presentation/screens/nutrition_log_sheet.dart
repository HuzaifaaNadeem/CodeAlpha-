import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/fitness_controller.dart';

class NutritionLogSheet extends ConsumerStatefulWidget {
  const NutritionLogSheet({super.key});

  @override
  ConsumerState<NutritionLogSheet> createState() => _NutritionLogSheetState();
}

class _NutritionLogSheetState extends ConsumerState<NutritionLogSheet> {
  final _calories = TextEditingController(text: '450');
  final _protein = TextEditingController(text: '30');
  final _carbs = TextEditingController(text: '50');
  final _fat = TextEditingController(text: '15');

  @override
  void dispose() {
    _calories.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.canvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.outline,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Log nutrition',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 5),
              Text(
                'Add a meal or snack to today’s macro totals.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _calories,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                  prefixIcon: Icon(Icons.local_fire_department_rounded),
                  suffixText: 'kcal',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _protein,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Protein', suffixText: 'g'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _carbs,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Carbs', suffixText: 'g'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _fat,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Fat', suffixText: 'g'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () async {
                  await ref
                      .read(fitnessControllerProvider.notifier)
                      .logNutrition(
                        calories: int.tryParse(_calories.text) ?? 0,
                        protein: int.tryParse(_protein.text) ?? 0,
                        carbs: int.tryParse(_carbs.text) ?? 0,
                        fat: int.tryParse(_fat.text) ?? 0,
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.check_rounded),
                label: const Text('Add to today'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/daily_record.dart';

class WeekBarChart extends StatelessWidget {
  const WeekBarChart({
    super.key,
    required this.records,
    required this.goal,
    required this.valueOf,
    required this.labelForValue,
  });

  final List<DailyRecord> records;
  final int goal;
  final int Function(DailyRecord record) valueOf;
  final String Function(int value) labelForValue;

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    var maxValue = goal;
    for (final record in records) {
      final value = valueOf(record);
      if (value > maxValue) {
        maxValue = value;
      }
    }
    if (maxValue <= 0) {
      maxValue = 1;
    }

    return SizedBox(
      height: 190,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(records.length, (index) {
          final record = records[index];
          final value = valueOf(record);
          final factor = value / maxValue;
          final reached = value >= goal;
          final labelIndex = record.date.weekday - 1;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  labelForValue(value),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: factor.clamp(0.08, 1.0).toDouble(),
                      widthFactor: 0.5,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 420 + index * 60),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: reached ? AppTheme.primary : AppTheme.mint,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  _days[labelIndex],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: index == records.length - 1
                            ? AppTheme.ink
                            : AppTheme.muted,
                      ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

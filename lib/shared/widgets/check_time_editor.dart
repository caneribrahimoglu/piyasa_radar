import 'package:flutter/material.dart';
import 'package:piyasa_radar/core/constants/default_check_times.dart';
import 'package:piyasa_radar/core/theme/app_spacing.dart';
import 'package:piyasa_radar/shared/widgets/app_button.dart';

class CheckTimeEditor extends StatelessWidget {
  const CheckTimeEditor({
    required this.times,
    required this.onChanged,
    this.errorText,
    this.initialPickerTime,
    super.key,
  });

  final List<String> times;
  final ValueChanged<List<String>> onChanged;
  final String? errorText;
  final TimeOfDay? initialPickerTime;

  Future<void> _addTime(BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialPickerTime ?? TimeOfDay.now(),
    );
    if (selectedTime == null) return;

    final nextTimes = normalizeCheckTimes([
      ...times,
      formatCheckTime(selectedTime.hour, selectedTime.minute),
    ]);
    onChanged(nextTimes);
  }

  void _removeTime(String time) {
    onChanged(normalizeCheckTimes(times.where((value) => value != time)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kontrol saatleri',
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final time in times)
              InputChip(
                label: Text(time),
                deleteIcon: const Icon(Icons.cancel),
                onDeleted: () => _removeTime(time),
              ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Kontrol saati ekle',
          icon: Icons.schedule_outlined,
          onPressed: () => _addTime(context),
        ),
      ],
    );
  }
}

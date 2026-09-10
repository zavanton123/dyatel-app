import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../utils/number_format.dart';

/// A grouped-digit field ("100,000") with its own compact stepper.
class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<int> onChanged;

  void _step(int delta) {
    final current = parseGrouped(controller.text) ?? 0;
    final next = current + delta;
    controller.text = formatGrouped(next);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadius.field),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,\-]')),
                  ],
                  style: const TextStyle(
                    fontSize: 20,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    final parsed = parseGrouped(value);
                    if (parsed != null) onChanged(parsed);
                  },
                  onEditingComplete: () {
                    final parsed = parseGrouped(controller.text);
                    if (parsed != null) controller.text = formatGrouped(parsed);
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StepButton(
                      icon: Icons.keyboard_arrow_up_rounded,
                      onTap: () => _step(1),
                      semanticLabel: 'Increase $label',
                    ),
                    _StepButton(
                      icon: Icons.keyboard_arrow_down_rounded,
                      onTap: () => _step(-1),
                      semanticLabel: 'Decrease $label',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkResponse(
        onTap: onTap,
        radius: 16,
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}

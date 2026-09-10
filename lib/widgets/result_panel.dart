import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/number_format.dart';

/// Shows the generated number: an empty prompt, a blurred value, or the value.
class ResultPanel extends StatelessWidget {
  const ResultPanel({
    super.key,
    required this.value,
    required this.hidden,
    required this.onReveal,
  });

  final int? value;
  final bool hidden;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: value == null
          ? const _EmptyState()
          : _Value(value: value!, hidden: hidden, onReveal: onReveal),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.casino_outlined, size: 72, color: AppColors.textMuted),
          SizedBox(height: 18),
          Text(
            'Ready when you are',
            style: TextStyle(fontSize: 19, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value({
    required this.value,
    required this.hidden,
    required this.onReveal,
  });

  final int value;
  final bool hidden;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    final number = FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          formatGrouped(value),
          style: const TextStyle(
            fontSize: 76,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.05,
          ),
        ),
      ),
    );

    if (!hidden) {
      return Center(child: number);
    }

    // Tapping the blur reveals, matching the caption underneath.
    return InkWell(
      onTap: onReveal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: number,
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(bottom: 22),
            child: Text(
              'Listen before you reveal',
              style: TextStyle(fontSize: 17, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

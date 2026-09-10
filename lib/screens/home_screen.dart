import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/language.dart';
import '../services/settings_service.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart';
import '../utils/number_format.dart';
import '../widgets/language_sheet.dart';
import '../widgets/number_field.dart';
import '../widgets/result_panel.dart';
import '../widgets/section_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _settings = SettingsService();
  final _speech = SpeechService();
  final _random = Random();

  final _fromController = TextEditingController(text: '0');
  final _toController = TextEditingController(text: '100,000');

  int _from = 0;
  int _to = 100000;
  String _language = kDefaultLanguage;
  bool _hideNumber = false;
  bool _speaking = false;

  int? _value;
  bool _revealed = true;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _speech.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    final language = await _settings.loadLanguage();
    final hide = await _settings.loadHideNumber();
    final range = await _settings.loadRange();
    if (!mounted) return;

    setState(() {
      _language = language;
      _hideNumber = hide;
      _from = range.from;
      _to = range.to;
      _fromController.text = formatGrouped(range.from);
      _toController.text = formatGrouped(range.to);
    });
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.surfaceAlt,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _generate() {
    FocusScope.of(context).unfocus();

    if (_from > _to) {
      _notify('"From" must not be greater than "To".');
      return;
    }

    setState(() {
      _value = _from + _random.nextInt(_to - _from + 1);
      _revealed = !_hideNumber;
    });
    _settings.saveRange(_from, _to);
  }

  Future<void> _listen() async {
    final value = _value;
    if (value == null || _speaking) return;

    setState(() => _speaking = true);
    try {
      // Google reads a bare numeral as words in the target language.
      final engine = await _speech.speak('$value', _language);
      if (engine == SpeechEngine.system) {
        _notify('Google voice unavailable — used the device voice.');
      }
    } on SpeechException catch (error) {
      _notify(error.message);
    } finally {
      if (mounted) setState(() => _speaking = false);
    }
  }

  Future<void> _pickLanguage() async {
    // Silencing playback is incidental; never make the picker wait on it.
    unawaited(_speech.stop());

    final picked = await LanguageSheet.show(context, _language);
    if (picked == null || !mounted) return;

    setState(() => _language = picked);
    _settings.saveLanguage(picked);
  }

  void _setHideNumber(bool value) {
    setState(() {
      _hideNumber = value;
      if (_value != null) _revealed = !value;
    });
    _settings.saveHideNumber(value);
  }

  @override
  Widget build(BuildContext context) {
    final hidden = _value != null && !_revealed;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Header(),
                    const SizedBox(height: 24),
                    _rangeCard(),
                    const SizedBox(height: 14),
                    OptionRow(
                      icon: Icons.language_rounded,
                      title: 'Language',
                      subtitle: languageForCode(_language).label,
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                      ),
                      onTap: _pickLanguage,
                    ),
                    const SizedBox(height: 14),
                    OptionRow(
                      icon: Icons.visibility_off_outlined,
                      title: 'Hide number',
                      subtitle: 'Blur the result after generating',
                      trailing: Switch(
                        value: _hideNumber,
                        onChanged: _setHideNumber,
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ResultPanel(
                      value: _value,
                      hidden: hidden,
                      onReveal: () => setState(() => _revealed = true),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: _actions(hidden: hidden),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rangeCard() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NUMBER RANGE',
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: NumberField(
                  label: 'From',
                  controller: _fromController,
                  onChanged: (value) => _from = value,
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 14),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: NumberField(
                  label: 'To',
                  controller: _toController,
                  onChanged: (value) => _to = value,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// The action bar changes with the state: generate, then listen-and-reveal
  /// while hidden, then generate-again once the answer is on screen.
  Widget _actions({required bool hidden}) {
    if (_value == null) {
      return _PrimaryButton(
        icon: Icons.casino_outlined,
        label: 'Generate number',
        onPressed: _generate,
      );
    }

    if (hidden) {
      return Row(
        children: [
          Expanded(
            child: _PrimaryButton(
              icon: Icons.volume_up_rounded,
              label: 'Listen',
              busy: _speaking,
              onPressed: _listen,
            ),
          ),
          const SizedBox(width: 12),
          _SecondaryButton(
            icon: Icons.visibility_outlined,
            label: 'Reveal',
            onPressed: () => setState(() => _revealed = true),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _PrimaryButton(
            icon: Icons.casino_outlined,
            label: 'Generate new',
            onPressed: _generate,
          ),
        ),
        const SizedBox(width: 12),
        _SecondaryButton(
          icon: Icons.volume_up_rounded,
          label: 'Listen',
          busy: _speaking,
          onPressed: _listen,
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.casino_rounded, size: 54, color: AppColors.dice),
        const SizedBox(width: 16),
        // Flexible so the wordmark never overflows on a narrow phone.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Random Number',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Train your number listening',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white70,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
        icon: busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 26),
        label: Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: OutlinedButton.icon(
        onPressed: busy ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

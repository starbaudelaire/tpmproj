import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';

class CurrencyConverterView extends ConsumerStatefulWidget {
  const CurrencyConverterView({
    required this.rates,
    super.key,
  });

  final Map<String, double> rates;

  @override
  ConsumerState<CurrencyConverterView> createState() =>
      _CurrencyConverterViewState();
}

class _CurrencyConverterViewState extends ConsumerState<CurrencyConverterView> {
  final _controller = TextEditingController(text: '1');

  String from = 'USD';
  String to = 'IDR';

  static const _currencies = ['USD', 'IDR', 'EUR'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cycleFrom() {
    HapticFeedback.selectionClick();

    setState(() {
      final current = _currencies.indexOf(from);
      from = _currencies[(current + 1) % _currencies.length];

      if (from == to) {
        final next = _currencies.indexOf(to);
        to = _currencies[(next + 1) % _currencies.length];
      }
    });
  }

  void _cycleTo() {
    HapticFeedback.selectionClick();

    setState(() {
      final current = _currencies.indexOf(to);
      to = _currencies[(current + 1) % _currencies.length];

      if (to == from) {
        to = _currencies[(current + 2) % _currencies.length];
      }
    });
  }

  void _swap() {
    HapticFeedback.selectionClick();

    setState(() {
      final previous = from;
      from = to;
      to = previous;
    });
  }

  double get _input {
    return double.tryParse(_controller.text.replaceAll(',', '.')) ?? 0;
  }

  double get _result {
    final fromRate = widget.rates[from] ?? 1;
    final toRate = widget.rates[to] ?? 1;

    if (fromRate == 0) return 0;

    return _input / fromRate * toRate;
  }

  String _symbol(String code) {
    return switch (code) {
      'USD' => '\$',
      'IDR' => 'Rp',
      'EUR' => '€',
      _ => code,
    };
  }

  String _name(String code) {
    return switch (code) {
      'USD' => 'US Dollar',
      'IDR' => 'Indonesian Rupiah',
      'EUR' => 'Euro',
      _ => code,
    };
  }

  String _format(double value) {
    if (value >= 1000) return value.toStringAsFixed(0);
    if (value >= 1) return value.toStringAsFixed(2);
    return value.toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context) {
    final rateText =
        '1 $from ≈ ${_format((widget.rates[to] ?? 1) / (widget.rates[from] ?? 1))} $to';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          blur: 34,
          opacity: 0.078,
          borderRadius: 30,
          borderColor: CupertinoColors.white.withOpacity(0.12),
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.fromLTRB(17, 17, 17, 17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.2,
                colors: [
                  AppColors.accentPrimary.withOpacity(0.13),
                  CupertinoColors.white.withOpacity(0.038),
                  CupertinoColors.black.withOpacity(0.02),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Currency Exchange',
                  style: AppTypography.displaySemi22.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: -0.55,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Convert travel budget between USD, IDR, and EUR.',
                  style: AppTypography.textRegular13.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),
                _AmountInput(
                  controller: _controller,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                _ResultPanel(
                  symbol: _symbol(to),
                  code: to,
                  result: _format(_result),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _CurrencyTile(
                        code: from,
                        symbol: _symbol(from),
                        name: _name(from),
                        onTap: _cycleFrom,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _SwapButton(onTap: _swap),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CurrencyTile(
                        code: to,
                        symbol: _symbol(to),
                        name: _name(to),
                        onTap: _cycleTo,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _RateHint(text: rateText),
      ],
    );
  }
}

class _AmountInput extends StatelessWidget {
  const _AmountInput({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: CupertinoColors.white.withOpacity(0.055),
        border: Border.all(
          color: CupertinoColors.white.withOpacity(0.08),
          width: 0.8,
        ),
      ),
      child: CupertinoTextField.borderless(
        controller: controller,
        onChanged: onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
        placeholder: 'Amount',
        placeholderStyle: AppTypography.textRegular13.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
        style: AppTypography.displayBold34.copyWith(
          color: AppColors.textPrimary,
          fontSize: 30,
          letterSpacing: -0.9,
        ),
        cursorColor: AppColors.textPrimary,
      ),
    );
  }
}

class _CurrencyTile extends StatefulWidget {
  const _CurrencyTile({
    required this.code,
    required this.symbol,
    required this.name,
    required this.onTap,
  });

  final String code;
  final String symbol;
  final String name;
  final VoidCallback onTap;

  @override
  State<_CurrencyTile> createState() => _CurrencyTileState();
}

class _CurrencyTileState extends State<_CurrencyTile> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          height: 70,
          padding: const EdgeInsets.fromLTRB(11, 11, 11, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: CupertinoColors.white.withOpacity(0.052),
            border: Border.all(
              color: CupertinoColors.white.withOpacity(0.075),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentTertiary.withOpacity(0.14),
                ),
                child: Text(
                  widget.symbol,
                  style: AppTypography.textMedium15.copyWith(
                    color: AppColors.accentTertiary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.code,
                      style: AppTypography.textMedium15.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.captionSmall11.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwapButton extends StatefulWidget {
  const _SwapButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<_SwapButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: GlassCard(
          width: 46,
          height: 46,
          blur: 24,
          opacity: 0.095,
          borderRadius: 999,
          borderColor: CupertinoColors.white.withOpacity(0.10),
          padding: EdgeInsets.zero,
          child: const Center(
            child: Icon(
              CupertinoIcons.arrow_2_squarepath,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.symbol,
    required this.code,
    required this.result,
  });

  final String symbol;
  final String code;
  final String result;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 30,
      opacity: 0.085,
      borderRadius: 28,
      borderColor: CupertinoColors.white.withOpacity(0.11),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Converted',
            style: AppTypography.captionSmall11.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                symbol,
                style: AppTypography.displaySemi22.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  result,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.displayBold34.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 36,
                    letterSpacing: -1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            code,
            style: AppTypography.captionSmall11.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _RateHint extends StatelessWidget {
  const _RateHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 24,
      opacity: 0.06,
      borderRadius: 999,
      borderColor: CupertinoColors.white.withOpacity(0.08),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.info_circle,
            size: 15,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.captionSmall11.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

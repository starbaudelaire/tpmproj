import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/glass_card.dart';
import 'guide_controller.dart';
import '../../../shared/widgets/jogja_page_header.dart';

class GuideScreen extends ConsumerStatefulWidget {
  const GuideScreen({this.initialPrompt, super.key});

  final String? initialPrompt;

  @override
  ConsumerState<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends ConsumerState<GuideScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  bool _sending = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialPrompt != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.text = widget.initialPrompt!;
        _send();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    HapticFeedback.selectionClick();

    _controller.clear();

    setState(() => _sending = true);

    await ref.read(chatHistoryProvider.notifier).send(text);

    if (!mounted) return;

    setState(() => _sending = false);

    await Future<void>.delayed(const Duration(milliseconds: 80));

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _useSuggestion(String value) {
    _controller.text = value;
    _send();
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(chatHistoryProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.18,
          colors: [
            Color(0xFF282836),
            Color(0xFF181821),
            Color(0xFF0F0F16),
            Color(0xFF06070B),
          ],
          stops: [0, 0.32, 0.68, 1],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: JogjaPageHeader(
                title: 'Guide AI',
                subtitle: 'Tanya rekomendasi wisata dengan gaya pemandu Jogja.',
                trailing: _CircleButton(
                  icon: CupertinoIcons.trash,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(chatHistoryProvider.notifier).clear();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SuggestionRow(onSelected: _useSuggestion),
            const SizedBox(height: 12),
            Expanded(
              child: history.isEmpty
                  ? const _EmptyGuideState()
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final message = history[history.length - index - 1];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: message.isUser
                              ? _UserBubble(message: message.text)
                              : _AiBubble(
                                  message: message.text,
                                  loading: message.text.trim().isEmpty,
                                ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
              child: _GuideInputBar(
                controller: _controller,
                sending: _sending,
                onSend: _send,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _GuideHeader extends StatelessWidget {
  const _GuideHeader({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentSecondary.withOpacity(0.14),
            border: Border.all(
              color: CupertinoColors.white.withOpacity(0.10),
            ),
          ),
          child: const Icon(
            CupertinoIcons.sparkles,
            size: 21,
            color: AppColors.accentSecondary,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guide AI',
                style: AppTypography.displayBold34.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 31,
                  letterSpacing: -1.05,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tanya itinerary, kuliner, budaya, dan hidden gems Jogja.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textRegular13.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _CircleButton(
          icon: CupertinoIcons.trash,
          onTap: onClear,
        ),
      ],
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const suggestions = [
      'Itinerary Jogja 1 hari',
      'Kuliner murah',
      'Hidden gems',
      'Wisata budaya',
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final value = suggestions[index];

          return CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: () => onSelected(value),
            child: GlassCard(
              blur: 24,
              opacity: 0.07,
              borderRadius: 999,
              borderColor: CupertinoColors.white.withOpacity(0.10),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              child: Text(
                value,
                style: AppTypography.captionSmall11.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyGuideState extends StatelessWidget {
  const _EmptyGuideState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: GlassCard(
          blur: 32,
          opacity: 0.072,
          borderRadius: 28,
          borderColor: CupertinoColors.white.withOpacity(0.11),
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.map,
                size: 34,
                color: AppColors.accentTertiary,
              ),
              const SizedBox(height: 14),
              Text(
                'Mau eksplor Jogja ke mana?',
                textAlign: TextAlign.center,
                style: AppTypography.displaySemi22.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: -0.45,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coba tanya rute wisata, itinerary, kuliner, atau rekomendasi tempat berdasarkan mood perjalananmu.',
                textAlign: TextAlign.center,
                style: AppTypography.textRegular13.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  const _AiBubble({
    required this.message,
    required this.loading,
  });

  final String message;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 310),
        child: GlassCard(
          blur: 30,
          opacity: 0.074,
          borderRadius: 24,
          borderColor: CupertinoColors.white.withOpacity(0.11),
          padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
          child: loading
              ? const CupertinoActivityIndicator(
                  color: AppColors.textSecondary,
                )
              : Text(
                  message,
                  style: AppTypography.textRegular13.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
        ),
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentPrimary.withOpacity(0.88),
                AppColors.accentPrimary.withOpacity(0.66),
              ],
            ),
            border: Border.all(
              color: CupertinoColors.white.withOpacity(0.14),
              width: 0.8,
            ),
          ),
          child: Text(
            message,
            style: AppTypography.textRegular13.copyWith(
              color: AppColors.textPrimary,
              height: 1.38,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideInputBar extends StatelessWidget {
  const _GuideInputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 34,
      opacity: 0.085,
      borderRadius: 999,
      borderColor: CupertinoColors.white.withOpacity(0.12),
      padding: const EdgeInsets.fromLTRB(16, 6, 7, 6),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField.borderless(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              placeholder: 'Ask Guide AI...',
              placeholderStyle: AppTypography.textRegular13.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              style: AppTypography.textRegular13.copyWith(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              cursorColor: AppColors.textPrimary,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          _SendButton(
            sending: sending,
            onTap: onSend,
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatefulWidget {
  const _SendButton({
    required this.sending,
    required this.onTap,
  });

  final bool sending;
  final VoidCallback onTap;

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || widget.sending) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        if (!widget.sending) widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentPrimary.withOpacity(0.9),
            border: Border.all(
              color: CupertinoColors.white.withOpacity(0.16),
            ),
          ),
          child: widget.sending
              ? const CupertinoActivityIndicator(
                  color: AppColors.textPrimary,
                )
              : const Icon(
                  CupertinoIcons.arrow_up,
                  size: 19,
                  color: AppColors.textPrimary,
                ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatefulWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<_CircleButton> {
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
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: GlassCard(
          width: 42,
          height: 42,
          blur: 28,
          opacity: 0.075,
          borderRadius: 999,
          borderColor: CupertinoColors.white.withOpacity(0.11),
          padding: EdgeInsets.zero,
          child: Center(
            child: Transform.translate(
              offset: const Offset(0.5, 0),
              child: Icon(
                widget.icon,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

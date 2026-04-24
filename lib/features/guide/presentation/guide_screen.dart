import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'guide_controller.dart';
import 'widgets/ai_card_response.dart';
import 'widgets/chat_bubble_ai.dart';
import 'widgets/chat_bubble_user.dart';
import 'widgets/chat_input_toolbar.dart';
import 'widgets/suggestion_chips_row.dart';

class GuideScreen extends ConsumerStatefulWidget {
  const GuideScreen({this.initialPrompt, super.key});

  final String? initialPrompt;

  @override
  ConsumerState<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends ConsumerState<GuideScreen> {
  final _controller = TextEditingController();

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
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(aiStreamProvider(text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(chatHistoryProvider);
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SuggestionChipsRow(
              onSelected: (value) {
                _controller.text = value;
                _send();
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final message = history[history.length - index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: message.isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      message.isUser
                          ? ChatBubbleUser(message: message.text)
                          : ChatBubbleAi(message: message.text),
                      if (!message.isUser && message.text.contains('Borobudur'))
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: AICardResponse(
                            title: 'Candi Borobudur',
                            subtitle:
                                'Sunrise, sejarah, dan jalur foto terbaik.',
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            child: ChatInputToolbar(controller: _controller, onSend: _send),
          ),
        ],
      ),
    );
  }
}

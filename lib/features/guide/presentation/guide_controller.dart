import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../domain/usecases/send_message_usecase.dart';

class ChatMessage {
  ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

class ChatController extends StateNotifier<List<ChatMessage>> {
  ChatController()
      : _useCase = SendMessageUseCase(getIt()),
        super(const []);

  final SendMessageUseCase _useCase;

  Stream<String> send(String prompt) {
    state = [...state, ChatMessage(text: prompt, isUser: true)];
    return _useCase(prompt).map((response) {
      if (state.isNotEmpty && !state.last.isUser) {
        state = [
          ...state.sublist(0, state.length - 1),
          ChatMessage(text: response, isUser: false),
        ];
      } else {
        state = [...state, ChatMessage(text: response, isUser: false)];
      }
      return response;
    });
  }
}

final chatHistoryProvider =
    StateNotifierProvider<ChatController, List<ChatMessage>>(
  (ref) => ChatController(),
);

final aiStreamProvider = StreamProvider.autoDispose.family<String, String>(
  (ref, prompt) => ref.read(chatHistoryProvider.notifier).send(prompt),
);

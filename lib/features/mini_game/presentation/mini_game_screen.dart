import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../data/quiz_local_datasource.dart';
import 'widgets/quiz_lobby.dart';
import 'widgets/quiz_question_card.dart';
import 'widgets/quiz_result_card.dart';
import 'widgets/quiz_timer_arc.dart';

enum QuizPhase { lobby, question, result }

class QuizState {
  const QuizState({
    this.phase = QuizPhase.lobby,
    this.questions = const [],
    this.questionIndex = 0,
    this.score = 0,
    this.timeLeft = 15,
  });

  final QuizPhase phase;
  final List<QuizQuestion> questions;
  final int questionIndex;
  final int score;
  final int timeLeft;

  QuizQuestion? get currentQuestion =>
      questionIndex < questions.length ? questions[questionIndex] : null;

  QuizState copyWith({
    QuizPhase? phase,
    List<QuizQuestion>? questions,
    int? questionIndex,
    int? score,
    int? timeLeft,
  }) {
    return QuizState(
      phase: phase ?? this.phase,
      questions: questions ?? this.questions,
      questionIndex: questionIndex ?? this.questionIndex,
      score: score ?? this.score,
      timeLeft: timeLeft ?? this.timeLeft,
    );
  }
}

class QuizController extends StateNotifier<QuizState> {
  QuizController(this._dataSource) : super(const QuizState());

  final QuizLocalDataSource _dataSource;
  Timer? _timer;

  Future<void> start() async {
    final questions = await _dataSource.loadQuestions();
    state = QuizState(
      phase: QuizPhase.question,
      questions: questions.take(5).toList(),
    );
    _startTimer();
  }

  void answer(int index) {
    final current = state.currentQuestion;
    if (current == null) return;
    final updatedScore =
        index == current.correctIndex ? state.score + 20 : state.score;
    _advance(updatedScore);
  }

  void _advance(int score) {
    if (state.questionIndex >= state.questions.length - 1) {
      _timer?.cancel();
      _dataSource.saveScore(
        score: score,
        correct: score ~/ 20,
        total: state.questions.length,
      );
      state = state.copyWith(phase: QuizPhase.result, score: score);
      return;
    }
    state = state.copyWith(
      questionIndex: state.questionIndex + 1,
      score: score,
      timeLeft: 15,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft <= 1) {
        state = state.copyWith(timeLeft: 15);
        _advance(state.score);
      } else {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      }
    });
  }

  void reset() {
    _timer?.cancel();
    state = const QuizState();
  }
}

final quizStateProvider = StateNotifierProvider<QuizController, QuizState>(
  (ref) => QuizController(getIt()),
);

class MiniGameScreen extends ConsumerWidget {
  const MiniGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizStateProvider);
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Mini Game')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: switch (state.phase) {
            QuizPhase.lobby => QuizLobby(
                onStart: () => ref.read(quizStateProvider.notifier).start(),
              ),
            QuizPhase.question => Column(
                children: [
                  QuizTimerArc(progress: state.timeLeft / 15),
                  const SizedBox(height: 20),
                  if (state.currentQuestion != null)
                    QuizQuestionCard(
                      question: state.currentQuestion!,
                      onAnswer: (index) =>
                          ref.read(quizStateProvider.notifier).answer(index),
                    ),
                ],
              ),
            QuizPhase.result => QuizResultCard(
                score: state.score,
                onReplay: () => ref.read(quizStateProvider.notifier).reset(),
              ),
          },
        ),
      ),
    );
  }
}

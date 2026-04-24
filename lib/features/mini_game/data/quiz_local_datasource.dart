import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../bootstrap/hive_init.dart';
import '../../../core/constants/app_constants.dart';

class QuizQuestion {
  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.category,
  });

  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String category;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['id'] as String,
        question: json['question'] as String,
        options: List<String>.from(json['options'] as List),
        correctIndex: json['correctIndex'] as int,
        category: json['category'] as String,
      );
}

class QuizLocalDataSource {
  Future<List<QuizQuestion>> loadQuestions() async {
    final raw = await rootBundle.loadString('assets/data/quiz_questions.json');
    return (jsonDecode(raw) as List<dynamic>)
        .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveScore({
    required int score,
    required int correct,
    required int total,
  }) async {
    final box = Hive.box<QuizScoreModel>(AppConstants.quizScoresBox);
    await box.put(
      const Uuid().v4(),
      QuizScoreModel(
        id: const Uuid().v4(),
        score: score,
        correct: correct,
        total: total,
        playedAt: DateTime.now(),
      ),
    );
  }
}

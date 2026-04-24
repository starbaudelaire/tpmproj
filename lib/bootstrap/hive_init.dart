import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/app_constants.dart';
import '../shared/models/destination.dart';
import '../shared/models/user.dart';

class QuizScoreModel {
  QuizScoreModel({
    required this.id,
    required this.score,
    required this.correct,
    required this.total,
    required this.playedAt,
  });

  final String id;
  final int score;
  final int correct;
  final int total;
  final DateTime playedAt;
}

class QuizScoreAdapter extends TypeAdapter<QuizScoreModel> {
  @override
  final int typeId = 2;

  @override
  QuizScoreModel read(BinaryReader reader) {
    return QuizScoreModel(
      id: reader.readString(),
      score: reader.readInt(),
      correct: reader.readInt(),
      total: reader.readInt(),
      playedAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, QuizScoreModel obj) {
    writer
      ..writeString(obj.id)
      ..writeInt(obj.score)
      ..writeInt(obj.correct)
      ..writeInt(obj.total)
      ..writeString(obj.playedAt.toIso8601String());
  }
}

abstract final class HiveInit {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DestinationModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(QuizScoreAdapter());
    }

    await Hive.openBox<UserModel>(AppConstants.usersBox);
    await Hive.openBox<DestinationModel>(AppConstants.destinationsBox);
    await Hive.openBox<QuizScoreModel>(AppConstants.quizScoresBox);
  }
}

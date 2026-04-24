import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';

class AiRemoteDataSource {
  AiRemoteDataSource(this._dio);

  final Dio _dio;

  Stream<String> streamReply(String prompt) async* {
    if (ApiConstants.aiApiKey.isEmpty) {
      final words =
          'Saya rekomendasikan mengunjungi Candi Borobudur saat pagi hari, lalu lanjut ke kopi tenang di Prawirotaman untuk suasana yang lebih santai.'
              .split(' ');
      var buffer = '';
      for (final word in words) {
        await Future<void>.delayed(const Duration(milliseconds: 90));
        buffer = '$buffer $word'.trim();
        yield buffer;
      }
      return;
    }

    try {
      final response = await _dio.post<ResponseBody>(
        '${ApiConstants.aiBaseUrl}/v1/chat/completions',
        data: {
          'model': ApiConstants.aiModel,
          'stream': true,
          'messages': [
            {
              'role': 'system',
              'content':
                  'Kamu adalah pemandu wisata Yogyakarta yang ramah dan berpengetahuan. Beri jawaban singkat, membantu, dan lokal.',
            },
            {'role': 'user', 'content': prompt},
          ],
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${ApiConstants.aiApiKey}'},
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data?.stream;
      if (stream == null) throw Exception('No stream');
      var output = '';
      await for (final chunk in stream) {
        final text = utf8.decode(chunk);
        output += text;
        yield output;
      }
    } catch (_) {
      yield 'Guide AI sedang tidak tersedia';
    }
  }
}

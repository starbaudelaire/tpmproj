import '../../data/ai_remote_datasource.dart';

class SendMessageUseCase {
  const SendMessageUseCase(this._dataSource);

  final AiRemoteDataSource _dataSource;

  Stream<String> call(String prompt) => _dataSource.streamReply(prompt);
}

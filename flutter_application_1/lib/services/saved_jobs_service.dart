import 'api_client.dart';

class SavedJobsService {
  SavedJobsService._();

  static final SavedJobsService instance = SavedJobsService._();

  Future<List<Map<String, dynamic>>> fetchSavedJobs() async {
    final dio = await ApiClient.instance.authenticated();
    final response = await dio.get('/saved-jobs');
    final payload = response.data;

    if (payload is! List) {
      throw const FormatException('Invalid saved jobs response');
    }

    return payload
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> saveJob(int postId) async {
    final dio = await ApiClient.instance.authenticated();
    await dio.post('/saved-jobs/$postId');
  }

  Future<void> unsaveJob(int postId) async {
    final dio = await ApiClient.instance.authenticated();
    await dio.delete('/saved-jobs/$postId');
  }
}

import 'api_client.dart';

class SavedJobsService {
  SavedJobsService._();

  static final SavedJobsService instance = SavedJobsService._();

  /// Fetch all saved jobs for user
  Future<List<Map<String, dynamic>>> fetchSavedJobs() async {
    try {
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.get('/saved-jobs');
      final payload = response.data;

      if (payload is! List) {
        throw FormatException('Invalid saved jobs response');
      }

      return payload
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Save a job by post ID
  Future<void> saveJob(int postId) async {
    try {
      final dio = await ApiClient.instance.authenticated();
      await dio.post('/saved-jobs/$postId');
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Unsave a job by post ID
  Future<void> unsaveJob(int postId) async {
    try {
      final dio = await ApiClient.instance.authenticated();
      await dio.delete('/saved-jobs/$postId');
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Check if job is saved
  Future<bool> isJobSaved(int postId) async {
    try {
      final savedJobs = await fetchSavedJobs();
      return savedJobs.any((job) => job['postId'] == postId);
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }
}

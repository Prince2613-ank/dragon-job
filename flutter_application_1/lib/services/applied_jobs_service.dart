import 'api_client.dart';

/// Service for managing applied jobs
class AppliedJobsService {
  AppliedJobsService._();

  static final AppliedJobsService instance = AppliedJobsService._();

  /// Fetch all applied jobs for user
  Future<List<Map<String, dynamic>>> fetchAppliedJobs() async {
    try {
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.get('/applied-jobs');
      final payload = response.data;

      if (payload is! List) {
        throw FormatException('Invalid applied jobs response');
      }

      return payload
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Get applied jobs by status
  Future<List<Map<String, dynamic>>> fetchAppliedJobsByStatus(
    String status,
  ) async {
    try {
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.get(
        '/applied-jobs',
        queryParameters: {'status': status},
      );
      final payload = response.data;

      if (payload is! List) {
        throw FormatException('Invalid applied jobs response');
      }

      return payload
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Apply to a job
  Future<Map<String, dynamic>> applyToJob(
    int postId, {
    String? coverLetter,
  }) async {
    try {
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.post(
        '/applied-jobs/$postId',
        data: {if (coverLetter != null) 'coverLetter': coverLetter},
      );

      if (response.data is! Map) {
        throw FormatException('Invalid apply response');
      }
      return Map<String, dynamic>.from(response.data as Map);
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Withdraw application
  Future<void> withdrawApplication(int applicationId) async {
    try {
      final dio = await ApiClient.instance.authenticated();
      await dio.delete('/applied-jobs/$applicationId');
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Check if already applied to job
  Future<bool> hasApplied(int postId) async {
    try {
      final appliedJobs = await fetchAppliedJobs();
      return appliedJobs.any((job) => job['postId'] == postId);
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Get application status
  Future<String?> getApplicationStatus(int postId) async {
    try {
      final appliedJobs = await fetchAppliedJobs();
      final application = appliedJobs.firstWhere(
        (job) => job['postId'] == postId,
      );
      return application['status']?.toString();
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Valid application statuses
  static const List<String> validStatuses = [
    'pending',
    'reviewed',
    'accepted',
    'rejected',
    'withdrawn',
  ];
}

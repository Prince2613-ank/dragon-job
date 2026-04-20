/// Service Provider / Locator
/// Centralized access to all app services
/// Provides a single source of truth for service instances

import 'api_client.dart';
import 'applied_jobs_service.dart';
import 'auth_service.dart';
import 'job_recommendation_service.dart';
import 'notification_service.dart';
import 'posts_service.dart';
import 'saved_jobs_service.dart';
import 'search_service.dart';
import 'user_skills_service.dart';

class ServiceProvider {
  ServiceProvider._();

  // Singleton instances
  static final ApiClient _apiClient = ApiClient.instance;
  static final AuthService _authService = AuthService.instance;
  static final PostsService _postsService = PostsService.instance;
  static final SavedJobsService _savedJobsService = SavedJobsService.instance;
  static final UserSkillsService _userSkillsService =
      UserSkillsService.instance;
  static final JobRecommendationService _jobRecommendationService =
      JobRecommendationService.instance;
  static final AppliedJobsService _appliedJobsService =
      AppliedJobsService.instance;
  static final NotificationService _notificationService =
      NotificationService.instance;
  static final SearchService _searchService = SearchService.instance;

  // Export services
  static ApiClient get api => _apiClient;
  static AuthService get auth => _authService;
  static PostsService get posts => _postsService;
  static SavedJobsService get savedJobs => _savedJobsService;
  static UserSkillsService get skills => _userSkillsService;
  static JobRecommendationService get jobRecommendations =>
      _jobRecommendationService;
  static AppliedJobsService get appliedJobs => _appliedJobsService;
  static NotificationService get notifications => _notificationService;
  static SearchService get search => _searchService;

  /// Initialize all services
  static Future<void> initialize() async {
    // Add any initialization logic here
    // For example, check if user is already logged in
    final hasToken = await ApiClient.instance.hasAuthToken();
    if (hasToken) {
      // Token exists, services are ready
    }
  }

  /// Reset all services (useful for logout)
  static Future<void> reset() async {
    await AuthService.instance.logout();
  }
}

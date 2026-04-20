import 'api_client.dart';

/// Service for managing notifications
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  /// Fetch all notifications
  Future<List<Map<String, dynamic>>> fetchNotifications({
    int? limit,
    int? offset,
  }) async {
    try {
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.get(
        '/notifications',
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );
      final payload = response.data;

      if (payload is! List) {
        throw FormatException('Invalid notifications response');
      }

      return payload
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Fetch unread notifications
  Future<List<Map<String, dynamic>>> fetchUnreadNotifications() async {
    try {
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.get(
        '/notifications',
        queryParameters: {'unread': true},
      );
      final payload = response.data;

      if (payload is! List) {
        throw FormatException('Invalid notifications response');
      }

      return payload
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      final dio = await ApiClient.instance.authenticated();
      await dio.put('/notifications/$notificationId', data: {'read': true});
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final dio = await ApiClient.instance.authenticated();
      await dio.put('/notifications/mark-all-read');
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      final dio = await ApiClient.instance.authenticated();
      await dio.delete('/notifications/$notificationId');
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    try {
      final dio = await ApiClient.instance.authenticated();
      await dio.delete('/notifications');
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Get notification count
  Future<int> getUnreadCount() async {
    try {
      final unreadNotifications = await fetchUnreadNotifications();
      return unreadNotifications.length;
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Notification types
  static const String typeJobRecommendation = 'job_recommendation';
  static const String typeApplicationStatus = 'application_status';
  static const String typeSavedJob = 'saved_job';
  static const String typeSkillUpdate = 'skill_update';
  static const String typeProfileUpdate = 'profile_update';
}

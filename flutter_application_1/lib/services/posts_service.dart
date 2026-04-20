import 'package:dio/dio.dart';

import 'api_client.dart';

class PostsService {
  PostsService._();

  static final PostsService instance = PostsService._();

  /// Fetch all posts or filtered by type
  Future<List<Map<String, dynamic>>> fetchPosts({String? type}) async {
    try {
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.get(
        '/posts',
        queryParameters: type == null ? null : {'type': type},
      );
      return _extractList(response.data);
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Fetch a single post by ID
  Future<Map<String, dynamic>> fetchPostById(int id) async {
    try {
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.get('/posts/$id');

      if (response.data is! Map) {
        throw FormatException('Invalid post response');
      }
      return Map<String, dynamic>.from(response.data as Map);
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Create a new post (admin only)
  Future<Map<String, dynamic>> createPost(Map<String, dynamic> payload) async {
    try {
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.post('/posts', data: payload);

      if (response.data is! Map) {
        throw FormatException('Invalid create post response');
      }
      return Map<String, dynamic>.from(response.data as Map);
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Extract list of posts from response
  List<Map<String, dynamic>> _extractList(dynamic payload) {
    final rawList = switch (payload) {
      List<dynamic> list => list,
      Map<dynamic, dynamic> map when map['posts'] is List =>
        map['posts'] as List,
      _ => throw FormatException('Invalid posts response'),
    };

    return rawList
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}

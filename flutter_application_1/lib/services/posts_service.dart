import 'package:dio/dio.dart';

import 'api_client.dart';

class PostsService {
  PostsService._();

  static final PostsService instance = PostsService._();

  Future<List<Map<String, dynamic>>> fetchPosts({String? type}) async {
    final dio = await ApiClient.instance.authenticated();
    final response = await dio.get(
      '/posts',
      queryParameters: type == null ? null : {'type': type},
    );

    return _extractList(response.data);
  }

  Future<Map<String, dynamic>> createPost(Map<String, dynamic> payload) async {
    final dio = await ApiClient.instance.authenticated();
    final response = await dio.post('/posts', data: payload);

    if (response.data is! Map) {
      throw const FormatException('Invalid create post response');
    }
    return Map<String, dynamic>.from(response.data as Map);
  }

  List<Map<String, dynamic>> _extractList(dynamic payload) {
    final rawList = switch (payload) {
      List<dynamic> list => list,
      Map<dynamic, dynamic> map when map['posts'] is List => map['posts'] as List,
      _ => throw const FormatException('Invalid posts response')
    };

    return rawList
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}

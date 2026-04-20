import 'package:dio/dio.dart';

import 'api_client.dart';

class UserSkillsService {
  UserSkillsService._();

  static final UserSkillsService instance = UserSkillsService._();

  /// Fetch user skills
  Future<List<String>> fetchSkills() async {
    try {
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.get('/users/me/skills');
      return _extractSkills(response.data);
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Replace all user skills
  Future<List<String>> replaceSkills(List<String> skills) async {
    try {
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.put(
        '/users/me/skills',
        data: {'skills': skills},
      );
      return _extractSkills(response.data);
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Add a single skill
  Future<List<String>> addSkill(String skill) async {
    try {
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.post(
        '/users/me/skills',
        data: {'skill': skill},
      );
      return _extractSkills(response.data);
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Remove a skill
  Future<List<String>> removeSkill(String skill) async {
    try {
      final encodedSkill = Uri.encodeComponent(skill);
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.delete('/users/me/skills/$encodedSkill');
      return _extractSkills(response.data);
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Check if skill exists
  Future<bool> hasSkill(String skill) async {
    try {
      final skills = await fetchSkills();
      return skills.any((s) => s.toLowerCase() == skill.toLowerCase());
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Extract skills from response
  List<String> _extractSkills(dynamic payload) {
    if (payload is! Map || payload['skills'] is! List) {
      throw FormatException('Invalid skills response');
    }

    return (payload['skills'] as List)
        .map((item) => item.toString())
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }
}

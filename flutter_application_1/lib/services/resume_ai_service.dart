import 'dart:io';

import 'package:dio/dio.dart';

import 'api_client.dart';

class ResumeAiService {
  ResumeAiService._();

  static final ResumeAiService instance = ResumeAiService._();

  /// Analyze resume using AI
  Future<Map<String, dynamic>> analyzeResume({
    required String filePath,
    String type = 'job',
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw ArgumentError('Resume file not found at path: $filePath');
      }

      // Validate file size (10MB max)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw ArgumentError('File size exceeds 10MB limit');
      }

      final dio = await ApiClient.instance.authenticated();
      final formData = FormData.fromMap({
        'resume': await MultipartFile.fromFile(
          filePath,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      });

      final response = await dio.post(
        '/ai/analyze-resume',
        queryParameters: {'type': type},
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      if (response.data is! Map) {
        throw FormatException('Invalid AI analysis response');
      }

      return Map<String, dynamic>.from(response.data as Map);
    } catch (error) {
      if (error is ArgumentError) rethrow;
      throw ApiClient.handleError(error);
    }
  }

  /// Get supported resume analysis types
  List<String> getSupportedTypes() => ['job', 'internship', 'freelance'];
}

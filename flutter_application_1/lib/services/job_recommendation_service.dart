import 'dart:io';

import 'package:dio/dio.dart';

import 'api_client.dart';

/// Service for AI-powered job recommendations and resume analysis
class JobRecommendationService {
  JobRecommendationService._();

  static final JobRecommendationService instance = JobRecommendationService._();

  /// Analyze resume and get job recommendations
  Future<Map<String, dynamic>> analyzeResumeAndGetRecommendations({
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

  /// Extract recommended jobs from analysis result
  List<Map<String, dynamic>> extractRecommendedJobs(
    Map<String, dynamic> analysisResult,
  ) {
    try {
      final jobs = analysisResult['recommendedJobs'];
      if (jobs is! List) return [];

      return jobs
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Extract parsed resume from analysis result
  Map<String, dynamic>? extractParsedResume(
    Map<String, dynamic> analysisResult,
  ) {
    try {
      final resume = analysisResult['parsedResume'];
      if (resume is! Map) return null;
      return Map<String, dynamic>.from(resume as Map);
    } catch (_) {
      return null;
    }
  }

  /// Get profile completion percentage
  int? getProfileCompletion(Map<String, dynamic> analysisResult) {
    try {
      final completion = analysisResult['profileCompletion'];
      if (completion is int) return completion;
      if (completion is double) return completion.toInt();
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get match score for top job
  int? getTopMatchScore(Map<String, dynamic> analysisResult) {
    try {
      final score = analysisResult['matchScore'];
      if (score is int) return score;
      if (score is double) return score.toInt();
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get data source information (AI vs heuristic)
  Map<String, dynamic>? getSourceInfo(Map<String, dynamic> analysisResult) {
    try {
      final source = analysisResult['source'];
      if (source is Map) {
        return Map<String, dynamic>.from(source as Map);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get analysis metadata
  Map<String, dynamic>? getMetadata(Map<String, dynamic> analysisResult) {
    try {
      final meta = analysisResult['meta'];
      if (meta is Map) {
        return Map<String, dynamic>.from(meta as Map);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get matched skills from analysis
  List<String> getMatchedSkills(Map<String, dynamic> analysisResult) {
    try {
      final skills = analysisResult['matchedSkills'];
      if (skills is! List) return [];

      return skills.map((s) => s.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  /// Get missing skills from analysis
  List<String> getMissingSkills(Map<String, dynamic> analysisResult) {
    try {
      final skills = analysisResult['missingSkills'];
      if (skills is! List) return [];

      return skills.map((s) => s.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  /// Check if latest analysis used AI or heuristic parser
  String? getParserSource(Map<String, dynamic> analysisResult) {
    try {
      final source = analysisResult['source'];
      if (source is Map && source['parser'] is String) {
        return source['parser'] as String;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Check if latest analysis used AI or heuristic matcher
  String? getMatcherSource(Map<String, dynamic> analysisResult) {
    try {
      final source = analysisResult['source'];
      if (source is Map && source['matcher'] is String) {
        return source['matcher'] as String;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get supported resume analysis types
  List<String> getSupportedTypes() => ['job', 'internship', 'daily_wage'];
}

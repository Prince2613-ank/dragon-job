import 'api_client.dart';

/// Service for searching and filtering jobs with advanced options
class SearchService {
  SearchService._();

  static final SearchService instance = SearchService._();

  /// Search jobs by multiple criteria
  Future<List<Map<String, dynamic>>> searchJobs({
    String? query,
    String? type, // 'job', 'internship', 'daily_wage'
    String? location,
    String? company,
    int? minSalary,
    int? maxSalary,
    List<String>? skills,
    int? limit,
    int? offset,
  }) async {
    try {
      final dio = await ApiClient.instance.authenticated();

      final queryParams = <String, dynamic>{
        if (query != null && query.isNotEmpty) 'q': query,
        if (type != null && type.isNotEmpty) 'type': type,
        if (location != null && location.isNotEmpty) 'location': location,
        if (company != null && company.isNotEmpty) 'company': company,
        if (minSalary != null) 'minSalary': minSalary,
        if (maxSalary != null) 'maxSalary': maxSalary,
        if (skills != null && skills.isNotEmpty) 'skills': skills.join(','),
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      };

      final response = await dio.get(
        '/posts/search',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return _extractSearchResults(response.data);
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Advanced search with filters
  Future<Map<String, dynamic>> advancedSearch({
    required Map<String, dynamic> filters,
    int? limit,
    int? offset,
  }) async {
    try {
      final dio = await ApiClient.instance.authenticated();

      final response = await dio.post(
        '/posts/advanced-search',
        data: {
          'filters': filters,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      if (response.data is! Map) {
        throw FormatException('Invalid search response');
      }

      return Map<String, dynamic>.from(response.data as Map);
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Search by location
  Future<List<Map<String, dynamic>>> searchByLocation(String location) async {
    return searchJobs(location: location);
  }

  /// Search by company
  Future<List<Map<String, dynamic>>> searchByCompany(String company) async {
    return searchJobs(company: company);
  }

  /// Search by type
  Future<List<Map<String, dynamic>>> searchByType(String type) async {
    return searchJobs(type: type);
  }

  /// Filter by skills
  Future<List<Map<String, dynamic>>> filterBySkills(List<String> skills) async {
    return searchJobs(skills: skills);
  }

  /// Get trending searches
  Future<List<String>> getTrendingSearches() async {
    try {
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.get('/posts/trending-searches');

      if (response.data is! List) {
        throw FormatException('Invalid trending searches response');
      }

      return (response.data as List).map((item) => item.toString()).toList();
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Get search suggestions
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final dio = await ApiClient.instance.authenticated();
      final response = await dio.get(
        '/posts/search-suggestions',
        queryParameters: {'q': query},
      );

      if (response.data is! List) {
        throw FormatException('Invalid suggestions response');
      }

      return (response.data as List).map((item) => item.toString()).toList();
    } catch (error) {
      throw ApiClient.handleError(error);
    }
  }

  /// Extract search results from response
  List<Map<String, dynamic>> _extractSearchResults(dynamic payload) {
    final rawList = switch (payload) {
      List<dynamic> list => list,
      Map<dynamic, dynamic> map when map['results'] is List =>
        map['results'] as List,
      Map<dynamic, dynamic> map when map['posts'] is List =>
        map['posts'] as List,
      _ => throw FormatException('Invalid search results format'),
    };

    return rawList
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  /// Get available job types
  static const List<String> jobTypes = ['job', 'internship', 'daily_wage'];

  /// Get salary ranges for filtering
  static const Map<String, List<int>> salaryRanges = {
    'entry': [0, 300000],
    'mid': [300000, 600000],
    'senior': [600000, 1200000],
    'executive': [1200000, 2500000],
  };
}

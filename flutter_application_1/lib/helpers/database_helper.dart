import '../services/auth_service.dart';
import '../services/posts_service.dart';
import '../services/saved_jobs_service.dart';

class Job {
  final int? id;
  final int? postId;
  final String title;
  final String company;
  final String location;
  final String logo;

  Job({
    this.id,
    this.postId,
    required this.title,
    required this.company,
    required this.location,
    required this.logo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'title': title,
      'company': company,
      'location': location,
      'logo': logo,
    };
  }

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'] as int?,
      postId: map['postId'] as int?,
      title: (map['title'] ?? '') as String,
      company: (map['company'] ?? '') as String,
      location: (map['location'] ?? '') as String,
      logo: (map['logo'] ?? 'work') as String,
    );
  }
}

class AdminPost {
  final int? id;
  final String postType;
  final String role;
  final String company;
  final String salary;
  final String location;
  final String description;

  AdminPost({
    this.id,
    required this.postType,
    required this.role,
    required this.company,
    required this.salary,
    required this.location,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postType': postType,
      'role': role,
      'company': company,
      'salary': salary,
      'location': location,
      'description': description,
    };
  }

  factory AdminPost.fromMap(Map<String, dynamic> map) {
    return AdminPost(
      id: map['id'] as int?,
      postType: (map['postType'] ?? '') as String,
      role: (map['role'] ?? '') as String,
      company: (map['company'] ?? '') as String,
      salary: (map['salary'] ?? '') as String,
      location: (map['location'] ?? '') as String,
      description: (map['description'] ?? '') as String,
    );
  }
}

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  final Map<int, int> _savedJobIdToPostId = {};

  Future<int> insertJob(Job job) async {
    if (job.postId == null || job.postId! <= 0) {
      throw ArgumentError('Cannot save a job without a valid postId');
    }

    await SavedJobsService.instance.saveJob(job.postId!);
    await getAllSavedJobs();
    return job.postId!;
  }

  Future<List<Job>> getAllSavedJobs() async {
    final remoteSavedJobs = await SavedJobsService.instance.fetchSavedJobs();
    _savedJobIdToPostId.clear();

    final jobs = <Job>[];
    for (final item in remoteSavedJobs) {
      final savedId = item['id'] as int?;
      final postId = item['postId'] as int?;
      final post = item['post'];

      if (post is! Map) continue;
      final postMap = Map<String, dynamic>.from(post);
      final resolvedPostId = postId ?? (postMap['id'] as int?);

      if (savedId != null && resolvedPostId != null) {
        _savedJobIdToPostId[savedId] = resolvedPostId;
      }

      jobs.add(
        Job(
          id: savedId,
          postId: resolvedPostId,
          title: (postMap['role'] ?? '') as String,
          company: (postMap['company'] ?? '') as String,
          location: (postMap['location'] ?? '') as String,
          logo: 'work',
        ),
      );
    }

    return jobs;
  }

  Future<int> deleteJob(int id) async {
    final postId = _savedJobIdToPostId[id] ?? await _resolvePostIdForSavedId(id);

    if (postId == null) {
      throw StateError('Saved job not found for id: $id');
    }

    await SavedJobsService.instance.unsaveJob(postId);
    _savedJobIdToPostId.remove(id);
    return 1;
  }

  Future<int?> _resolvePostIdForSavedId(int savedId) async {
    final remoteSavedJobs = await SavedJobsService.instance.fetchSavedJobs();

    for (final item in remoteSavedJobs) {
      final currentSavedId = item['id'] as int?;
      final postId = item['postId'] as int?;
      final post = item['post'];
      final postMap = post is Map ? Map<String, dynamic>.from(post) : null;
      final resolvedPostId = postId ?? (postMap?['id'] as int?);

      if (currentSavedId != null && resolvedPostId != null) {
        _savedJobIdToPostId[currentSavedId] = resolvedPostId;
      }

      if (currentSavedId == savedId) {
        return resolvedPostId;
      }
    }

    return null;
  }

  Future<void> deleteSavedJobForPost(AdminPost post) async {
    if (post.id != null && post.id! > 0) {
      await SavedJobsService.instance.unsaveJob(post.id!);
      _removeSavedJobCacheForPost(post.id!);
      return;
    }

    final savedJobs = await getAllSavedJobs();
    final match = savedJobs.where((job) {
      return job.title == post.role && job.company == post.company;
    });

    if (match.isEmpty) return;

    final firstMatch = match.first;
    if (firstMatch.postId == null) return;

    await SavedJobsService.instance.unsaveJob(firstMatch.postId!);
    _removeSavedJobCacheForPost(firstMatch.postId!);
  }

  void _removeSavedJobCacheForPost(int postId) {
    final targetIds = _savedJobIdToPostId.entries
        .where((entry) => entry.value == postId)
        .map((entry) => entry.key)
        .toList();

    for (final id in targetIds) {
      _savedJobIdToPostId.remove(id);
    }
  }

  Future<int> insertUser(String name, String email, String password) async {
    final user = await AuthService.instance.signup(
      name: name,
      email: email,
      password: password,
    );

    final userId = user['id'];
    if (userId is! int) {
      throw const FormatException('Invalid signup response: missing user id');
    }

    return userId;
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final user = await AuthService.instance.login(
        email: email,
        password: password,
      );

      return {
        'id': user['id'],
        'name': user['name'],
        'email': user['email'],
        'role': user['role'] ?? 'user',
      };
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final user = await AuthService.instance.getCurrentUser();
    if (user == null) return null;

    return {
      'id': (user['id'] as int?) ?? userId,
      'name': user['name'],
      'email': user['email'],
      'role': user['role'] ?? 'user',
    };
  }

  Future<void> updateUserProfile({
    required int userId,
    required String name,
    required String email,
  }) async {
    final updatedUser = await AuthService.instance.updateCurrentUser(
      name: name,
      email: email,
    );

    if (updatedUser == null) {
      throw Exception('Unable to update profile on backend');
    }
  }

  Future<int> insertAdminPost(AdminPost post) async {
    final createdPostData = await PostsService.instance.createPost(post.toMap());
    final createdPostId = createdPostData['id'];

    if (createdPostId is! int) {
      throw const FormatException('Invalid create post response: missing post id');
    }

    return createdPostId;
  }

  Future<List<AdminPost>> getPostsByType(String type) async {
    final remotePostsData = await PostsService.instance.fetchPosts(type: type);
    return remotePostsData.map(AdminPost.fromMap).toList();
  }

  Future<List<AdminPost>> getAllAdminPosts() async {
    final remotePostsData = await PostsService.instance.fetchPosts();
    return remotePostsData.map(AdminPost.fromMap).toList();
  }
}

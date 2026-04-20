import 'package:shared_preferences/shared_preferences.dart';

class AppliedJobsHelper {
  AppliedJobsHelper._();

  static final AppliedJobsHelper instance = AppliedJobsHelper._();

  Future<int> _currentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('loggedInUserId') ?? 0;
  }

  Future<String> _appliedIdsKey() async {
    final userId = await _currentUserId();
    return 'appliedPostIds_user_$userId';
  }

  Future<Set<int>> getAppliedPostIds() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _appliedIdsKey();
    final rawIds = prefs.getStringList(key) ?? [];

    return rawIds.map((item) => int.tryParse(item)).whereType<int>().toSet();
  }

  Future<bool> isApplied(int postId) async {
    final appliedIds = await getAppliedPostIds();
    return appliedIds.contains(postId);
  }

  Future<bool> markApplied(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _appliedIdsKey();

    final rawIds = prefs.getStringList(key) ?? [];
    final appliedIds = rawIds
        .map((item) => int.tryParse(item))
        .whereType<int>()
        .toSet();

    if (appliedIds.contains(postId)) {
      return false;
    }

    appliedIds.add(postId);
    await prefs.setStringList(
      key,
      appliedIds.map((id) => id.toString()).toList(),
    );

    final userId = await _currentUserId();
    await prefs.setInt('jobsAppliedCount_user_$userId', appliedIds.length);

    return true;
  }
}

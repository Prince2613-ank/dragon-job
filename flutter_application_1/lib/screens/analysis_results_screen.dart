import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/applied_jobs_helper.dart';
import '../services/resume_ai_service.dart';
import 'manage_resume_screen.dart';

class AnalysisResultsScreen extends StatefulWidget {
  const AnalysisResultsScreen({super.key});

  @override
  State<AnalysisResultsScreen> createState() => _AnalysisResultsScreenState();
}

class _AnalysisResultsScreenState extends State<AnalysisResultsScreen> {
  bool _loading = true;
  String? _error;

  ResumeFile? _resume;
  int _matchScore = 0;
  int _profileCompletion = 0;
  List<String> _matched = [];
  List<String> _missing = [];
  List<String> _resumeSkills = [];
  List<Map<String, dynamic>> _recommendedJobs = [];
  Set<int> _appliedPostIds = {};
  String _parserSource = 'unknown';
  String _matcherSource = 'unknown';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    if (!_loading) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    try {
      Map<String, dynamic>? analysis;

      if (args is Map) {
        final rawAnalysis = args['analysis'];
        if (rawAnalysis is Map) {
          analysis = Map<String, dynamic>.from(rawAnalysis);
        }

        final rawResume = args['resume'];
        if (rawResume is Map) {
          _resume = ResumeFile.fromMap(Map<String, dynamic>.from(rawResume));
        }
      } else if (args is ResumeFile) {
        _resume = args;
      }

      if (analysis == null) {
        if (_resume == null) {
          throw const FormatException('Resume is required for analysis');
        }

        analysis = await ResumeAiService.instance.analyzeResume(
          filePath: _resume!.path,
        );
      }

      _mapAnalysis(analysis);
      await _loadAppliedPostIds();
      await _persistAnalysis();

      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    } on DioException catch (error) {
      final message = error.response?.statusCode == 400
          ? 'Unable to parse this resume format.'
          : 'AI analysis failed. Please try again.';

      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Unable to load analysis results.';
      });
    }
  }

  Future<void> _loadAppliedPostIds() async {
    _appliedPostIds = await AppliedJobsHelper.instance.getAppliedPostIds();
  }

  int? _recommendedPostId(Map<String, dynamic> item) {
    final fromPostId = item['postId'];
    if (fromPostId is int) return fromPostId;
    if (fromPostId is num) return fromPostId.toInt();

    final post = item['post'];
    if (post is Map) {
      final id = post['id'];
      if (id is int) return id;
      if (id is num) return id.toInt();
    }

    return null;
  }

  String _recommendedRole(Map<String, dynamic> item) {
    final post = item['post'];
    if (post is Map && post['role'] != null) {
      return post['role'].toString();
    }
    return 'Unknown Role';
  }

  String _recommendedCompany(Map<String, dynamic> item) {
    final post = item['post'];
    if (post is Map && post['company'] != null) {
      return post['company'].toString();
    }
    return 'Unknown Company';
  }

  String _recommendedLocation(Map<String, dynamic> item) {
    final post = item['post'];
    if (post is Map && post['location'] != null) {
      return post['location'].toString();
    }
    return 'Unknown Location';
  }

  Future<void> _applyToRecommendedJob(Map<String, dynamic> item) async {
    final postId = _recommendedPostId(item);
    if (postId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to apply to this job.')),
      );
      return;
    }

    final added = await AppliedJobsHelper.instance.markApplied(postId);
    if (!mounted) return;

    setState(() {
      _appliedPostIds.add(postId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added ? 'Applied successfully' : 'Already applied to this job',
        ),
      ),
    );
  }

  void _mapAnalysis(Map<String, dynamic> analysis) {
    _matchScore = (analysis['matchScore'] as num?)?.round() ?? 0;
    _profileCompletion = (analysis['profileCompletion'] as num?)?.round() ?? 0;

    final matchedSkills = analysis['matchedSkills'];
    final missingSkills = analysis['missingSkills'];

    _matched = matchedSkills is List
        ? matchedSkills.map((item) => item.toString()).toList()
        : [];
    _missing = missingSkills is List
        ? missingSkills.map((item) => item.toString()).toList()
        : [];

    final parsedResume = analysis['parsedResume'];
    if (parsedResume is Map) {
      final rawSkills = parsedResume['skills'];
      _resumeSkills = rawSkills is List
          ? rawSkills.map((item) => item.toString()).toList()
          : [];
    }

    final source = analysis['source'];
    if (source is Map) {
      _parserSource = source['parser']?.toString() ?? 'unknown';
      _matcherSource = source['matcher']?.toString() ?? 'unknown';
    }

    final recommended = analysis['recommendedJobs'];
    _recommendedJobs = recommended is List
        ? recommended
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
        : [];
  }

  Future<void> _persistAnalysis() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('loggedInUserId') ?? 0;

    await prefs.setInt('last_resume_score_user_$userId', _matchScore);
    await prefs.setInt('profile_completion_user_$userId', _profileCompletion);
    await prefs.setStringList('last_matched_skills_user_$userId', _matched);
    await prefs.setStringList('last_missing_skills_user_$userId', _missing);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Analysis Results',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analysis Results',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Match Score: $_matchScore%',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _matchScore >= 70 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: _matchScore / 100,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              color: _matchScore >= 70 ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Chip(label: Text('Parser: $_parserSource')),
                const SizedBox(width: 8),
                Chip(label: Text('Matcher: $_matcherSource')),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Resume Skills Detected',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _resumeSkills.isNotEmpty
                  ? _resumeSkills
                        .map(
                          (skill) => Chip(
                            label: Text(skill),
                            backgroundColor: Colors.blue.shade100,
                            labelStyle: const TextStyle(color: Colors.blue),
                          ),
                        )
                        .toList()
                  : [
                      const Text(
                        'No skills detected from resume/profile yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Skills Matching Top Job',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _matched.isNotEmpty
                  ? _matched
                        .map(
                          (skill) => Chip(
                            label: Text(skill),
                            backgroundColor: Colors.green.shade100,
                            labelStyle: const TextStyle(color: Colors.green),
                          ),
                        )
                        .toList()
                  : [
                      const Text(
                        'No overlap with the top job yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Skills Missing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _missing.isNotEmpty
                  ? _missing
                        .map(
                          (skill) => Chip(
                            label: Text(skill),
                            backgroundColor: Colors.red.shade100,
                            labelStyle: const TextStyle(color: Colors.red),
                          ),
                        )
                        .toList()
                  : [
                      const Text(
                        'Great! No major skill gaps detected.',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
            ),
            const SizedBox(height: 20),
            if (_recommendedJobs.isNotEmpty) ...[
              Text(
                'Top Match: ${_recommendedRole(_recommendedJobs.first)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Recommended Jobs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ..._recommendedJobs.take(5).map((item) {
                final postId = _recommendedPostId(item);
                final score = (item['score'] as num?)?.round() ?? 0;
                final isApplied =
                    postId != null && _appliedPostIds.contains(postId);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.work, color: Colors.blue),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _recommendedRole(item),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_recommendedCompany(item)} - ${_recommendedLocation(item)}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Match: $score%',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isApplied
                              ? null
                              : () => _applyToRecommendedJob(item),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isApplied
                                ? Colors.grey
                                : Colors.blue,
                          ),
                          child: Text(isApplied ? 'Applied' : 'Apply'),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 10),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profile Completion',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$_profileCompletion%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/resume_ai_service.dart';

class ResumeFile {
  String name;
  String path;
  bool isDefault;
  List<String> skills;

  ResumeFile({
    required this.name,
    required this.path,
    this.isDefault = false,
    required this.skills,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'path': path,
    'isDefault': isDefault,
    'skills': skills,
  };

  factory ResumeFile.fromMap(Map<String, dynamic> map) {
    return ResumeFile(
      name: map['name'],
      path: map['path'],
      isDefault: map['isDefault'] ?? false,
      skills: List<String>.from(map['skills'] ?? []),
    );
  }
}

class ManageResumeScreen extends StatefulWidget {
  const ManageResumeScreen({super.key});

  @override
  State<ManageResumeScreen> createState() => _ManageResumeScreenState();
}

class _ManageResumeScreenState extends State<ManageResumeScreen> {
  List<ResumeFile> _resumes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadResumes();
  }

  Future<String> _resumesKey() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('loggedInUserId') ?? 0;
    return 'resumes_list_user_$userId';
  }

  Future<void> _loadResumes() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _resumesKey();
    final raw = prefs.getStringList(key) ?? [];

    if (!mounted) return;
    setState(() {
      _resumes = raw.map((e) => ResumeFile.fromMap(jsonDecode(e))).toList();
    });
  }

  Future<void> _persistResumes() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _resumesKey();
    await prefs.setStringList(
      key,
      _resumes.map((e) => jsonEncode(e.toMap())).toList(),
    );
  }

  Future<void> _addNewResume(
    String path, {
    List<String> skills = const [],
  }) async {
    final separator = path.contains('\\') ? '\\' : '/';
    final name = path.split(separator).last;

    for (final resume in _resumes) {
      resume.isDefault = false;
    }

    _resumes.insert(
      0,
      ResumeFile(name: name, path: path, isDefault: true, skills: skills),
    );

    await _persistResumes();
    if (!mounted) return;
    setState(() {});
  }

  List<String> _extractParsedSkills(Map<String, dynamic> analysis) {
    final parsedResume = analysis['parsedResume'];
    if (parsedResume is! Map) return [];

    final rawSkills = parsedResume['skills'];
    if (rawSkills is! List) return [];

    return rawSkills.map((item) => item.toString()).toList();
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    final selectedPath = result.files.single.path!;

    setState(() => _isLoading = true);
    try {
      final analysis = await ResumeAiService.instance.analyzeResume(
        filePath: selectedPath,
      );
      final parsedSkills = _extractParsedSkills(analysis);
      await _addNewResume(selectedPath, skills: parsedSkills);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            parsedSkills.isEmpty
                ? 'Resume uploaded and parsed.'
                : 'Resume uploaded. Parsed skills: ${parsedSkills.take(5).join(', ')}',
          ),
        ),
      );
    } on DioException catch (error) {
      if (!mounted) return;
      final statusCode = error.response?.statusCode;
      final message = statusCode == 400
          ? 'Unsupported or invalid resume file.'
          : 'Failed to parse resume. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload resume')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _setDefault(ResumeFile resume) async {
    for (final r in _resumes) {
      r.isDefault = false;
    }
    resume.isDefault = true;

    await _persistResumes();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _deleteResume(ResumeFile resume) async {
    _resumes.remove(resume);

    if (_resumes.isNotEmpty && !_resumes.any((r) => r.isDefault)) {
      _resumes.first.isDefault = true;
    }

    await _persistResumes();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _analyzeResume() async {
    final defaultResume = _resumes.where((r) => r.isDefault).toList();

    if (defaultResume.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No default resume selected')),
      );
      return;
    }

    final resume = defaultResume.first;

    setState(() => _isLoading = true);
    try {
      final analysis = await ResumeAiService.instance.analyzeResume(
        filePath: resume.path,
      );

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/analysis_results',
        arguments: {
          'resume': resume.toMap(),
          'analysis': analysis,
        },
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI analysis failed. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Resumes',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create with Resume Builder'),
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/resume_builder',
                );
                if (result is Map) {
                  await _addNewResume(
                    result['path'],
                    skills: List<String>.from(result['skills'] ?? []),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload New Resume'),
              onPressed: _isLoading ? null : _pickResume,
            ),
            const Divider(height: 30),
            const Text(
              'Your Resumes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _resumes.length,
                itemBuilder: (_, i) {
                  final r = _resumes[i];
                  return Card(
                    color: r.isDefault ? Colors.blue[50] : null,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.description, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  r.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteResume(r),
                              ),
                            ],
                          ),
                          if (r.isDefault)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'Default',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          if (r.skills.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: r.skills
                                  .map(
                                    (s) => Chip(
                                      label: Text(s),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          if (!r.isDefault)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => _setDefault(r),
                                child: const Text('Set Default'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.insights, color: Colors.white),
                label: Text(
                  _isLoading ? 'Processing...' : 'Run AI Analysis on Default',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: _isLoading ? null : _analyzeResume,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

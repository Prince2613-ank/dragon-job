import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'manage_resume_screen.dart'; // ResumeFile model

class AnalysisResultsScreen extends StatefulWidget {
  const AnalysisResultsScreen({super.key});

  @override
  State<AnalysisResultsScreen> createState() => _AnalysisResultsScreenState();
}

class _AnalysisResultsScreenState extends State<AnalysisResultsScreen> {
  // ================= DATA =================
  late ResumeFile resume;

  final List<String> requiredSkills = [
    'Flutter',
    'Dart',
    'Firebase',
    'Python',
    'AI/ML',
    'C++',
    'Java',
    'GCP',
    'Project Management',
  ];

  List<String> matched = [];
  List<String> missing = [];
  int matchScore = 0;
  int profileCompletion = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ Get full resume object
    resume = ModalRoute.of(context)!.settings.arguments as ResumeFile;

    _runAnalysis();
  }

  // ================= ANALYSIS =================
  Future<void> _runAnalysis() async {
    matched.clear();
    missing.clear();

    for (final skill in requiredSkills) {
      if (resume.skills.any((s) => s.toLowerCase() == skill.toLowerCase())) {
        matched.add(skill);
      } else {
        missing.add(skill);
      }
    }

    matchScore = ((matched.length / requiredSkills.length) * 100).round();

    // ================= PROFILE COMPLETION =================
    profileCompletion = 0;

    if (resume.skills.isNotEmpty) profileCompletion += 30;
    if (matched.isNotEmpty) profileCompletion += 30;
    if (matchScore > 0) profileCompletion += 40;

    await _persistAnalysis();

    setState(() {});
  }

  // ================= SAVE RESULT =================
  Future<void> _persistAnalysis() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('last_resume_score', matchScore);
    await prefs.setInt('profile_completion', profileCompletion);
    await prefs.setStringList('last_matched_skills', matched);
    await prefs.setStringList('last_missing_skills', missing);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Analysis Results",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= SCORE =================
            Text(
              "Job Match Score: $matchScore%",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: matchScore >= 70 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: matchScore / 100,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              color: matchScore >= 70 ? Colors.green : Colors.orange,
            ),

            const SizedBox(height: 30),

            // ================= MATCHED =================
            const Text(
              "Skills Found",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: matched.isNotEmpty
                  ? matched
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
                        "No matching skills found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
            ),

            const SizedBox(height: 25),

            // ================= MISSING =================
            const Text(
              "Skills Missing",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: missing.isNotEmpty
                  ? missing
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
                        "Great! No missing skills 🎉",
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
            ),

            const Spacer(),

            // ================= PROFILE SCORE =================
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
                      "Profile Completion",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$profileCompletion%",
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

// FILE: lib/screens/analysis_results_screen.dart

import 'package:flutter/material.dart';

class AnalysisResultsScreen extends StatelessWidget {
  const AnalysisResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for the report
    double matchScore = 0.92; // 92%
    List<String> keywordsFound = ['Flutter', 'Python', 'AI/ML', 'Firebase'];
    List<String> keywordsMissing = ['GCP', 'Project Management'];

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Job Match Score: 92%",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: matchScore,
              minHeight: 12,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: Colors.grey[300],
              color: Colors.green[700],
            ),
            const Divider(height: 32),
            _buildKeywordSection("Keywords Found", keywordsFound, Colors.blue),
            const SizedBox(height: 16),
            _buildKeywordSection(
              "Keywords Missing",
              keywordsMissing,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeywordSection(
    String title,
    List<String> keywords,
    Color chipColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: keywords.map((skill) {
            return Chip(
              label: Text(skill),
              backgroundColor: chipColor.withOpacity(0.1),
              labelStyle: TextStyle(color: chipColor),
            );
          }).toList(),
        ),
      ],
    );
  }
}

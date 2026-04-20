// FILE: lib/screens/recommended_jobs_screen.dart

import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'job_details_screen.dart';

class RecommendedJobsScreen extends StatefulWidget {
  const RecommendedJobsScreen({super.key});

  @override
  State<RecommendedJobsScreen> createState() => _RecommendedJobsScreenState();
}

class _RecommendedJobsScreenState extends State<RecommendedJobsScreen> {
  List<AdminPost> _recommendedJobs = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendedJobs();
  }

  Future<void> _loadRecommendedJobs() async {
    final jobs = await DatabaseHelper.instance.getPostsByType('job');
    setState(() {
      _recommendedJobs = jobs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Recommended Jobs",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: _recommendedJobs.isEmpty
          ? const Center(
              child: Text(
                "No recommended jobs available",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _recommendedJobs.length,
              itemBuilder: (context, index) {
                return _buildJobCard(
                  context: context,
                  post: _recommendedJobs[index],
                );
              },
            ),
    );
  }

  // ================= JOB CARD =================
  Widget _buildJobCard({
    required BuildContext context,
    required AdminPost post,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => JobDetailsScreen(post: post)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Icon(Icons.work, size: 40, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.role,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.company,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.location,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Salary: ${post.salary}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

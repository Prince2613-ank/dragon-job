// FILE: lib/screens/saved_jobs_screen.dart

import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'job_details_screen.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  late Future<List<Job>> _savedJobsFuture;

  @override
  void initState() {
    super.initState();
    _loadSavedJobs();
  }

  void _loadSavedJobs() {
    setState(() {
      _savedJobsFuture = DatabaseHelper.instance.getAllSavedJobs();
    });
  }

  Future<void> _removeJob(Job job) async {
    if (job.id == null) return;
    await DatabaseHelper.instance.deleteJob(job.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job removed from saved list.')),
    );
    _loadSavedJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Jobs", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<Job>>(
        future: _savedJobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No saved jobs",
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final savedJobs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: savedJobs.length,
            itemBuilder: (context, index) {
              return _buildJobCard(context: context, job: savedJobs[index]);
            },
          );
        },
      ),
    );
  }

  // ================= JOB CARD =================
  Widget _buildJobCard({required BuildContext context, required Job job}) {
    Map<String, IconData> iconMap = {
      "android": Icons.android,
      "business": Icons.business,
      "design_services": Icons.design_services,
      "computer": Icons.computer,
      "storage": Icons.storage,
      "school": Icons.school,
      "work": Icons.work,
    };

    IconData logo = iconMap[job.logo] ?? Icons.work;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          // 🔥 Convert Job → AdminPost (runtime mapping)
          final post = AdminPost(
            id: job.postId,
            postType: 'job',
            role: job.title,
            company: job.company,
            salary: 'N/A',
            location: job.location,
            description: 'Saved job from your list',
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => JobDetailsScreen(post: post)),
          ).then((_) => _loadSavedJobs());
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(logo, size: 40, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.company,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.location,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.blue),
                tooltip: "Remove from saved",
                onPressed: () {
                  _removeJob(job);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

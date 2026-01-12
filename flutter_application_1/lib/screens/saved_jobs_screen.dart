// FILE: lib/screens/saved_jobs_screen.dart

import 'package:flutter/material.dart';
import '../helpers/database_helper.dart'; // Import DB helper and Job model
import 'job_details_screen.dart'; // Import Job Details screen

// 1. Convert to StatefulWidget
class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  // 2. Use a FutureBuilder to handle loading state
  late Future<List<Job>> _savedJobsFuture;

  @override
  void initState() {
    super.initState();
    // 3. Load the jobs when the screen is first built
    _loadSavedJobs();
  }

  // 4. Function to fetch jobs from the database
  void _loadSavedJobs() {
    setState(() {
      _savedJobsFuture = DatabaseHelper.instance.getAllSavedJobs();
    });
  }

  // 5. Function to remove a job (will be called from the card)
  Future<void> _removeJob(int id) async {
    await DatabaseHelper.instance.deleteJob(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job removed from saved list.')),
    );
    // Refresh the list
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
      // 6. Use FutureBuilder to build the UI based on the database call
      body: FutureBuilder<List<Job>>(
        future: _savedJobsFuture,
        builder: (context, snapshot) {
          // --- LOADING STATE ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // --- ERROR STATE ---
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          // --- EMPTY STATE ---
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

          // --- SUCCESS STATE (Data is loaded) ---
          final savedJobs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: savedJobs.length,
            itemBuilder: (context, index) {
              final job = savedJobs[index];
              return _buildJobCard(context: context, job: job);
            },
          );
        },
      ),
    );
  }

  // 7. Re-usable Job Card widget
  Widget _buildJobCard({required BuildContext context, required Job job}) {
    // Simple icon mapping
    Map<String, IconData> iconMap = {
      "android": Icons.android,
      "business": Icons.business,
      "design_services": Icons.design_services,
      "computer": Icons.computer,
      "storage": Icons.storage,
      "school": Icons.school,
    };
    IconData logo = iconMap[job.logo] ?? Icons.work;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          // When tapping a saved job, go to details and refresh when we come back
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JobDetailsScreen(job: job)),
          ).then((_) => _loadSavedJobs()); // Refresh the list when returning
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
              // 8. Add a "remove" button
              IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.blue),
                tooltip: "Remove from saved",
                onPressed: () {
                  _removeJob(job.id!);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

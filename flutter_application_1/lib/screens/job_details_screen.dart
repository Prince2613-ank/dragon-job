// FILE: lib/screens/job_details_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/database_helper.dart'; // Import your helpers

class JobDetailsScreen extends StatefulWidget {
  final Job job; // This screen will accept a Job object

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isSaved = false;
  bool _isApplied = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  // Check if the job is already in the database
  void _checkIfSaved() async {
    final allJobs = await DatabaseHelper.instance.getAllSavedJobs();
    // Check for a job with the same title AND company
    setState(() {
      _isSaved = allJobs.any(
        (job) =>
            job.title == widget.job.title && job.company == widget.job.company,
      );
    });
  }

  // Toggle the save state
  void _toggleSave() async {
    if (_isSaved) {
      // --- REMOVE JOB ---
      final allJobs = await DatabaseHelper.instance.getAllSavedJobs();
      Job? jobToDelete;
      // Find the specific job in the DB
      for (var job in allJobs) {
        if (job.title == widget.job.title &&
            job.company == widget.job.company) {
          jobToDelete = job;
          break;
        }
      }
      // If we found it, delete it by its unique ID
      if (jobToDelete != null) {
        await DatabaseHelper.instance.deleteJob(jobToDelete.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job removed from saved list.')),
        );
      }
      setState(() {
        _isSaved = false;
      });
    } else {
      // --- ADD JOB ---
      await DatabaseHelper.instance.insertJob(widget.job);
      setState(() {
        _isSaved = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job saved!')));
    }
  }

  // Handle the Apply button
  void _applyForJob() async {
    final prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt('jobsAppliedCount') ?? 0;
    currentCount++;
    await prefs.setInt('jobsAppliedCount', currentCount);

    setState(() {
      _isApplied = true;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Application submitted!')));
  }

  @override
  Widget build(BuildContext context) {
    final saveIcon = Icon(
      _isSaved ? Icons.bookmark : Icons.bookmark_border,
      color: Colors.white,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job.company, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [IconButton(icon: saveIcon, onPressed: _toggleSave)],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.android,
                        size: 60,
                        color: Colors.blue,
                      ), // Placeholder
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.job.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.job.company,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              widget.job.location,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Job Description
                  Text(
                    "About this job",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Apply Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isApplied ? Colors.grey : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isApplied ? null : _applyForJob,
                child: Text(
                  _isApplied ? "Applied" : "Apply Now",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

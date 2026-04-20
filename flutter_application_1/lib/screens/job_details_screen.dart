// FILE: lib/screens/job_details_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/database_helper.dart';

class JobDetailsScreen extends StatefulWidget {
  final AdminPost post; // 🔥 ADMIN POST

  const JobDetailsScreen({super.key, required this.post});

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

  // ================= SAVE CHECK =================
  void _checkIfSaved() async {
    final allJobs = await DatabaseHelper.instance.getAllSavedJobs();
    setState(() {
      _isSaved = allJobs.any((job) {
        if (widget.post.id != null && job.postId != null) {
          return job.postId == widget.post.id;
        }
        return job.title == widget.post.role && job.company == widget.post.company;
      });
    });
  }

  // ================= SAVE / UNSAVE =================
  void _toggleSave() async {
    if (_isSaved) {
      await DatabaseHelper.instance.deleteSavedJobForPost(widget.post);

      setState(() => _isSaved = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job removed from saved list')),
      );
    } else {
      // 🔥 Convert AdminPost → Job for saved jobs
      final job = Job(
        postId: widget.post.id,
        title: widget.post.role,
        company: widget.post.company,
        location: widget.post.location,
        logo: 'work',
      );

      await DatabaseHelper.instance.insertJob(job);

      setState(() => _isSaved = true);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job saved successfully')));
    }
  }

  // ================= APPLY =================
  void _applyForJob() async {
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt('jobsAppliedCount') ?? 0;
    await prefs.setInt('jobsAppliedCount', count + 1);

    setState(() => _isApplied = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application submitted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.post.company,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            onPressed: _toggleSave,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= HEADER =================
                  Row(
                    children: [
                      const Icon(Icons.work, size: 60, color: Colors.blue),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.role,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.post.company,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              widget.post.location,
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

                  // ================= SALARY =================
                  Text(
                    "Compensation",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.post.salary,
                    style: const TextStyle(fontSize: 16),
                  ),

                  const Divider(height: 32),

                  // ================= DESCRIPTION =================
                  Text(
                    "About this role",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.post.description,
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

          // ================= APPLY BUTTON =================
          Container(
            padding: const EdgeInsets.all(16),
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

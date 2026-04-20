import 'package:flutter/material.dart';

import '../helpers/applied_jobs_helper.dart';
import '../helpers/database_helper.dart';
import 'job_details_screen.dart';

class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({super.key});

  @override
  State<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  late Future<List<AdminPost>> _appliedJobsFuture;

  @override
  void initState() {
    super.initState();
    _appliedJobsFuture = _loadAppliedJobs();
  }

  Future<List<AdminPost>> _loadAppliedJobs() async {
    final appliedIds = await AppliedJobsHelper.instance.getAppliedPostIds();

    if (appliedIds.isEmpty) return [];

    final allPosts = await DatabaseHelper.instance.getAllAdminPosts();
    return allPosts
        .where((post) => post.id != null && appliedIds.contains(post.id))
        .toList();
  }

  Future<void> _refresh() async {
    final jobs = await _loadAppliedJobs();
    if (!mounted) return;
    setState(() {
      _appliedJobsFuture = Future.value(jobs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Applied Jobs',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<AdminPost>>(
        future: _appliedJobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load applied jobs',
                style: TextStyle(color: Colors.red.shade700),
              ),
            );
          }

          final jobs = snapshot.data ?? [];
          if (jobs.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 140),
                  Icon(Icons.assignment_outlined, size: 72, color: Colors.grey),
                  SizedBox(height: 14),
                  Center(
                    child: Text(
                      'You have not applied to any jobs yet.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final post = jobs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text(post.role),
                    subtitle: Text('${post.company} - ${post.location}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobDetailsScreen(post: post),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

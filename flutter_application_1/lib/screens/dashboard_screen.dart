import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/database_helper.dart';
import 'job_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int profileCompletion = 0;
  int resumeScore = 0;
  int jobsApplied = 0;

  List<AdminPost> recommendedPosts = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDashboardData(); // refresh when returning
  }

  // ================= LOAD DATA =================
  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();

    profileCompletion = prefs.getInt('profile_completion') ?? 0;
    resumeScore = prefs.getInt('last_resume_score') ?? 0;
    jobsApplied = prefs.getInt('jobsAppliedCount') ?? 0;

    recommendedPosts = await DatabaseHelper.instance.getAllAdminPosts();

    setState(() {});
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildProfileCompletion(),
            const SizedBox(height: 20),
            _buildAiCard(context),
            const SizedBox(height: 20),
            _buildStats(),
            const SizedBox(height: 30),
            _buildRecommended(context),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Welcome back!",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6),
        Text(
          "Find your perfect job today.",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // ================= PROFILE COMPLETION =================
  Widget _buildProfileCompletion() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Profile Completion: $profileCompletion%",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: profileCompletion / 100,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }

  // ================= AI CARD =================
  Widget _buildAiCard(BuildContext context) {
    return Card(
      color: Colors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.insights, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "AI Resume Matching",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Resume Score: $resumeScore%",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/manage_resume');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                    ),
                    child: const Text("Analyze Now"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= STATS =================
  Widget _buildStats() {
    return Row(
      children: [
        _statCard(title: "Jobs Applied", value: jobsApplied.toString()),
        const SizedBox(width: 16),
        _statCard(title: "Resume Score", value: "$resumeScore%"),
      ],
    );
  }

  Widget _statCard({required String title, required String value}) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 6),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  // ================= RECOMMENDED =================
  Widget _buildRecommended(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recommended for You",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/recommended_jobs');
              },
              child: const Text("View All"),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (recommendedPosts.isEmpty) const Text("No jobs available right now"),

        ...recommendedPosts
            .take(3)
            .map(
              (post) => Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.work, color: Colors.blue),
                  title: Text(post.role),
                  subtitle: Text("${post.company} • ${post.location}"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JobDetailsScreen(post: post),
                      ),
                    );
                  },
                ),
              ),
            ),
      ],
    );
  }
}

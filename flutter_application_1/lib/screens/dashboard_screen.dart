// FILE: lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/database_helper.dart'; // Import Job model
import 'job_details_screen.dart'; // Import Job Details screen

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _jobsAppliedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadJobsAppliedCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadJobsAppliedCount();
  }

  Future<void> _loadJobsAppliedCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _jobsAppliedCount = prefs.getInt('jobsAppliedCount') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // We wrap the main column in a DefaultTabController
    return DefaultTabController(
      length: 3, // For the 3 tabs: Submitted, Review, Interviews
      child: Scaffold(
        backgroundColor: Colors.grey[100], // Light grey background
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Welcome Header
                Text(
                  "Welcome back, Prince!",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Find your perfect job today.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // 2. PROFILE COMPLETION BAR
                _buildProfileCompletion(),
                const SizedBox(height: 24),

                // 3. AI Resume Matcher Card
                _buildAiMatcherCard(context),
                const SizedBox(height: 24),

                // 4. Stats Overview
                _buildStatsOverview(),
                const SizedBox(height: 24),

                // 5. APPLICATION STATUS TRACKER
                _buildApplicationTracker(),
                const SizedBox(height: 24),

                // 6. Recommended Jobs Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recommended for You",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // *** THIS IS THE FIX ***
                        Navigator.pushNamed(context, '/recommended_jobs');
                      },
                      child: const Text(
                        "View All",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 7. Job List
                _buildJobCard(
                  job: Job(
                    logo: "android",
                    title: "Flutter Developer",
                    company: "Google",
                    location: "Mountain View, CA",
                  ),
                ),
                _buildJobCard(
                  job: Job(
                    logo: "business",
                    title: "Backend Engineer (Django)",
                    company: "TechCorp",
                    location: "Remote",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildProfileCompletion() {
    double completion = 0.7; // 70%
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Profile Completion: 70%",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: completion,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            Text(
              "Complete your profile to get better job matches!",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationTracker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "My Applications",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: TabBar(
            indicator: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black54,
            tabs: const [
              Tab(text: "Submitted (15)"),
              Tab(text: "In Review (4)"),
              Tab(text: "Interviews (1)"),
            ],
          ),
        ),
        SizedBox(
          height: 150, // Give the content area a fixed height
          child: TabBarView(
            children: [
              Center(child: Text("Showing 15 Submitted Applications")),
              Center(child: Text("Showing 4 Applications In Review")),
              Center(child: Text("Showing 1 Upcoming Interview")),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAiMatcherCard(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.blue,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const Icon(Icons.insights, size: 40, color: Colors.white),
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
                  const SizedBox(height: 4),
                  const Text(
                    "Upload your resume to get AI-powered job recommendations.",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/manage_resume');
                    },
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

  Widget _buildStatsOverview() {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$_jobsAppliedCount",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Jobs Applied",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "8",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Profile Views",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper for Job Card
  Widget _buildJobCard({required Job job}) {
    IconData logo = job.logo == "android" ? Icons.android : Icons.business;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JobDetailsScreen(job: job)),
          ).then((_) => _loadJobsAppliedCount());
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
                      style: TextStyle(
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
              Icon(Icons.bookmark_border, color: Colors.grey[500]),
            ],
          ),
        ),
      ),
    );
  }
}

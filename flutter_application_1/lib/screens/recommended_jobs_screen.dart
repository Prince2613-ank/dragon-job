// FILE: lib/screens/recommended_jobs_screen.dart

import 'package:flutter/material.dart';
import '../helpers/database_helper.dart'; // Import Job model
import 'job_details_screen.dart'; // Import Job Details screen

class RecommendedJobsScreen extends StatelessWidget {
  const RecommendedJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We create a dummy list of jobs here
    final List<Job> recommendedJobs = [
      Job(
        logo: "android",
        title: "Flutter Developer",
        company: "Google",
        location: "Mountain View, CA",
      ),
      Job(
        logo: "business",
        title: "Backend Engineer (Django)",
        company: "TechCorp",
        location: "Remote",
      ),
      Job(
        logo: "design_services",
        title: "UI/UX Designer",
        company: "Creative Inc.",
        location: "New York, NY",
      ),
      Job(
        logo: "computer",
        title: "AI/ML Engineer",
        company: "Data Future",
        location: "Remote",
      ),
      Job(
        logo: "android",
        title: "Junior Flutter Developer",
        company: "Startup Hub",
        location: "Austin, TX",
      ),
    ];

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
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: recommendedJobs.length,
        itemBuilder: (context, index) {
          return _buildJobCard(context: context, job: recommendedJobs[index]);
        },
      ),
    );
  }

  // We copy the same _buildJobCard helper for consistency
  Widget _buildJobCard({required BuildContext context, required Job job}) {
    // Simple icon mapping
    Map<String, IconData> iconMap = {
      "android": Icons.android,
      "business": Icons.business,
      "design_services": Icons.design_services,
      "computer": Icons.computer,
    };
    IconData logo = iconMap[job.logo] ?? Icons.work;

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
          );
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
              Icon(Icons.bookmark_border, color: Colors.grey[500]),
            ],
          ),
        ),
      ),
    );
  }
}

// FILE: lib/screens/jobs_screen.dart

import 'package:flutter/material.dart';
import '../helpers/database_helper.dart'; // Import Job model
import 'job_details_screen.dart'; // Import Job Details screen

// 1. Convert to StatefulWidget
class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  // 2. Define our state variables
  final TextEditingController _searchController = TextEditingController();

  // This is our master list of jobs
  final List<Job> _allJobs = [
    Job(
      logo: "android",
      title: "Senior Flutter Developer",
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
      title: "Data Scientist (AI/ML)",
      company: "Future AI",
      location: "Boston, MA",
    ),
    Job(
      logo: "storage",
      title: "PostgreSQL DBA",
      company: "DataStax",
      location: "Remote",
    ),
    Job(
      logo: "android",
      title: "Junior Flutter Developer",
      company: "Startup Hub",
      location: "Austin, TX",
    ),
  ];

  // This is the list that will be displayed on screen
  List<Job> _displayedJobs = [];

  // Sort state
  bool _isSortedAscending = true;

  @override
  void initState() {
    super.initState();
    // Initially, the displayed list is the full list
    _displayedJobs = _allJobs;
    // Add a listener to the search controller
    _searchController.addListener(_filterJobs);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterJobs);
    _searchController.dispose();
    super.dispose();
  }

  // 3. Create the filter/search function
  void _filterJobs() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _displayedJobs = _allJobs.where((job) {
        // Simple search logic
        final titleMatch = job.title.toLowerCase().contains(query);
        final companyMatch = job.company.toLowerCase().contains(query);
        return titleMatch || companyMatch;
      }).toList();

      // Apply sorting
      _sortJobs();
    });
  }

  // 4. Create the sort function
  void _sortJobs() {
    setState(() {
      if (_isSortedAscending) {
        _displayedJobs.sort((a, b) => a.title.compareTo(b.title)); // A-Z
      } else {
        _displayedJobs.sort((a, b) => b.title.compareTo(a.title)); // Z-A
      }
      _isSortedAscending = !_isSortedAscending; // Toggle for next tap
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background
      body: Column(
        children: [
          // 1. Search and Filter Bar
          _buildSearchAndFilterBar(context),

          // 2. Scrollable List of Jobs
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _displayedJobs.length, // Use the displayed list
              itemBuilder: (context, index) {
                return _buildJobCard(
                  context: context,
                  job: _displayedJobs[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Search Bar
  Widget _buildSearchAndFilterBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: TextField(
              controller: _searchController, // 5. Connect the controller
              decoration: InputDecoration(
                hintText: "Search for jobs...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 6. ADD THE SORT BUTTON
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
            ),
            icon: Icon(Icons.sort_by_alpha, color: Colors.blue),
            onPressed: _sortJobs, // Call the sort function
          ),
          const SizedBox(width: 10),

          // 7. UPDATE THE FILTER BUTTON
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
            ),
            icon: const Icon(Icons.filter_list, color: Colors.blue),
            onPressed: () {
              // Open the new full-page filter screen
              Navigator.pushNamed(context, '/filters');
              // In a real app, you'd use .then() to get data back
              // and then call _filterJobs()
            },
          ),
        ],
      ),
    );
  }

  // Helper Widget for a single Job Card
  Widget _buildJobCard({required BuildContext context, required Job job}) {
    Map<String, IconData> iconMap = {
      "android": Icons.android,
      "business": Icons.business,
      "design_services": Icons.design_services,
      "computer": Icons.computer,
      "storage": Icons.storage,
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

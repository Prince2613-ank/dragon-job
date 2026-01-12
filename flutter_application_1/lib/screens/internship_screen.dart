// FILE: lib/screens/internship_screen.dart

import 'package:flutter/material.dart';
import '../helpers/database_helper.dart'; // Import Job model
import 'job_details_screen.dart'; // Import Job Details screen

// 1. Convert to StatefulWidget
class InternshipScreen extends StatefulWidget {
  const InternshipScreen({super.key});

  @override
  State<InternshipScreen> createState() => _InternshipScreenState();
}

class _InternshipScreenState extends State<InternshipScreen> {
  // 2. Define our state variables
  final TextEditingController _searchController = TextEditingController();

  // This is our master list of internships
  final List<Job> _allInternships = [
    Job(
      logo: "school",
      title: "Flutter Developer Intern",
      company: "Google",
      location: "Remote (Summer 2026)",
    ),
    Job(
      logo: "computer",
      title: "AI/ML Intern",
      company: "Future AI",
      location: "Boston, MA",
    ),
    Job(
      logo: "design_services",
      title: "UI/UX Design Intern",
      company: "Creative Inc.",
      location: "New York, NY",
    ),
    Job(
      logo: "business",
      title: "Backend Intern (Django)",
      company: "TechCorp",
      location: "Remote",
    ),
  ];

  // This is the list that will be displayed on screen
  List<Job> _displayedInternships = [];

  // Sort state
  bool _isSortedAscending = true;

  @override
  void initState() {
    super.initState();
    // Initially, the displayed list is the full list
    _displayedInternships = _allInternships;
    // Add a listener to the search controller
    _searchController.addListener(_filterInternships);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterInternships);
    _searchController.dispose();
    super.dispose();
  }

  // 3. Create the filter/search function
  void _filterInternships() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _displayedInternships = _allInternships.where((internship) {
        // Simple search logic
        final titleMatch = internship.title.toLowerCase().contains(query);
        final companyMatch = internship.company.toLowerCase().contains(query);
        return titleMatch || companyMatch;
      }).toList();

      // Apply sorting
      _sortInternships();
    });
  }

  // 4. Create the sort function
  void _sortInternships() {
    setState(() {
      if (_isSortedAscending) {
        _displayedInternships.sort((a, b) => a.title.compareTo(b.title)); // A-Z
      } else {
        _displayedInternships.sort((a, b) => b.title.compareTo(a.title)); // Z-A
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
          // 1. Search, Sort, and Filter Bar
          _buildSearchAndFilterBar(context),

          // 2. Scrollable List of Internships
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _displayedInternships.length, // Use the displayed list
              itemBuilder: (context, index) {
                return _buildInternshipCard(
                  context: context,
                  internship: _displayedInternships[index],
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
                hintText: "Search for internships...",
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
            onPressed: _sortInternships, // Call the sort function
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
              // Open the full-page filter screen
              Navigator.pushNamed(context, '/filters');
            },
          ),
        ],
      ),
    );
  }

  // Helper Widget for a single Internship Card
  Widget _buildInternshipCard({
    required BuildContext context,
    required Job internship, // Use the Job model
  }) {
    // Simple icon mapping
    Map<String, IconData> iconMap = {
      "school": Icons.school,
      "computer": Icons.computer,
      "design_services": Icons.design_services,
      "business": Icons.business,
    };
    IconData logo = iconMap[internship.logo] ?? Icons.work;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          // Navigate to the JobDetailsScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailsScreen(job: internship),
            ),
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
                      internship.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      internship.company,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      internship.location,
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

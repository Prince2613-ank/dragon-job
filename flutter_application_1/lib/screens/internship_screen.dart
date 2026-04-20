// FILE: lib/screens/internship_screen.dart

import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'job_details_screen.dart';

class InternshipScreen extends StatefulWidget {
  const InternshipScreen({super.key});

  @override
  State<InternshipScreen> createState() => _InternshipScreenState();
}

class _InternshipScreenState extends State<InternshipScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<AdminPost> _allInternships = [];
  List<AdminPost> _displayedInternships = [];

  bool _isSortedAscending = true;

  @override
  void initState() {
    super.initState();
    _loadInternships();
    _searchController.addListener(_filterInternships);
  }

  Future<void> _loadInternships() async {
    final internships = await DatabaseHelper.instance.getPostsByType(
      'internship',
    );

    setState(() {
      _allInternships = internships;
      _displayedInternships = internships;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterInternships);
    _searchController.dispose();
    super.dispose();
  }

  // ================= SEARCH =================
  void _filterInternships() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _displayedInternships = _allInternships.where((internship) {
        return internship.role.toLowerCase().contains(query) ||
            internship.company.toLowerCase().contains(query);
      }).toList();
    });
  }

  // ================= SORT =================
  void _sortInternships() {
    setState(() {
      if (_isSortedAscending) {
        _displayedInternships.sort((a, b) => a.role.compareTo(b.role)); // A-Z
      } else {
        _displayedInternships.sort((a, b) => b.role.compareTo(a.role)); // Z-A
      }
      _isSortedAscending = !_isSortedAscending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildSearchAndFilterBar(context),

          Expanded(
            child: _displayedInternships.isEmpty
                ? const Center(
                    child: Text(
                      "No internships available",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _displayedInternships.length,
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

  // ================= SEARCH / FILTER BAR =================
  Widget _buildSearchAndFilterBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search for internships...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),

          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.sort_by_alpha, color: Colors.blue),
            onPressed: _sortInternships,
          ),
          const SizedBox(width: 10),

          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.filter_list, color: Colors.blue),
            onPressed: () {
              Navigator.pushNamed(context, '/filters');
            },
          ),
        ],
      ),
    );
  }

  // ================= INTERNSHIP CARD =================
  Widget _buildInternshipCard({
    required BuildContext context,
    required AdminPost internship,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JobDetailsScreen(post: internship),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Icon(Icons.school, size: 40, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      internship.role,
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
                    const SizedBox(height: 4),
                    Text(
                      "Stipend: ${internship.salary}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// FILE: lib/screens/jobs_screen.dart

import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'job_details_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<AdminPost> _allJobs = [];
  List<AdminPost> _displayedJobs = [];

  bool _isSortedAscending = true;

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _searchController.addListener(_filterJobs);
  }

  Future<void> _loadJobs() async {
    final jobs = await DatabaseHelper.instance.getPostsByType('job');
    setState(() {
      _allJobs = jobs;
      _displayedJobs = jobs;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterJobs);
    _searchController.dispose();
    super.dispose();
  }

  // ================= SEARCH =================
  void _filterJobs() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _displayedJobs = _allJobs.where((job) {
        return job.role.toLowerCase().contains(query) ||
            job.company.toLowerCase().contains(query);
      }).toList();
    });
  }

  // ================= SORT =================
  void _sortJobs() {
    setState(() {
      if (_isSortedAscending) {
        _displayedJobs.sort((a, b) => a.role.compareTo(b.role)); // A-Z
      } else {
        _displayedJobs.sort((a, b) => b.role.compareTo(a.role)); // Z-A
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
            child: _displayedJobs.isEmpty
                ? const Center(
                    child: Text(
                      "No jobs available",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _displayedJobs.length,
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
                hintText: "Search for jobs...",
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
            onPressed: _sortJobs,
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

  // ================= JOB CARD =================
  Widget _buildJobCard({
    required BuildContext context,
    required AdminPost job,
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
            MaterialPageRoute(builder: (_) => JobDetailsScreen(post: job)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Icon(Icons.work, size: 40, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.role,
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
                    const SizedBox(height: 4),
                    Text(
                      "Salary: ${job.salary}",
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

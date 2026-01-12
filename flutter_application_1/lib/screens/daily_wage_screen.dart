// FILE: lib/screens/daily_wage_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:shared_preferences/shared_preferences.dart'; // 1. IMPORT
import 'service_details_screen.dart';

class DailyWageScreen extends StatefulWidget {
  const DailyWageScreen({super.key});

  @override
  State<DailyWageScreen> createState() => _DailyWageScreenState();
}

class _DailyWageScreenState extends State<DailyWageScreen> {
  bool _isMapView = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/post_job');
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, color: Colors.white),
          tooltip: "Post a Job",
        ),

        body: Column(
          children: [
            _buildSearchAndFilterBar(context),

            Container(
              color: Colors.white,
              child: const TabBar(
                tabs: [
                  Tab(text: "Find Services"),
                  Tab(text: "Find Job Postings"),
                ],
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [_buildServicesTab(), _buildCustomerJobsTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS FOR TAB 1 (SERVICES) ---

  Widget _buildServicesTab() {
    return _buildListView();
  }

  Widget _buildSearchAndFilterBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search for services...",
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
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
            ),
            icon: Icon(_isMapView ? Icons.list : Icons.map, color: Colors.blue),
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildServiceCard(
          icon: Icons.content_cut,
          title: "Barber",
          location: "Nearby",
          rating: 5.0,
          workHistory: ["Men's Haircut", "Beard Trim"],
        ),
        _buildServiceCard(
          icon: Icons.electrical_services,
          title: "Electrician",
          location: "On-demand",
          rating: 4.0,
          workHistory: ["Fix ceiling fan", "New wiring installation"],
        ),
        _buildServiceCard(
          icon: Icons.plumbing,
          title: "Plumber",
          location: "On-demand",
          rating: 4.5,
          workHistory: ["Fixed leaky sink", "Install new toilet"],
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String location,
    required double rating,
    required List<String> workHistory,
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
              builder: (context) => ServiceDetailsScreen(
                title: title,
                icon: icon,
                rating: rating,
                workHistory: workHistory,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    RatingBar.builder(
                      initialRating: rating,
                      itemCount: 5,
                      itemSize: 16,
                      itemBuilder: (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) {},
                      ignoreGestures: true,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[500]),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS FOR TAB 2 (CUSTOMER JOBS) ---

  Widget _buildCustomerJobsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 2. PASS THE SKILL
        _buildCustomerJobCard(
          title: "Need plumber to fix leaky sink",
          location: "Malviya Nagar",
          time: "Posted 2h ago",
          skill: "Plumber",
        ),
        _buildCustomerJobCard(
          title: "Looking for part-time driver",
          location: "Saket",
          time: "Posted 5h ago",
          skill: "Driver",
        ),
        _buildCustomerJobCard(
          title: "Electrician needed for new wiring",
          location: "Hauz Khas",
          time: "Posted 1d ago",
          skill: "Electrician",
        ),
      ],
    );
  }

  Widget _buildCustomerJobCard({
    required String title,
    required String location,
    required String time,
    required String skill, // 3. ACCEPT THE SKILL
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[50],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // 4. MAKE BUTTON ASYNC
                onPressed: () async {
                  // 5. SAVE THE SKILL TO SHARED PREFERENCES
                  final prefs = await SharedPreferences.getInstance();
                  // Get the current list
                  List<String> currentSkills =
                      prefs.getStringList('mySkills') ?? [];
                  // Add the new skill (if it's not already there)
                  if (!currentSkills.contains(skill)) {
                    currentSkills.add(skill);
                    await prefs.setStringList('mySkills', currentSkills);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Job complete! "$skill" added to your profile.',
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Mark as Complete",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// FILE: lib/screens/daily_wage_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/database_helper.dart';
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

        /// ADMIN POST BUTTON (UNCHANGED)
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
                children: [
                  _buildServicesTab(),
                  _buildCustomerJobsTab(), // 🔥 UPDATED
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TAB 1 (SERVICES) =================

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
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location),
            RatingBar.builder(
              initialRating: rating,
              itemCount: 5,
              itemSize: 16,
              ignoreGestures: true,
              itemBuilder: (_, __) =>
                  const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (_) {},
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceDetailsScreen(
                title: title,
                icon: icon,
                rating: rating,
                workHistory: workHistory,
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= TAB 2 (ADMIN DAILY WAGE POSTS) =================

  Widget _buildCustomerJobsTab() {
    return FutureBuilder<List<AdminPost>>(
      future: DatabaseHelper.instance.getPostsByType(
        'daily_wage',
      ), // 🔥 KEY LINE
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No daily wage jobs available"));
        }

        final posts = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return _buildCustomerJobCard(
              title: post.role,
              location: post.location,
              time: post.company,
              skill: post.role,
            );
          },
        );
      },
    );
  }

  Widget _buildCustomerJobCard({
    required String title,
    required String location,
    required String time,
    required String skill,
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
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Text(location),
              ],
            ),
            const SizedBox(height: 4),
            Text("Company: $time"),
            const SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[50],
                  elevation: 0,
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  List<String> skills = prefs.getStringList('mySkills') ?? [];

                  if (!skills.contains(skill)) {
                    skills.add(skill);
                    await prefs.setStringList('mySkills', skills);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Job completed! "$skill" added to profile'),
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

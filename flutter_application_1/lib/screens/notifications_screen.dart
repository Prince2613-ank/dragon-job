// FILE: lib/screens/notifications_screen.dart

import 'package:flutter/material.dart';

// 1. Create a data class for our notifications
class NotificationItem {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  final String? navigationRoute; // Route to navigate to on tap

  NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    this.navigationRoute,
  });
}

// 2. Convert to StatefulWidget
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // 3. Create the list of notifications
  List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // Helper to load our dummy notifications
  void _loadNotifications() {
    setState(() {
      _notifications = [
        NotificationItem(
          icon: Icons.work,
          color: Colors.blue,
          title: "New Job Matches!",
          body: "New jobs were posted for 'Flutter Developer'.",
          time: "10m ago",
          navigationRoute:
              '/main', // We can't go to 'Jobs' directly, so we go to '/main'
        ),
        NotificationItem(
          icon: Icons.visibility,
          color: Colors.green,
          title: "TechCorp viewed your profile",
          body: "Your profile was viewed by a recruiter from TechCorp.",
          time: "1h ago",
          navigationRoute: '/edit_profile', // Go to profile
        ),
        NotificationItem(
          icon: Icons.check_circle,
          color: Colors.blue,
          title: "Application Submitted",
          body: "Your application for 'Backend Engineer' was submitted.",
          time: "1d ago",
        ),
        NotificationItem(
          icon: Icons.person_pin,
          color: Colors.purple,
          title: "Profile Tip",
          body: "Complete your 'Skills' section to get 2x more views.",
          time: "2d ago",
          navigationRoute: '/edit_profile', // Go to profile
        ),
      ];
    });
  }

  // 4. Function to remove a single notification
  void _removeNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
  }

  // 5. Function to clear all notifications
  void _clearAllNotifications() {
    setState(() {
      _notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // 6. ADD THE "CLEAR ALL" BUTTON
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: "Clear All",
            onPressed: _clearAllNotifications,
          ),
        ],
      ),
      // 7. Handle the empty state
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No new notifications",
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final item = _notifications[index];

                // 8. ADD THE DISMISSIBLE WIDGET
                return Dismissible(
                  key: Key(item.title + item.time), // Unique key
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) {
                    _removeNotification(index);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: item.color,
                        child: Icon(item.icon, color: Colors.white),
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item.body),
                      trailing: Text(
                        item.time,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),

                      // 9. ADD THE ONTAP FUNCTIONALITY
                      onTap: () {
                        if (item.navigationRoute != null) {
                          // Check if the route is /main to handle tab navigation
                          if (item.navigationRoute == '/main') {
                            // Pop this screen and go to the main wrapper
                            Navigator.pop(context);
                            Navigator.pushReplacementNamed(context, '/main');
                            // This won't switch tabs, but it's a simple navigation
                          } else if (item.navigationRoute == '/edit_profile') {
                            Navigator.pushNamed(context, '/edit_profile');
                          }
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

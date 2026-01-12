// FILE: lib/screens/profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. IMPORT

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;

  // 2. Initialize skills as an empty list
  List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    // 3. Load skills from storage when the screen opens
    _loadSkills();
  }

  // 4. NEW FUNCTION to load skills
  Future<void> _loadSkills() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedSkills;

    // Check if 'mySkills' key exists
    if (prefs.containsKey('mySkills')) {
      // If it exists, load them
      savedSkills = prefs.getStringList('mySkills') ?? [];
    } else {
      // If not (first time app run), set the defaults
      savedSkills = ['Flutter', 'Python', 'Django', 'UI/UX Design', 'Firebase'];
      await prefs.setStringList('mySkills', savedSkills);
    }

    // Update the UI
    setState(() {
      _skills = savedSkills;
    });
  }

  // 5. NEW FUNCTION to save skills
  Future<void> _saveSkills() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mySkills', _skills);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text(
                "Prince Raj",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                "princeraj3835@gmail.com",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),

              Text(
                "Flutter Developer seeking new opportunities.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: 200,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Profile"),
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit_profile');
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const Divider(height: 30),

              // 6. This widget now loads skills from storage
              _buildMySkills(),

              // Menu List
              _buildProfileMenuItem(
                icon: Icons.document_scanner,
                title: "Manage Resume",
                onTap: () {
                  Navigator.pushNamed(context, '/manage_resume');
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.bookmark,
                title: "Saved Jobs",
                onTap: () {
                  Navigator.pushNamed(context, '/saved_jobs');
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.settings,
                title: "Settings",
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.help_outline,
                title: "Contact Support",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact Support pressed!')),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/welcome',
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 7. UPDATE "My Skills" WIDGET
  Widget _buildMySkills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "My Skills",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
              onPressed: () {
                // 8. ADD SKILL and SAVE
                setState(() {
                  _skills.add('New Skill'); // Adds a placeholder
                });
                _saveSkills(); // Save the new list
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _skills.map((skill) {
            return Chip(
              label: Text(skill),
              backgroundColor: Colors.blue.withOpacity(0.1),
              labelStyle: const TextStyle(color: Colors.blue),
              onDeleted: () {
                // 9. REMOVE SKILL and SAVE
                setState(() {
                  _skills.remove(skill);
                });
                _saveSkills(); // Save the new list
              },
              deleteIcon: const Icon(Icons.cancel, size: 18),
            );
          }).toList(),
        ),
        const Divider(height: 30),
      ],
    );
  }

  // Helper for menu items
  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}

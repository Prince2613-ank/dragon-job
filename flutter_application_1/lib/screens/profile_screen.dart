import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/database_helper.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;

  List<String> _skills = [];

  String _name = '';
  String _email = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSkills();
    _loadUserProfile();
  }

  // ================= USER DATA =================
  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('loggedInUserId');

    if (userId != null) {
      final user = await DatabaseHelper.instance.getUserById(userId);

      if (user != null) {
        setState(() {
          _name = user['name'];
          _email = user['email'];
          _loading = false;
        });
        return;
      }
    }

    setState(() {
      _name = 'Guest User';
      _email = '';
      _loading = false;
    });
  }

  // ================= SKILLS =================
  Future<void> _loadSkills() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedSkills;

    if (prefs.containsKey('mySkills')) {
      savedSkills = prefs.getStringList('mySkills') ?? [];
    } else {
      savedSkills = ['Flutter', 'Python', 'Django', 'UI/UX Design', 'Firebase'];
      await prefs.setStringList('mySkills', savedSkills);
    }

    setState(() {
      _skills = savedSkills;
    });
  }

  Future<void> _saveSkills() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mySkills', _skills);
  }

  // ================= IMAGE =================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
              _name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            Text(
              _email,
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
              ),
            ),

            const Divider(height: 30),

            _buildMySkills(),

            _buildProfileMenuItem(
              icon: Icons.document_scanner,
              title: "Manage Resume",
              onTap: () => Navigator.pushNamed(context, '/manage_resume'),
            ),
            _buildProfileMenuItem(
              icon: Icons.bookmark,
              title: "Saved Jobs",
              onTap: () => Navigator.pushNamed(context, '/saved_jobs'),
            ),
            _buildProfileMenuItem(
              icon: Icons.settings,
              title: "Settings",
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await AuthService.instance.logout();
                  await prefs.remove('loggedInUserId');
                  await prefs.remove('loggedInUserName');
                  await prefs.remove('loggedInUserEmail');
                  await prefs.remove('loggedInUserRole');

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/welcome',
                    (route) => false,
                  );
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SKILLS UI =================
  Widget _buildMySkills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "My Skills",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
              onPressed: () {
                setState(() {
                  _skills.add('New Skill');
                });
                _saveSkills();
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _skills.map((skill) {
            return Chip(
              label: Text(skill),
              backgroundColor: Colors.blue.withOpacity(0.1),
              labelStyle: const TextStyle(color: Colors.blue),
              onDeleted: () {
                setState(() {
                  _skills.remove(skill);
                });
                _saveSkills();
              },
            );
          }).toList(),
        ),
        const Divider(height: 30),
      ],
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

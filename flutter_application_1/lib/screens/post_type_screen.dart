import 'package:flutter/material.dart';
import 'post_form_screen.dart';

class PostTypeScreen extends StatelessWidget {
  const PostTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Post Type')),
      body: Column(
        children: [
          _btn(context, 'Job', 'job'),
          _btn(context, 'Internship', 'internship'),
          _btn(context, 'Daily Wage', 'daily_wage'),
        ],
      ),
    );
  }

  Widget _btn(BuildContext context, String label, String type) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PostFormScreen(postType: type)),
          );
        },
        child: Text(label),
      ),
    );
  }
}

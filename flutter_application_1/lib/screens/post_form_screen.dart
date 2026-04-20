import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../helpers/database_helper.dart';

class PostFormScreen extends StatefulWidget {
  final String postType;

  const PostFormScreen({super.key, required this.postType});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String get salaryLabel {
    if (widget.postType == 'job') return 'Salary';
    if (widget.postType == 'internship') return 'Stipend';
    return 'Daily Wage';
  }

  Future<void> submit() async {
    if (titleController.text.isEmpty ||
        companyController.text.isEmpty ||
        salaryController.text.isEmpty ||
        locationController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    try {
      await DatabaseHelper.instance.insertAdminPost(
        AdminPost(
          postType: widget.postType,
          role: titleController.text.trim(),
          company: companyController.text.trim(),
          salary: salaryController.text.trim(),
          location: locationController.text.trim(),
          description: descriptionController.text.trim(),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully')),
      );

      Navigator.pop(context);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final message =
          statusCode == 403
          ? 'Only admin users can create posts.'
          : 'Unable to create post. Please try again.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to create post. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.postType == 'job'
              ? 'Create Job'
              : widget.postType == 'internship'
              ? 'Create Internship'
              : 'Create Daily Wage',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Post Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                _buildField(
                  controller: titleController,
                  label: 'Role',
                  icon: Icons.work_outline,
                ),
                _buildField(
                  controller: companyController,
                  label: 'Company',
                  icon: Icons.business_outlined,
                ),
                _buildField(
                  controller: salaryController,
                  label: salaryLabel,
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                ),
                _buildField(
                  controller: locationController,
                  label: 'Location',
                  icon: Icons.location_on_outlined,
                ),
                _buildField(
                  controller: descriptionController,
                  label: 'Description',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    onPressed: submit,
                    child: const Text(
                      'Post',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= REUSABLE INPUT =================
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
        ),
      ),
    );
  }
}

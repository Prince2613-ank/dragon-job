// FILE: lib/screens/manage_resume_screen.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

// Helper class to manage resume data
class ResumeFile {
  String name;
  String path;
  bool isDefault;

  ResumeFile({required this.name, required this.path, this.isDefault = false});
}

class ManageResumeScreen extends StatefulWidget {
  const ManageResumeScreen({super.key});

  @override
  State<ManageResumeScreen> createState() => _ManageResumeScreenState();
}

class _ManageResumeScreenState extends State<ManageResumeScreen> {
  List<ResumeFile> _resumes = [
    ResumeFile(name: "my_old_resume.pdf", path: "/dummy/path", isDefault: true),
  ];
  bool _isLoading = false;

  // --- 1. NEW HELPER FUNCTION ---
  // A central function to add any new resume to our list
  void _addNewResumeToList(String path) {
    // Get the file name from the full path
    final String fileName = path.split('/').last;

    final newResume = ResumeFile(name: fileName, path: path);

    // If this is the first resume, make it default
    if (_resumes.isEmpty) {
      newResume.isDefault = true;
    }

    setState(() {
      _resumes.add(newResume); // Add to the list
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Added: $fileName')));
  }

  // --- 2. UPDATE _pickResume ---
  // This function now just picks a file and calls our new helper
  Future<void> _pickResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      // Call our new function
      _addNewResumeToList(result.files.single.path!);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('File selection canceled.')));
    }
  }

  // --- (No changes to this function) ---
  Future<void> _analyzeResume() async {
    ResumeFile? defaultResume;
    try {
      defaultResume = _resumes.firstWhere((r) => r.isDefault);
    } catch (e) {
      defaultResume = null;
    }

    if (defaultResume == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a resume first.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Simulating AI analysis on ${defaultResume.name}...'),
      ),
    );

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isLoading = false;
    });

    Navigator.pushNamed(context, '/analysis_results');
  }

  void _setDefault(ResumeFile resumeToSet) {
    setState(() {
      for (var resume in _resumes) {
        resume.isDefault = false;
      }
      resumeToSet.isDefault = true;
    });
  }

  void _deleteResume(ResumeFile resumeToDelete) {
    setState(() {
      _resumes.remove(resumeToDelete);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manage Resumes",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- 3. UPDATE THIS BUTTON'S onPressed ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Create with Resume Builder"),
                onPressed: () async {
                  // <-- Make it async
                  // Wait for the builder screen to pop and send a result
                  final result = await Navigator.pushNamed(
                    context,
                    '/resume_builder',
                  );

                  // Check if we got a valid path back
                  if (result != null && result is String) {
                    _addNewResumeToList(result); // Add it to the list!
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text("Upload New Resume"),
                onPressed: _pickResume,
              ),
            ),
            const Divider(height: 32),

            Text(
              "Your Resumes",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _resumes.length,
                itemBuilder: (context, index) {
                  final resume = _resumes[index];
                  return Card(
                    color: resume.isDefault ? Colors.blue[50] : Colors.white,
                    child: ListTile(
                      leading: const Icon(
                        Icons.description,
                        color: Colors.blue,
                      ),
                      title: Text(
                        resume.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: resume.isDefault
                          ? Text(
                              "Default",
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                alignment: Alignment.centerLeft,
                              ),
                              child: const Text("Set as Default"),
                              onPressed: () => _setDefault(resume),
                            ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _deleteResume(resume),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Icon(Icons.insights, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 5,
                ),
                label: Text(
                  _isLoading ? "Processing..." : "Run AI Analysis on Default",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                onPressed: _isLoading ? null : _analyzeResume,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

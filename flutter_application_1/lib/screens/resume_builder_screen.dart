// FILE: lib/screens/resume_builder_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final _nameController = TextEditingController(text: "Prince Raj");
  final _emailController = TextEditingController(
    text: "princeraj3835@gmail.com",
  );
  final _phoneController = TextEditingController(text: "+91 12345 67890");
  final _summaryController = TextEditingController(
    text: "Aspiring Flutter developer...",
  );
  final _expController = TextEditingController(
    text: "Flutter Intern @ XYZ Corp",
  );
  final _eduController = TextEditingController(
    text: "B.Tech CSE - Galgotias University",
  );

  bool _isLoading = false;

  Future<void> _generatePdf() async {
    setState(() {
      _isLoading = true;
    });

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                _nameController.text,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(_emailController.text),
              pw.Text(_phoneController.text),
              pw.Divider(height: 20),
              pw.Text(
                "Summary",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(_summaryController.text),
              pw.SizedBox(height: 20),
              pw.Text(
                "Experience",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(_expController.text),
              pw.SizedBox(height: 20),
              pw.Text(
                "Education",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(_eduController.text),
            ],
          );
        },
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/generated_resume.pdf");

    await file.writeAsBytes(await pdf.save());

    setState(() {
      _isLoading = false;
    });

    // --- THIS IS THE FIX ---
    // First, show the snackbar and open the file
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Resume saved to ${file.path}')));

    // THEN, pop the screen and send the file path back
    Navigator.pop(context, file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Resume Builder",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _summaryController,
              decoration: InputDecoration(labelText: 'Summary'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _expController,
              decoration: InputDecoration(labelText: 'Experience (1 entry)'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _eduController,
              decoration: InputDecoration(labelText: 'Education (1 entry)'),
              maxLines: 2,
            ),
            const SizedBox(height: 30),
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
                    : const Icon(Icons.picture_as_pdf, color: Colors.white),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: _isLoading ? null : _generatePdf,
                label: Text(
                  _isLoading ? "Generating..." : "Generate PDF",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

  // 🔥 SKILLS (DYNAMIC)
  final TextEditingController _skillController = TextEditingController();
  List<String> _skills = ["Flutter", "Dart", "Firebase"];

  bool _isLoading = false;

  // ================= PDF GENERATION =================
  Future<void> _generatePdf() async {
    setState(() => _isLoading = true);

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

              // ===== SUMMARY =====
              pw.Text(
                "Summary",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(_summaryController.text),

              pw.SizedBox(height: 16),

              // ===== SKILLS =====
              pw.Text(
                "Skills",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _skills
                    .map(
                      (skill) => pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(),
                          borderRadius: pw.BorderRadius.circular(5),
                        ),
                        child: pw.Text(skill),
                      ),
                    )
                    .toList(),
              ),

              pw.SizedBox(height: 16),

              // ===== EXPERIENCE =====
              pw.Text(
                "Experience",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(_expController.text),

              pw.SizedBox(height: 16),

              // ===== EDUCATION =====
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
    final file = File(
      "${output.path}/resume_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await pdf.save());

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Resume saved: ${file.path}')));

    // ✅ SEND DATA BACK TO MANAGE RESUME
    Navigator.pop(context, {'path': file.path, 'skills': _skills});
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Resume Builder",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(_nameController, "Full Name"),
            _buildTextField(_emailController, "Email"),
            _buildTextField(_phoneController, "Phone"),
            _buildTextField(_summaryController, "Summary", maxLines: 3),

            const SizedBox(height: 20),

            // ===== SKILLS UI =====
            const Text(
              "Skills",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _skills.map((skill) {
                return Chip(
                  label: Text(skill),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _skills.remove(skill);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillController,
                    decoration: const InputDecoration(
                      hintText: "Add skill",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                  onPressed: () {
                    final skill = _skillController.text.trim();
                    if (skill.isNotEmpty &&
                        !_skills.any(
                          (s) => s.toLowerCase() == skill.toLowerCase(),
                        )) {
                      setState(() {
                        _skills.add(skill);
                        _skillController.clear();
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),
            _buildTextField(_expController, "Experience", maxLines: 2),
            _buildTextField(_eduController, "Education", maxLines: 2),

            const SizedBox(height: 30),

            // ===== GENERATE BUTTON =====
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: Text(
                  _isLoading ? "Generating..." : "Generate PDF",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: _isLoading ? null : _generatePdf,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPER =================
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // ================= DISPOSE =================
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _summaryController.dispose();
    _expController.dispose();
    _eduController.dispose();
    _skillController.dispose();
    super.dispose();
  }
}

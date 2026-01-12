// FILE: lib/screens/filter_screen.dart

import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // We'll use these to hold the state of our filters
  String? _jobType = 'Full-time';
  String? _experienceLevel = 'Entry-level';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filters", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Job Type Filter ---
            Text(
              "Job Type",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildChoiceChip(
              label: "Full-time",
              groupValue: _jobType,
              onSelected: (value) => setState(() => _jobType = value),
            ),
            _buildChoiceChip(
              label: "Part-time",
              groupValue: _jobType,
              onSelected: (value) => setState(() => _jobType = value),
            ),

            const Divider(height: 32),

            // --- Experience Level Filter ---
            Text(
              "Experience Level",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildChoiceChip(
              label: "Entry-level",
              groupValue: _experienceLevel,
              onSelected: (value) => setState(() => _experienceLevel = value),
            ),
            _buildChoiceChip(
              label: "Mid-level",
              groupValue: _experienceLevel,
              onSelected: (value) => setState(() => _experienceLevel = value),
            ),
            _buildChoiceChip(
              label: "Senior-level",
              groupValue: _experienceLevel,
              onSelected: (value) => setState(() => _experienceLevel = value),
            ),

            const Spacer(), // Pushes the button to the bottom
            // --- Apply Button ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // We don't need to pass data back for this demo
                  // In a real app, you would pass these values back
                  Navigator.pop(context);
                },
                child: const Text(
                  "Apply Filters",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for filter chips
  Widget _buildChoiceChip({
    required String label,
    required String? groupValue,
    required Function(String) onSelected,
  }) {
    final isSelected = groupValue == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onSelected(label);
        }
      },
      selectedColor: Colors.blue,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? Colors.blue : Colors.grey[200]!),
      ),
    );
  }
}

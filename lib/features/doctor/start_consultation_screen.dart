import 'package:flutter/material.dart';
import 'doctor_list_screen.dart';

class StartConsultationScreen extends StatefulWidget {
  const StartConsultationScreen({super.key});

  @override
  State<StartConsultationScreen> createState() =>
      _StartConsultationScreenState();
}

class _StartConsultationScreenState extends State<StartConsultationScreen> {
  final TextEditingController issueController = TextEditingController();

  final List<String> quickIssues = [
    "Fever",
    "Headache",
    "Skin Issue",
    "Cold & Cough",
    "Stomach Pain"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Start Consultation"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 SMART TITLE
            const Text(
              "Tell us what's bothering you 👇",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "You can type, select, or upload reports",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// 🔥 QUICK ISSUE CHIPS
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: quickIssues.map((issue) {
                return GestureDetector(
                  onTap: () {
                    issueController.text = issue;
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(issue),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            /// 🔥 INPUT BOX (UPGRADED)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: issueController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Describe your issue in detail...",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// 🔥 ATTACH REPORT (UI ONLY)
            Row(
              children: [
                Icon(Icons.attach_file, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                const Text("Upload report (optional)",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),

            const SizedBox(height: 25),

            /// 🔥 CTA BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  final issue = issueController.text.trim();

                  if (issue.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please describe your issue")),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorListScreen(issue: issue),
                    ),
                  );
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

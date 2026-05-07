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
  final FocusNode _focusNode = FocusNode(); // ← for custom chip
  String? selectedIssue;

  final List<String> quickIssues = [
    "Fever",
    "Headache",
    "Skin Issue",
    "Cold & Cough",
    "Stomach Pain",
    "custom"
  ];

  @override
  void dispose() {
    issueController.dispose();
    _focusNode.dispose(); // ← cleanup
    super.dispose();
  }

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
            const Text(
              "Tell us what's bothering you",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "You can type, select, or upload reports",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            /// QUICK ISSUE CHIPS
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: quickIssues.map((issue) {
                final isCustom = issue == 'custom';
                final isSelected = selectedIssue == issue;

                return GestureDetector(
                  onTap: () {
                    if (isCustom) {
                      setState(() {
                        selectedIssue = 'custom';
                        issueController.clear();
                      });
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _focusNode.requestFocus(); // ← focus text field
                      });
                    } else {
                      setState(() {
                        selectedIssue = issue;
                        issueController.text = issue;
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0F172A)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCustom)
                          Icon(
                            Icons.edit,
                            size: 13,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                        if (isCustom) const SizedBox(width: 4),
                        Text(
                          isCustom ? 'Custom' : issue,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            /// INPUT BOX
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedIssue == 'custom'
                      ? const Color(0xFF0F172A)
                      : Colors.transparent,
                  width: 1.5,
                ), // ← highlight when custom selected
              ),
              child: TextField(
                controller: issueController,
                focusNode: _focusNode, // ← attach focus node
                maxLines: 4,
                onChanged: (_) {
                  if (selectedIssue != null &&
                      selectedIssue != 'custom' &&
                      issueController.text != selectedIssue) {
                    setState(() => selectedIssue = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: selectedIssue == 'custom'
                      ? "Describe your issue in detail..." // ← custom hint
                      : "Or describe your issue here...",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Icon(Icons.attach_file, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                const Text("Upload report (optional)",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),

            const SizedBox(height: 25),

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
                  if (issue.isEmpty || issue == 'custom') {
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
                child: const Text("Continue",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

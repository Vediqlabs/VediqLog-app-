import 'package:flutter/material.dart';
import '../../services/doctor_service.dart';
import 'payment_screen.dart';

class DoctorListScreen extends StatefulWidget {
  final String issue;

  const DoctorListScreen({
    super.key,
    required this.issue,
  });

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final service = DoctorService();

  List<Map<String, dynamic>> doctors = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDoctors();
  }

  Future<void> loadDoctors() async {
    try {
      final data = await service.getOnlineDoctors();

      setState(() {
        doctors = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading doctors: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Select Doctor"),
        elevation: 0,
      ),
      body: Column(
        children: [
          /// 🔥 ISSUE DISPLAY (IMPORTANT UX)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              "Your Issue: ${widget.issue}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          /// 🔥 DOCTOR LIST
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : doctors.isEmpty
                    ? const Center(
                        child: Text("No doctors available right now"),
                      )
                    : ListView.builder(
                        itemCount: doctors.length,
                        itemBuilder: (context, index) {
                          final doc = doctors[index];

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,

                              /// 👨‍⚕️ Avatar
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  doc['name'][0],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),

                              /// 📄 Details
                              title: Text(
                                doc['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(doc['specialization']),
                                  const SizedBox(height: 4),

                                  /// ⭐ Rating + Online
                                  Row(
                                    children: [
                                      Text("⭐ ${doc['rating']}"),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          "Online",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              /// 💰 Price
                              trailing: Text(
                                "₹${doc['price']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              /// 👉 NEXT STEP (SESSION)
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentScreen(
                                      doctor: doc,
                                      issue: widget.issue,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

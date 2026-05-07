import 'package:flutter/material.dart';
import '../../services/doctor_service.dart';
import 'payment_screen.dart';

class DoctorListScreen extends StatefulWidget {
  final String issue;

  const DoctorListScreen({super.key, required this.issue});

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
      if (!mounted) return; // ← crash fix
      setState(() {
        doctors = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return; // ← crash fix
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
          /// Issue banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Your Issue: ${widget.issue}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          /// Doctor list
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : doctors.isEmpty
                    ? const Center(
                        child: Text("No doctors available right now"),
                      )
                    : RefreshIndicator(
                        onRefresh: loadDoctors,
                        child: ListView.builder(
                          itemCount: doctors.length,
                          itemBuilder: (context, index) {
                            final doc = doctors[index];
                            final isOnline =
                                doc['is_online'] == true; // ← real value

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
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.blue.shade100,
                                  child: Text(
                                    doc['name'][0],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  doc['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(doc['specialization'] ?? ''),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text("⭐ ${doc['rating']}"),
                                        const SizedBox(width: 10),

                                        /// ← real online status
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isOnline
                                                ? Colors.green.shade100
                                                : Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            isOnline ? "Online" : "Offline",
                                            style: TextStyle(
                                              color: isOnline
                                                  ? Colors.green
                                                  : Colors.grey,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  "₹${doc['price']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                onTap: isOnline // ← block tap if offline
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PaymentScreen(
                                              doctor: doc,
                                              issue: widget.issue,
                                            ),
                                          ),
                                        );
                                      }
                                    : () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "This doctor is currently offline"),
                                          ),
                                        );
                                      },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'chat_screen.dart';
import '../../services/session_service.dart';

class PaymentScreen extends StatefulWidget {
  final Map doctor;
  final String issue;

  const PaymentScreen({
    super.key,
    required this.doctor,
    required this.issue,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isLoading = false;

  Future<void> handlePayment() async {
    setState(() => isLoading = true);

    final service = SessionService();

    try {
      /// 🔥 Create session
      final sessionId = await service.createSession(
        doctorId: widget.doctor['id'].toString(),
        issue: widget.issue,
      );

      /// Debug
      print("Session created: $sessionId");

      /// Navigate
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            doctor: widget.doctor,
            issue: widget.issue,
            sessionId: sessionId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating session: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    final issue = widget.issue;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Confirm Consultation"),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// 🔥 DOCTOR CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            doctor['name'][0],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(doctor['specialization']),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text("⭐ ${doctor['rating']}"),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "Verified",
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
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 📝 ISSUE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      "Issue: $issue",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 💰 BREAKDOWN
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _row("Consultation Fee", "₹${doctor['price']}"),
                        const SizedBox(height: 10),
                        _row("Platform Fee", "₹0"),
                        const Divider(height: 20),
                        _row("Total", "₹${doctor['price']}", isBold: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔒 TRUST
                  const Row(
                    children: [
                      Icon(Icons.lock, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(
                        "Secure payment • 100% safe",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// 🔥 BUTTON
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Pay & Start Chat",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

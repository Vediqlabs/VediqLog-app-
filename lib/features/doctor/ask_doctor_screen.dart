import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'start_consultation_screen.dart';
import 'chat_screen.dart';

class AskDoctorScreen extends StatefulWidget {
  const AskDoctorScreen({super.key});

  @override
  State<AskDoctorScreen> createState() => _AskDoctorScreenState();
}

class _AskDoctorScreenState extends State<AskDoctorScreen> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> sessions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final userId = _client.auth.currentUser!.id;

      final res = await _client
          .from('sessions')
          .select('*, doctors(name, specialization)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (!mounted) return;
      setState(() {
        sessions = List<Map<String, dynamic>>.from(res);
        loading = false;
      });
    } catch (e) {
      print("❌ ERROR LOADING SESSIONS: $e");
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      case 'rejected':
        return Colors.red; // ← added
      default:
        return Colors.orange; // pending
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'closed':
        return 'Closed';
      case 'rejected':
        return 'Rejected'; // ← added
      default:
        return 'Pending';
    }
  }

  void _onSessionTap(Map<String, dynamic> session) {
    final status = session['status'];
    final doctor = session['doctors'];

    if (status == 'rejected') {
      // Show rejected message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This consultation was declined by the doctor."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (status == 'pending') {
      // Show waiting message
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Waiting for Doctor"),
          content: const Text(
            "Your consultation request is pending. Please wait for the doctor to accept it.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    // active or closed → open chat
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          doctor: doctor ?? {},
          issue: session['issue'] ?? '',
          sessionId: session['id'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Ask Doctor"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: _loadSessions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Micro-consultations with certified experts",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // Main card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Get connected with a doctor instantly. Perfect for symptom checks and second opinions.",
                      style: TextStyle(color: Colors.white70, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const StartConsultationScreen(),
                          ),
                        );
                        _loadSessions();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.black),
                            SizedBox(width: 8),
                            Text(
                              "Start New Consultation",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Row(
                children: [
                  Icon(Icons.access_time, size: 18),
                  SizedBox(width: 6),
                  Text(
                    "Recent Consultations",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              loading
                  ? const Center(child: CircularProgressIndicator())
                  : sessions.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.person_outline,
                                  size: 40, color: Colors.grey),
                              SizedBox(height: 10),
                              Text(
                                "No consultations yet. Start one to get expert advice.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: sessions.map((session) {
                            final doctor = session['doctors'];
                            final status = session['status'];

                            return GestureDetector(
                              onTap: () => _onSessionTap(session),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: Colors.grey.shade100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blue.shade50,
                                      child: Text(
                                        doctor != null
                                            ? doctor['name'][0]
                                            : '?',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doctor?['name'] ?? 'Doctor',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            session['issue'] ?? '',
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _statusColor(status)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _statusLabel(status),
                                        style: TextStyle(
                                          color: _statusColor(status),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    // ← show lock icon for pending/rejected
                                    Icon(
                                      status == 'active'
                                          ? Icons.chevron_right
                                          : status == 'rejected'
                                              ? Icons.block
                                              : Icons.hourglass_empty,
                                      color: _statusColor(status),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

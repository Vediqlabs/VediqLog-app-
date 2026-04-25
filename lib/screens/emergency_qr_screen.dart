import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';

class EmergencyQRScreen extends StatefulWidget {
  const EmergencyQRScreen({super.key});

  @override
  State<EmergencyQRScreen> createState() => _EmergencyQRScreenState();
}

class _EmergencyQRScreenState extends State<EmergencyQRScreen> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  String qrData = "";
  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    loadEmergencyData();
  }

  Future<void> loadEmergencyData() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() {
        qrData = "NOT_LOGGED_IN";
        loading = false;
      });
      return;
    }

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    final emergencyLink = "https://vediqlog.app/emergency/${user.id}";

    setState(() {
      profile = data;
      qrData = emergencyLink;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.emergencyAccess),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  /// ===== QR CARD =====
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: qrData,
                          size: 260,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!.emergencyMedicalAccess,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.scanHealthData,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// ===== INFO =====
                  _infoTile(
                    Icons.bloodtype,
                    AppLocalizations.of(context)!.bloodGroup,
                    profile?['blood_group'] ??
                        AppLocalizations.of(context)!.unknown,
                  ),
                  _infoTile(
                    Icons.person,
                    AppLocalizations.of(context)!.fullName,
                    profile?['full_name'] ?? AppLocalizations.of(context)!.user,
                  ),
                  _infoTile(
                    Icons.warning_amber,
                    AppLocalizations.of(context)!.allergies,
                    profile?['allergies'] ??
                        AppLocalizations.of(context)!.noneKnown,
                  ),
                  _infoTile(
                    Icons.monitor_heart,
                    AppLocalizations.of(context)!.conditions,
                    profile?['conditions'] ??
                        AppLocalizations.of(context)!.none,
                  ),
                  _infoTile(
                    Icons.medication,
                    AppLocalizations.of(context)!.medications,
                    profile?['medications'] ??
                        AppLocalizations.of(context)!.none,
                  ),
                  _infoTile(
                    Icons.phone,
                    AppLocalizations.of(context)!.emergencyContact,
                    profile?['emergency_contact'] ??
                        AppLocalizations.of(context)!.notSet,
                  ),

                  const SizedBox(height: 24),

                  /// ===== ACTION BUTTONS =====
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share),
                          label: Text(AppLocalizations.of(context)!.share),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download),
                          label: Text(AppLocalizations.of(context)!.saveQr),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    AppLocalizations.of(context)!.emergencyAutoRefresh,
                    style: TextStyle(fontSize: 11, color: Colors.red),
                  ),
                ],
              ),
            ),
    );
  }

  /// ===== INFO TILE =====
  Widget _infoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

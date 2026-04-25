import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_policy_sheet.dart';
import '../l10n/app_localizations.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> policies = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPolicies();
  }

  Future<void> loadPolicies() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('insurance_policies')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    setState(() {
      policies = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  Future<void> deletePolicy(String id) async {
    await supabase.from('insurance_policies').delete().eq('id', id);
    loadPolicies();
  }

  void openAddPolicySheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddPolicySheet(),
    );

    loadPolicies();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(t.secureVault),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      floatingActionButton: policies.isEmpty
          ? null
          : FloatingActionButton.extended(
              backgroundColor: const Color(0xFF0F172A),
              onPressed: openAddPolicySheet,
              label: Text(t.addPolicy),
              icon: const Icon(Icons.add),
            ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : policies.isEmpty
          ? _emptyState()
          : _policyList(),
    );
  }

  /// ===== Empty State =====
  Widget _emptyState() {
    final t = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, size: 90, color: Colors.grey),
            const SizedBox(height: 20),

            Text(
              t.noPoliciesFound,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              t.storePoliciesSecure,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: openAddPolicySheet,
                child: Text(t.addFirstPolicy),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ===== Policy List =====
  Widget _policyList() {
    final t = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: policies.length,
        itemBuilder: (context, index) {
          final p = policies[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                /// Provider Icon
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield, color: Colors.amber),
                ),

                const SizedBox(width: 14),

                /// Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['provider'] ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        p['plan_name'] ?? "",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "${t.policyNo}: ${p['policy_number']}",
                        style: const TextStyle(fontSize: 12),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "${t.sumInsured}: ₹${p['sum_insured']}",
                        style: const TextStyle(fontSize: 12),
                      ),

                      Text(
                        "${t.premium}: ₹${p['annual_premium']}/year",
                        style: const TextStyle(fontSize: 12),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "${t.renewal}: ${p['renewal_date']?.toString().substring(0, 10) ?? ''}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Delete button
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => deletePolicy(p['id']),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

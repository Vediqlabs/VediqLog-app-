import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';

class MembershipSheet extends StatefulWidget {
  final String mode;

  const MembershipSheet({
    super.key,
    this.mode = "buy",
  });

  @override
  State<MembershipSheet> createState() => _MembershipSheetState();
}

class _MembershipSheetState extends State<MembershipSheet> {
  final supabase = Supabase.instance.client;

  bool get isManageMode => widget.mode == "manage";

  bool yearlySelected = true;
  bool activating = false;
  bool loading = true;
  bool isActive = false;

  String expiryDate = "";
  String dataMembershipId = "";

  @override
  void initState() {
    super.initState();
    loadMembership();
  }

  String generateMembershipId() =>
      DateTime.now().millisecondsSinceEpoch.toString().substring(6);

  Future<void> loadMembership() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('memberships')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (data != null && data['status'] == 'active') {
      setState(() {
        isActive = true;
        expiryDate = data['end_date']?.toString().substring(0, 10) ?? "";
        dataMembershipId = data['membership_id'] ?? "";
        loading = false;
      });
    } else {
      setState(() {
        isActive = false;
        loading = false;
      });
    }
  }

  Future<void> activateMembership() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => activating = true);

    final plan = yearlySelected ? "yearly" : "monthly";

    final endDate = yearlySelected
        ? DateTime.now().add(const Duration(days: 365))
        : DateTime.now().add(const Duration(days: 30));

    final membershipId = generateMembershipId();

    await supabase.from('memberships').upsert({
      'user_id': user.id,
      'plan': plan,
      'membership_id': membershipId,
      'status': 'active',
      'end_date': endDate.toIso8601String(),
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F9FC),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(22),
            ),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              /// Membership Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF1E293B),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "VEDIQLOG",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t.goldMember,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t.membershipId,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dataMembershipId.isEmpty
                          ? t.notActivated
                          : "•••• •••• •••• $dataMembershipId",
                      style: const TextStyle(
                        color: Colors.white,
                        letterSpacing: 2,
                        fontSize: 16,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(height: 12),
                      Text(
                        "${t.validTill}: $expiryDate",
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Text(
                t.ourServices,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              serviceTile(
                "👨‍👩‍👧 ${t.familyVault}",
                t.familyVaultDesc,
              ),

              serviceTile(
                "📍 ${t.emergencyGps}",
                t.emergencyGpsDesc,
              ),

              serviceTile(
                "🤖 ${t.aiInsights}",
                t.aiInsightsDesc,
              ),

              const SizedBox(height: 25),

              if (!isActive) ...[
                Row(
                  children: [
                    Expanded(
                      child: planBox(
                        context: context,
                        title: t.monthly,
                        price: "₹79",
                        selected: !yearlySelected,
                        onTap: () => setState(() => yearlySelected = false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: planBox(
                        context: context,
                        title: t.yearly,
                        price: "₹799",
                        selected: yearlySelected,
                        bestValue: true,
                        subtitle: t.save15,
                        onTap: () => setState(() => yearlySelected = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: activating ? null : activateMembership,
                    child: activating
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(t.activateMembership),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: null,
                    child: Text(t.membershipActive),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  static Widget serviceTile(
    String title,
    String subtitle,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  static Widget planBox({
    required BuildContext context,
    required String title,
    required String price,
    required bool selected,
    required VoidCallback onTap,
    bool bestValue = false,
    String? subtitle,
  }) {
    final t = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? Colors.amber.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? Colors.amber : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(title),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (bestValue)
            Positioned(
              top: -6,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  t.bestValue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

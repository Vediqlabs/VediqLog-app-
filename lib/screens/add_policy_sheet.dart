import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';

class AddPolicySheet extends StatefulWidget {
  const AddPolicySheet({super.key});

  @override
  State<AddPolicySheet> createState() => _AddPolicySheetState();
}

class _AddPolicySheetState extends State<AddPolicySheet> {
  final supabase = Supabase.instance.client;

  final providerCtrl = TextEditingController();
  final planCtrl = TextEditingController();
  final numberCtrl = TextEditingController();
  final sumCtrl = TextEditingController();
  final premiumCtrl = TextEditingController();

  DateTime? renewalDate;
  bool saving = false;

  @override
  void dispose() {
    providerCtrl.dispose();
    planCtrl.dispose();
    numberCtrl.dispose();
    sumCtrl.dispose();
    premiumCtrl.dispose();
    super.dispose();
  }

  Future<void> savePolicy() async {
    final l10n = AppLocalizations.of(context)!;

    if (providerCtrl.text.isEmpty ||
        planCtrl.text.isEmpty ||
        numberCtrl.text.isEmpty ||
        sumCtrl.text.isEmpty ||
        premiumCtrl.text.isEmpty ||
        renewalDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.fillAllFields)));
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => saving = true);

    await supabase.from('insurance_policies').insert({
      'user_id': user.id,
      'provider': providerCtrl.text.trim(),
      'plan_name': planCtrl.text.trim(),
      'policy_number': numberCtrl.text.trim(),
      'sum_insured': sumCtrl.text.trim(),
      'annual_premium': premiumCtrl.text.trim(),
      'renewal_date': renewalDate!.toIso8601String(),
    });

    if (mounted) Navigator.pop(context);
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (date != null) {
      setState(() => renewalDate = date);
    }
  }

  String formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/"
      "${d.month.toString().padLeft(2, '0')}/"
      "${d.year}";

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          decoration: const BoxDecoration(
            color: Color(0xFFF7F9FC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: ListView(
            controller: controller,
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

              Text(
                l10n.addInsurancePolicy,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              _field(l10n.insuranceProvider, providerCtrl),
              _field(l10n.planName, planCtrl),
              _field(l10n.policyNumber, numberCtrl),
              _field(l10n.sumInsured, sumCtrl, isNumber: true),
              _field(l10n.annualPremium, premiumCtrl, isNumber: true),

              const SizedBox(height: 8),

              GestureDetector(
                onTap: pickDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        renewalDate == null
                            ? l10n.selectRenewalDate
                            : formatDate(renewalDate!),
                        style: TextStyle(
                          color: renewalDate == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      const Icon(Icons.calendar_month),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: saving ? null : savePolicy,
                  child: saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(l10n.savePolicy),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _field(
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

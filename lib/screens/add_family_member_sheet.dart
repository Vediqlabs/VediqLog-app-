import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';

class AddFamilyMemberSheet extends StatefulWidget {
  const AddFamilyMemberSheet({super.key});

  @override
  State<AddFamilyMemberSheet> createState() => _AddFamilyMemberSheetState();
}

class _AddFamilyMemberSheetState extends State<AddFamilyMemberSheet> {
  final supabase = Supabase.instance.client;

  final TextEditingController phoneController = TextEditingController();

  String relation = 'Father';
  bool saving = false;

  /// Values stored in DB (keep English)
  final relations = ['Father', 'Mother', 'Spouse', 'Child'];

  Future<void> saveMember() async {
    final user = supabase.auth.currentUser;
    final phone = phoneController.text.trim();

    if (user == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enterPhoneNumber)),
      );
      return;
    }

    setState(() => saving = true);

    try {
      /// Find profile by phone
      final profile = await supabase
          .from('profiles')
          .select('id')
          .eq('phone', phone)
          .maybeSingle();

      if (profile == null) {
        throw AppLocalizations.of(context)!.noUserWithPhone;
      }

      /// Create link
      await supabase.from('family_links').insert({
        'owner_id': user.id,
        'member_id': profile['id'],
        'relation': relation,
      });

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) setState(() => saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            Text(
              AppLocalizations.of(context)!.addFamilyMember,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            /// PHONE FIELD
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.phoneNumberExisting,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// RELATION DROPDOWN
            DropdownButtonFormField<String>(
              value: relation,
              items: relations.map((r) {
                final label = {
                  'Father': AppLocalizations.of(context)!.father,
                  'Mother': AppLocalizations.of(context)!.mother,
                  'Spouse': AppLocalizations.of(context)!.spouse,
                  'Child': AppLocalizations.of(context)!.child,
                }[r]!;

                return DropdownMenuItem(value: r, child: Text(label));
              }).toList(),
              onChanged: (v) => setState(() => relation = v!),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.relation,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : saveMember,
                child: saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(AppLocalizations.of(context)!.linkMember),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

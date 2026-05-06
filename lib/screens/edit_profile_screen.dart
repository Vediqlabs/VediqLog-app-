import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final supabase = Supabase.instance.client;

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();

  final _allergies = TextEditingController();
  final _conditions = TextEditingController();
  final _medications = TextEditingController();
  final _emergencyContact = TextEditingController();

  DateTime? dob;

  // 🔥 IMPORTANT: use keys instead of text
  String gender = "male";
  String bloodGroup = "O+";

  bool loading = true;
  bool saving = false;
  bool isDiabetic = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data != null) {
      _name.text = data['full_name'] ?? '';
      _phone.text = data['phone'] ?? '';
      _height.text = data['height']?.toString() ?? '';
      _weight.text = data['weight']?.toString() ?? '';
      _allergies.text = data['allergies'] ?? '';
      _conditions.text = data['conditions'] ?? '';
      _medications.text = data['medications'] ?? '';
      _emergencyContact.text = data['emergency_contact'] ?? '';

      if (data['dob'] != null) {
        dob = DateTime.parse(data['dob']);
      }

      // 🔥 normalize stored values
      final g = (data['gender'] ?? "male").toString().toLowerCase();
      gender = ["male", "female", "other"].contains(g) ? g : "male";

      bloodGroup = data['blood_group'] ?? "O+";
      isDiabetic = data['is_diabetic'] ?? false;
    }

    setState(() => loading = false);
  }

  Future<void> saveProfile() async {
    final t = AppLocalizations.of(context)!;

    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.selectDob)),
      );
      return;
    }

    setState(() => saving = true);

    await supabase.from('profiles').update({
      'full_name': _name.text,
      'phone': _phone.text,
      'dob': dob!.toIso8601String(),
      'gender': gender,
      'blood_group': bloodGroup,
      'height': double.tryParse(_height.text),
      'weight': double.tryParse(_weight.text),
      'age': calculateAge(dob!),
      'allergies': _allergies.text,
      'conditions': _conditions.text,
      'medications': _medications.text,
      'emergency_contact': _emergencyContact.text,
      'is_diabetic': isDiabetic,
    }).eq('id', user.id);

    setState(() => saving = false);

    if (mounted) Navigator.pop(context);
  }

  Future<void> pickDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => dob = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.editProfile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            textField(t.fullName, _name),
            textField(t.phone, _phone),
            dobPicker(t),
            dropdownGender(t),
            dropdownBloodGroup(t),
            textField(t.heightCm, _height),
            textField(t.weightKg, _weight),
            SwitchListTile(
              title: Text(t.diabetic),
              value: isDiabetic,
              onChanged: (v) => setState(() => isDiabetic = v),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t.emergencyInformation,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            textField(t.allergies, _allergies),
            textField(t.medicalConditions, _conditions),
            textField(t.medications, _medications),
            textField(t.emergencyContactNumber, _emergencyContact),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: saving ? null : saveProfile,
                child: saving
                    ? const CircularProgressIndicator()
                    : Text(t.saveProfile),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dobPicker(AppLocalizations t) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          tileColor: Colors.grey.shade100,
          title: Text(
            dob == null ? t.selectDob : DateFormat('dd MMM yyyy').format(dob!),
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: pickDOB,
        ),
      );

  Widget textField(String label, TextEditingController c) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: TextField(
          controller: c,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      );

  Widget dropdownGender(AppLocalizations t) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: DropdownButtonFormField<String>(
          value: gender,
          items: [
            DropdownMenuItem(value: "male", child: Text(t.male)),
            DropdownMenuItem(value: "female", child: Text(t.female)),
            DropdownMenuItem(value: "other", child: Text(t.other)),
          ],
          onChanged: (v) => setState(() => gender = v!),
          decoration: InputDecoration(labelText: t.gender),
        ),
      );

  Widget dropdownBloodGroup(AppLocalizations t) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: DropdownButtonFormField<String>(
          value: bloodGroup,
          items: [
            "A+",
            "A-",
            "B+",
            "B-",
            "AB+",
            "AB-",
            "O+",
            "O-",
          ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (v) => setState(() => bloodGroup = v!),
          decoration: InputDecoration(labelText: t.bloodGroup),
        ),
      );
}

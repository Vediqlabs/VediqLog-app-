import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  String gender = "Male";
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

      gender = data['gender'] ?? "Male";
      bloodGroup = data['blood_group'] ?? "O+";
      isDiabetic = data['is_diabetic'] ?? false;
    }

    setState(() => loading = false);
  }

  Future<void> saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (dob == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select DOB")));
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
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            textField("Full Name", _name),
            textField("Phone", _phone),
            dobPicker(),
            dropdownGender(),
            dropdownBloodGroup(),
            textField("Height (cm)", _height),
            textField("Weight (kg)", _weight),
            SwitchListTile(
              title: const Text("Diabetic"),
              value: isDiabetic,
              onChanged: (v) => setState(() => isDiabetic = v),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Emergency Information",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            textField("Allergies", _allergies),
            textField("Medical Conditions", _conditions),
            textField("Medications", _medications),
            textField("Emergency Contact Number", _emergencyContact),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: saving ? null : saveProfile,
                child: saving
                    ? const CircularProgressIndicator()
                    : const Text("Save Profile"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dobPicker() => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          tileColor: Colors.grey.shade100,
          title: Text(
            dob == null ? "Select DOB" : DateFormat('dd MMM yyyy').format(dob!),
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

  Widget dropdownGender() => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: DropdownButtonFormField<String>(
          value: gender,
          items: [
            "Male",
            "Female",
            "Other",
          ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (v) => setState(() => gender = v!),
          decoration: const InputDecoration(labelText: "Gender"),
        ),
      );

  Widget dropdownBloodGroup() => Padding(
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
          decoration: const InputDecoration(labelText: "Blood Group"),
        ),
      );
}

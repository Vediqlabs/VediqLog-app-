import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';

class AddReminderScreen extends StatefulWidget {
  final DateTime date;
  final Map<String, dynamic>? reminder;

  const AddReminderScreen({super.key, required this.date, this.reminder});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  String selectedTab = "Medicine";

  final nameController = TextEditingController();

  late DateTime selectedDate;
  TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

  bool saving = false;
  String repeatType = "one_time";
  int repeatIntervalDays = 1;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.date;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.fromLTRB(18, 20, 18, keyboard),
            decoration: const BoxDecoration(
              color: Color(0xFFF6F7FB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView(
                controller: controller,
                children: [
                  /// Handle bar
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
                    AppLocalizations.of(context)!.addReminder,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// TYPE SELECTOR
                  Row(
                    children: [
                      AppLocalizations.of(context)!.medicine,
                      AppLocalizations.of(context)!.appointment,
                      AppLocalizations.of(context)!.labTest,
                    ].map((type) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          child: GestureDetector(
                            onTap: () => setState(() => selectedTab = type),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: selectedTab == type
                                    ? const Color(0xFFFFC107)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: selectedTab == type
                                      ? Colors.black
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  /// NAME FIELD
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => saveReminder(),
                    decoration: InputDecoration(
                      hintText: "$selectedTab",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// DATE + TIME
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: pickDate,
                            child: Text(
                              DateFormat('dd MMM yyyy').format(selectedDate),
                            ),
                          ),
                        ),
                        const Icon(Icons.access_time, size: 20),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: pickTime,
                          child: Text(selectedTime.format(context)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// REPEAT
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: repeatType,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: "one_time",
                            child: Text(AppLocalizations.of(context)!.oneTime),
                          ),
                          DropdownMenuItem(
                            value: "everyday",
                            child: Text(AppLocalizations.of(context)!.everyday),
                          ),
                          DropdownMenuItem(
                            value: "custom",
                            child: Text(
                              AppLocalizations.of(context)!.customInterval,
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => repeatType = v!),
                      ),
                    ),
                  ),

                  if (repeatType == "custom") ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Repeat every"),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  if (repeatIntervalDays > 1) {
                                    setState(() => repeatIntervalDays--);
                                  }
                                },
                              ),
                              Text(
                                "$repeatIntervalDays",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  setState(() => repeatIntervalDays++);
                                },
                              ),
                            ],
                          ),
                          const Text("days"),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  /// SAVE BUTTON

                  /// SAVE BUTTON
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
                      onPressed: saving ? null : saveReminder,
                      child: saving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(AppLocalizations.of(context)!.saveReminder),
                    ),
                  ),

                  const SizedBox(height: 0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /* ================= FUNCTIONS ================= */

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> saveReminder() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter reminder name")),
      );
      return;
    }

    setState(() => saving = true);

    try {
      final user = supabase.auth.currentUser;

      if (user == null || user.id.isEmpty) {
        throw Exception("User not ready");
      }

      final scheduled = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      final alarmId = scheduled.millisecondsSinceEpoch.remainder(2147483647);
      final inserted = await supabase
          .from('reminders')
          .insert({
            'user_id': user.id,
            'title': nameController.text.trim(),
            'date': selectedDate.toIso8601String().split("T").first,
            'time':
                "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
            'type': selectedTab,
            'repeat_type': repeatType,
            'repeat_interval': repeatIntervalDays,
            'alarm_id': alarmId,
          })
          .select()
          .single();

      if (repeatType == "custom") {
        for (int i = 0; i < repeatIntervalDays; i++) {
          final next = scheduled.add(Duration(days: i));

          final customAlarmId =
              next.millisecondsSinceEpoch.remainder(2147483647);

          await NotificationService.scheduleAlarm(
            id: customAlarmId,
            reminderId: inserted['id'],
            title: "Reminder",
            body: nameController.text.trim(),
            dateTime: next,
          );
        }
      } else {
        final alarmId = scheduled.millisecondsSinceEpoch.remainder(2147483647);

        await NotificationService.scheduleAlarm(
          id: alarmId,
          reminderId: inserted['id'],
          title: "Reminder",
          body: nameController.text.trim(),
          dateTime: scheduled,
        );
      }
      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      print("SAVE ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }
}

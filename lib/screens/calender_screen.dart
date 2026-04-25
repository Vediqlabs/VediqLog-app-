import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_reminder_screen.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> reminders = [];
  Set<String> markedDates = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 400), () {
      loadReminders();
    });
  }

  void openReminder({Map<String, dynamic>? reminder}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReminderScreen(date: selectedDate, reminder: reminder),
    ).then((_) => loadReminders());
  }

  Future<void> loadReminders() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null || user.id.isEmpty) {
      debugPrint("⛔ User not ready, skipping reminders load");
      setState(() => loading = false);
      return;
    }

    setState(() => loading = true);

    List data = [];

    try {
      data = await supabase
          .from('reminders')
          .select()
          .eq('user_id', user.id)
          .order('time');
    } catch (e) {
      debugPrint("Reminder load failed: $e");
    }

    final logs = await supabase
        .from('reminder_logs')
        .select()
        .eq('user_id', user.id)
        .eq('date', DateFormat('yyyy-MM-dd').format(selectedDate));

    final completedIds =
        logs.map<String>((e) => e['reminder_id'] as String).toSet();
    final List<Map<String, dynamic>> result = [];
    final Set<String> marked = {};

    for (final r in data) {
      final start = DateTime.parse(r['date']);
      final repeatType = r['repeat_type'] ?? "one_time";
      final interval = r['repeat_interval'] ?? 1;

      // -------- Mark Calender -------

      final daysInMonth = DateUtils.getDaysInMonth(
        selectedDate.year,
        selectedDate.month,
      );

      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(selectedDate.year, selectedDate.month, day);
        final diff = date.difference(start).inDays;

        if (diff < 0) continue;

        if (repeatType == "one_time") {
          if (diff == 0) {
            marked.add(DateFormat('yyyy-MM-dd').format(date));
          }
        } else if (repeatType == "everyday") {
          marked.add(DateFormat('yyyy-MM-dd').format(date));
        } else if (repeatType == "custom") {
          if (diff >= 0 && diff < interval) {
            marked.add(DateFormat('yyyy-MM-dd').format(date));
          }
        }
      }
      // -------- SHOW TODAY LIST --------
      final diff = selectedDate.difference(start).inDays;
      if (diff < 0) continue;

      bool showToday = false;

      if (repeatType == "one_time") {
        showToday = diff == 0;
      } else if (repeatType == "everyday") {
        showToday = diff >= 0;
      } else if (repeatType == "custom") {
        showToday = diff >= 0 && diff < interval;
      }

      if (showToday) {
        final reminder = Map<String, dynamic>.from(r);
        reminder['isCompleted'] = completedIds.contains(r['id']);
        result.add(reminder);
      }
    }

    if (!mounted) return;

    setState(() {
      reminders = result;
      markedDates = marked;
      loading = false;
    });
  }

  IconData iconForType(String type) {
    switch (type) {
      case "Appointment":
        return Icons.event;
      case "Lab Test":
        return Icons.science;
      default:
        return Icons.medication;
    }
  }

  Color iconColor(String type) {
    switch (type) {
      case "Appointment":
        return Colors.orange;
      case "Lab Test":
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  /* ---------- CALENDAR GRID ---------- */
  Widget buildCalendar() {
    final daysInMonth = DateUtils.getDaysInMonth(
      selectedDate.year,
      selectedDate.month,
    );

    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);

    final startWeekday = firstDay.weekday % 7;

    List<Widget> items = [];

    for (int i = 0; i < startWeekday; i++) {
      items.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(selectedDate.year, selectedDate.month, day);

      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      final isSelected =
          dateKey == DateFormat('yyyy-MM-dd').format(selectedDate);

      final hasReminder = markedDates.contains(dateKey);

      items.add(
        GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = date;
            });
            loadReminders();
          },
          child: Center(
            child: Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFF0F172A) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$day",
                    style: TextStyle(
                      color: isSelected ? Colors.amber : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hasReminder)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1,
      children: items,
    );
  }

  /* ---------- EMPTY STATE ---------- */
  Widget buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: OutlinedButton(
          onPressed: () => openReminder(),
          child: Text(AppLocalizations.of(context)!.addReminder),
        ),
      ),
    );
  }

  /* ---------- UI ---------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0F172A),
        child: const Icon(Icons.add, color: Colors.amber),
        onPressed: () => openReminder(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.smartReminders,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.healthScheduleSubtitle,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              /// CALENDAR CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    /// Month navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 16,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedDate = DateTime(
                                selectedDate.year,
                                selectedDate.month - 1,
                                1,
                              );
                            });
                            loadReminders();
                          },
                        ),
                        Text(
                          DateFormat.yMMMM(
                            Localizations.localeOf(context).toString(),
                          ).format(selectedDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedDate = DateTime(
                                selectedDate.year,
                                selectedDate.month + 1,
                                1,
                              );
                            });
                            loadReminders();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// Calendar grid
                    buildCalendar(),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// SECTION TITLE
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${AppLocalizations.of(context)!.scheduleFor} "
                    "${DateFormat.MMMM(Localizations.localeOf(context).toString()).format(selectedDate)} "
                    "${selectedDate.day}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : reminders.isEmpty
                        ? buildEmptyState()
                        : ListView.builder(
                            itemCount: reminders.length,
                            itemBuilder: (context, index) {
                              final r = reminders[index];

                              return Dismissible(
                                key: Key(r['id'].toString()),
                                direction: DismissDirection.horizontal,
                                background: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  color: Colors.green,
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                ),
                                secondaryBackground: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  color: Colors.red,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  final supabase = Supabase.instance.client;
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    await supabase
                                        .from('reminder_logs')
                                        .insert({
                                      'reminder_id': r['id'],
                                      'date': DateFormat('yyyy-MM-dd')
                                          .format(selectedDate),
                                      'user_id': supabase.auth.currentUser!.id,
                                    });

                                    loadReminders();
                                    return false;
                                  }

                                  if (direction ==
                                      DismissDirection.endToStart) {
                                    await supabase
                                        .from('reminders')
                                        .delete()
                                        .eq('id', r['id']);

                                    await NotificationService.cancelAlarm(
                                        r['id']);

                                    loadReminders();
                                    return true;
                                  }

                                  return false;
                                },
                                child: GestureDetector(
                                  onTap: () => openReminder(reminder: r),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: iconColor(
                                            r['type'],
                                          ).withOpacity(.15),
                                          child: Icon(
                                            iconForType(r['type']),
                                            color: iconColor(r['type']),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      r['title'],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        decoration:
                                                            r['isCompleted'] ==
                                                                    true
                                                                ? TextDecoration
                                                                    .lineThrough
                                                                : null,
                                                      ),
                                                    ),
                                                  ),
                                                  if (r['isCompleted'] == true)
                                                    const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                      size: 20,
                                                    ),
                                                ],
                                              ),
                                              Text(
                                                r['time'],
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

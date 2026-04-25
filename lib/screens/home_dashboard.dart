import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vediqlog/providers/active_profile_provider.dart';
import 'package:vediqlog/theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final supabase = Supabase.instance.client;

  int totalReports = 0;
  bool loadingReports = true;

  String lastVitalText = "Loading...";
  bool loadingVitals = true;

  List<Map<String, dynamic>> recentReports = [];
  bool loadingRecent = true;

  List<Map<String, dynamic>> family = [];
  bool loadingFamily = true;

  List<Map<String, dynamic>> todayReminders = [];
  bool loadingToday = true;
  bool hasAnyReminders = false;
  bool allCompletedToday = false;

  Timer? snapshotTimer;
  String? lastLoadedProfileId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActiveProfileProvider>().initWithSelf();
      loadFamily();
      reloadAll();
    });

    snapshotTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      loadTodaySnapshot();
    });
  }

  @override
  void dispose() {
    snapshotTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final activeId = Provider.of<ActiveProfileProvider>(
      context,
    ).activeProfileId;

    if (activeId != lastLoadedProfileId) {
      lastLoadedProfileId = activeId;
      reloadAll();
    }
  }

  void reloadAll() {
    loadTotalReports();
    loadLastVital();
    loadRecentReports();
    loadTodaySnapshot();
  }

  /// FAMILY
  Future<void> loadFamily() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('family_links')
        .select('profiles!family_links_member_id_fkey(id, full_name)')
        .eq('owner_id', user.id);

    if (!mounted) return;

    setState(() {
      family = List<Map<String, dynamic>>.from(data);
      loadingFamily = false;
    });
  }

  /// REPORT COUNT
  Future<void> loadTotalReports() async {
    final id = context.read<ActiveProfileProvider>().activeProfileId;

    if (id.isEmpty) return;

    if (!mounted) return;
    setState(() => loadingReports = true);

    final data = await supabase.from('reports').select('id').eq('user_id', id);

    if (!mounted) return;

    setState(() {
      totalReports = data.length;
      loadingReports = false;
    });
  }

  /// LAST VITAL
  Future<void> loadLastVital() async {
    final id = context.read<ActiveProfileProvider>().activeProfileId;

    setState(() => loadingVitals = true);

    final data = await supabase
        .from('health_metrics')
        .select()
        .eq('user_id', id)
        .order('created_at', ascending: false)
        .limit(1);

    if (data.isEmpty) {
      setState(() {
        lastVitalText = AppLocalizations.of(context)!.noVitals;
        loadingVitals = false;
      });
      return;
    }

    final m = data.first;

    setState(() {
      lastVitalText = "${m['title']} : ${m['value']} (${m['status']})";
      loadingVitals = false;
    });
  }

  ///ASK DOCTOR

  Widget _askDoctorCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/ask-doctor'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
            ],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            /// 🔥 RIGHT GLOW ICON
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Color(0xFFFFD700),
                  size: 26,
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🟢 ONLINE STATUS
                Row(
                  children: const [
                    Icon(Icons.circle, color: Colors.green, size: 8),
                    SizedBox(width: 6),
                    Text(
                      "DOCTORS ONLINE NOW",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// 🧠 TITLE
                const Text(
                  "Ask Doctor",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                /// 📄 DESCRIPTION
                const Text(
                  "Get expert medical advice in minutes.\nMicro-consultations starting at ₹99.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 18),

                /// 👇 BOTTOM ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// 👨‍⚕️ AVATAR STACK
                    SizedBox(
                      width: 100,
                      height: 30,
                      child: Stack(
                        children: [
                          _doctorAvatar(0),
                          _doctorAvatar(18),
                          _doctorAvatar(36),
                          Positioned(
                            left: 54,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                "+12",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    /// 🚀 CTA BUTTON
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: const [
                          Text(
                            "Consult Now",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// TODAY SNAPSHOT
  Future<void> loadTodaySnapshot() async {
    final profileId = context.read<ActiveProfileProvider>().activeProfileId;
    if (profileId.isEmpty) return;

    final todayDate = DateTime.now();
    final todayKey = todayDate.toIso8601String().substring(0, 10);

    if (todayReminders.isEmpty) {
      setState(() => loadingToday = true);
    }

    /// Get ALL reminders first
    final allReminders =
        await supabase.from('reminders').select().eq('user_id', profileId);

    /// Check if user has ever created reminders
    bool anyReminderExists = allReminders.isNotEmpty;

    /// Now get non-completed reminders
    final data = allReminders.where((r) => r['completed'] != true).toList();

    final List<Map<String, dynamic>> result = [];

    for (final r in data) {
      final start = DateTime.parse(r['date']);
      final diff = todayDate.difference(start).inDays;

      if (diff < 0) continue;

      final repeatType = r['repeat_type'] ?? "one_time";
      final interval = r['repeat_interval_days'] ?? 1;

      bool show = false;

      if (repeatType == "one_time") {
        show = r['date'] == todayKey;
      } else if (repeatType == "everyday") {
        show = diff >= 0;
      } else {
        show = diff % interval == 0;
      }

      if (show) {
        result.add(Map<String, dynamic>.from(r));
      }
    }

    setState(() {
      todayReminders = result;
      hasAnyReminders = anyReminderExists;
      allCompletedToday = anyReminderExists && result.isEmpty;
      loadingToday = false;
    });
  }

  /// RECENT REPORTS
  Future<void> loadRecentReports() async {
    final id = context.read<ActiveProfileProvider>().activeProfileId;

    setState(() => loadingRecent = true);

    final data = await supabase
        .from('reports')
        .select()
        .eq('user_id', id)
        .order('created_at', ascending: false)
        .limit(2);

    setState(() {
      recentReports = List<Map<String, dynamic>>.from(data);
      loadingRecent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActiveProfileProvider>();

    return SafeArea(
      child: Container(
        color: AppColors.surface,
        child: RefreshIndicator(
          onRefresh: () async => reloadAll(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.welcomeBack,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.graphiteLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "VEDIQLOG",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.graphite,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: reloadAll,
                        ),
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: CircleAvatar(
                            backgroundColor: AppColors.goldLight,
                            child: Text(
                              (provider.activeProfileName ?? "").isNotEmpty
                                  ? provider.activeProfileName![0]
                                  : "U",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// FAMILY SWITCH
                SizedBox(
                  height: 90,
                  child: loadingFamily
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _familyAvatar(
                              AppLocalizations.of(context)!.me,
                              supabase.auth.currentUser!.id,
                            ),
                            ...family.map((f) {
                              final p = f['profiles'];
                              return _familyAvatar(
                                p?['full_name'] ?? "",
                                p?['id'] ?? "",
                              );
                            }),
                          ],
                        ),
                ),

                const SizedBox(height: 25),

                /// STATS
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        AppLocalizations.of(context)!.totalReports,
                        loadingReports ? "..." : "$totalReports",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoCard(
                        AppLocalizations.of(context)!.lastVitals,
                        loadingVitals ? "..." : lastVitalText,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                /// 🔥 ASK DOCTOR CARD
                _askDoctorCard(context),

                const SizedBox(height: 25),

                /// TODAY SNAPSHOT
                Text(
                  AppLocalizations.of(context)!.todaySnapshot,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.graphite,
                  ),
                ),
                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: loadingToday
                      ? const Center(child: CircularProgressIndicator())
                      : todayReminders.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  !hasAnyReminders
                                      ? "No reminders yet"
                                      : "No reminders today",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (!hasAnyReminders)
                                  const Text(
                                    "Add your first reminder",
                                    style: TextStyle(
                                      color: AppColors.graphiteLight,
                                    ),
                                  ),
                              ],
                            )
                          : Column(
                              children: todayReminders.map((r) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.alarm,
                                        color: AppColors.gold,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "${r['title']} • ${r['time']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                ),

                const SizedBox(height: 25),

                /// RECENT ACTIVITY
                Text(
                  AppLocalizations.of(context)!.recentActivity,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.graphite,
                  ),
                ),
                const SizedBox(height: 15),
                if (loadingRecent)
                  const Center(child: CircularProgressIndicator())
                else if (recentReports.isEmpty)
                  Text(AppLocalizations.of(context)!.noReports)
                else
                  Column(
                    children: recentReports.map((r) {
                      return _recentTile(
                        r['file_name'] ?? "",
                        r['category'] ?? "",
                        r['created_at'].toString().substring(0, 10),
                        AppLocalizations.of(context)!.report,
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 25),

                /// ACTIONS
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/emergency'),
                        child: _actionCard(
                          Icons.emergency,
                          AppLocalizations.of(context)!.emergency,
                          AppLocalizations.of(context)!.lifeSavingAccess,
                          Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/vault'),
                        child: _actionCard(
                          Icons.shield,
                          AppLocalizations.of(context)!.vault,
                          AppLocalizations.of(context)!.policiesAndClaims,
                          AppColors.graphite,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _doctorAvatar(double left) {
    return Positioned(
      left: left,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const CircleAvatar(
          radius: 12,
          backgroundImage: NetworkImage(
            "https://i.pravatar.cc/150?img=3",
          ),
        ),
      ),
    );
  }

  Widget _familyAvatar(String name, String id) {
    final provider = context.watch<ActiveProfileProvider>();
    final active = provider.activeProfileId == id;

    return GestureDetector(
      onTap: () {
        provider.switchProfile(profileId: id, profileName: name);
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    active ? Border.all(color: AppColors.gold, width: 2) : null,
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.blue.shade100,
                child: Text(name.isNotEmpty ? name[0].toUpperCase() : "U"),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 60,
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoCard(String t, String v) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.graphiteLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            v,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.graphite,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _recentTile(
    String title,
    String tag,
    String date,
    String reportLabel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "$reportLabel • $date",
                  style: const TextStyle(
                    color: AppColors.graphiteLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  static Widget _actionCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.graphiteLight,
            ),
          ),
        ],
      ),
    );
  }
}

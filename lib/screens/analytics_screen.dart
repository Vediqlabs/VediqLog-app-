import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vediqlog/providers/active_profile_provider.dart';
import 'package:vediqlog/theme/app_theme.dart';
import 'metric_detail_screen.dart';
import 'add_metric_sheet.dart';
import '../l10n/app_localizations.dart';
import 'package:vediqlog/core/health_engine.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Map<String, String>> metrics = [];
  bool loading = true;

  double? userHeight;
  int userAge = 0;
  String userGender = "Male";
  bool userIsDiabetic = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadMetrics();
    });
  }

  Future<void> loadMetrics() async {
    if (!mounted) return;
    setState(() => loading = true);

    final supabase = Supabase.instance.client;
    final profileId = context.read<ActiveProfileProvider>().activeProfileId;

    if (profileId.isEmpty) {
      setState(() => loading = false);
      return;
    }
    int getRiskPriority(String status) {
      final s = status.toLowerCase();

      if (s.contains("critical") ||
          s.contains("high") ||
          s.contains("obese") ||
          s.contains("sedentary")) {
        return 0; // 🔴 Highest priority
      }

      if (s.contains("low") ||
          s.contains("borderline") ||
          s.contains("overweight") ||
          s.contains("slightly")) {
        return 1; // 🟠 Medium
      }

      return 2; // 🟢 Normal
    }

    // ✅ LOAD PROFILE FIRST
    final profile =
        await supabase.from('profiles').select().eq('id', profileId).single();

    userHeight = (profile['height'] as num?)?.toDouble();
    userAge = profile['age'] ?? 0;
    userGender = profile['gender'] ?? "Male";
    userIsDiabetic = profile['is_diabetic'] ?? false;

    final data = await supabase
        .from('health_metrics')
        .select('id,title,value,status')
        .eq('user_id', profileId)
        .order('created_at', ascending: false);

    if (!mounted) return;

    setState(() {
      metrics = data.map<Map<String, String>>((e) {
        final value = double.tryParse(e['value']?.toString() ?? "0") ?? 0;

        final status = getMetricStatus(
          title: e['title'],
          value: value,
          heightCm: userHeight,
          age: userAge,
          gender: userGender,
          isDiabetic: userIsDiabetic,
        );

        return {
          "id": e['id'].toString(),
          "title": (e['title'] ?? "").toString(),
          "value": (e['value'] ?? "--").toString(),
          "status": status,
        };
      }).toList();

      // 🔥 SORT BY RISK
      metrics.sort((a, b) => getRiskPriority(a['status']!)
          .compareTo(getRiskPriority(b['status']!)));

      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.healthAnalytics,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.graphite,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.analyticsSubtitle,
                style: const TextStyle(
                  color: AppColors.graphiteLight,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),

              /// LOADING
              if (loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )

              /// EMPTY STATE
              else if (metrics.isEmpty)
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: _emptyState()),
                      GestureDetector(
                        onTap: () async {
                          final result = await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (_) => const AddMetricSheet(),
                          );

                          if (result == true) loadMetrics();
                        },
                        child: _addMetricCard(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                )

              /// GRID
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: loadMetrics,
                    child: GridView.builder(
                      itemCount: metrics.length + 1,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (context, index) {
                        if (index == metrics.length) {
                          return GestureDetector(
                            onTap: () async {
                              final result = await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (_) => const AddMetricSheet(),
                              );

                              if (result == true) {
                                loadMetrics();
                              }
                            },
                            child: _addMetricCard(),
                          );
                        }

                        final m = metrics[index];

                        final value = double.tryParse(m['value'] ?? "0") ?? 0;

                        String recalculatedStatus;

                        if (m['title'] == "Blood Pressure") {
                          final systolic = value;

                          if (systolic >= 140) {
                            recalculatedStatus = "HIGH_STAGE_2";
                          } else if (systolic >= 130) {
                            recalculatedStatus = "HIGH_STAGE_1";
                          } else if (systolic >= 120) {
                            recalculatedStatus = "ELEVATED";
                          } else {
                            recalculatedStatus = "NORMAL";
                          }
                        } else {
                          recalculatedStatus = getMetricStatus(
                            title: m['title']!,
                            value: value,
                            heightCm: userHeight,
                            age: userAge,
                            gender: userGender,
                            isDiabetic: userIsDiabetic,
                          );
                        }

                        return _metricCard(
                          m['id']!,
                          m['title']!,
                          m['value']!,
                          recalculatedStatus,
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String calculateStatusForDashboard(String title, double value) {
    if (title == "Sleep Hours") {
      if (value < 5) return "CRITICAL_LOW";
      if (value < 6) return "LOW";
      if (value <= 8) return "OPTIMAL";
      if (value <= 9) return "SLIGHTLY_HIGH";
      return "HIGH";
    }

    if (title == "Steps") {
      if (value < 3000) return "SEDENTARY";
      if (value < 6000) return "LOW_ACTIVITY";
      if (value <= 10000) return "MODERATE";
      return "ACTIVE";
    }

    if (title == "TSH") {
      if (value < 0.4) return "LOW";
      if (value > 4.0) return "HIGH";
      return "NORMAL";
    }

    if (title == "Cholesterol") {
      if (value >= 240) return "HIGH";
      if (value >= 200) return "BORDERLINE";
      return "NORMAL";
    }

    return "NORMAL";
  }

  Widget _metricCard(String id, String title, String value, String status) {
    final loc = AppLocalizations.of(context)!;
    Color badgeColor = AppColors.success;
    String localizedStatus = loc.normal;

    switch (status) {
      case "HIGH":
      case "HIGH_STAGE_1":
      case "HIGH_STAGE_2":
      case "CRITICAL_LOW":
      case "SEDENTARY":
      case "OBESE":
        badgeColor = Colors.red;
        localizedStatus = status.replaceAll("_", " ");
        break;

      case "LOW":
      case "LOW_ACTIVITY":
      case "BORDERLINE":
      case "SLIGHTLY_HIGH":
      case "OVERWEIGHT":
      case "UNDERWEIGHT":
        badgeColor = Colors.orange;
        localizedStatus = status.replaceAll("_", " ");
        break;

      case "DEFICIENT":
      case "HIGH":
        badgeColor = Colors.red;
        break;

      case "INSUFFICIENT":
        badgeColor = Colors.orange;
        break;
      case "OPTIMAL":
      case "MODERATE":
      case "ACTIVE":
      case "NORMAL":
      default:
        badgeColor = AppColors.success;
        localizedStatus = status.replaceAll("_", " ");
    }
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MetricDetailScreen(metricId: id, metricTitle: title),
          ),
        );

        loadMetrics();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.goldLight,
              child: Icon(Icons.favorite, color: AppColors.gold),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                localizedStatus,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addMetricCard() {
    final loc = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => const AddMetricSheet(),
        );

        if (result == true) loadMetrics();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFF5E7B5),
              child: Icon(Icons.add, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Text(
              loc.addMetric,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Tap to start tracking",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    final loc = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.monitor_heart, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            loc.noMetrics,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(loc.addFirstMetric, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

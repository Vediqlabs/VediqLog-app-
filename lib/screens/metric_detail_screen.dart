import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vediqlog/providers/active_profile_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../l10n/app_localizations.dart';
import 'package:vediqlog/core/metric_config.dart';
import 'package:vediqlog/core/health_engine.dart';

class MetricDetailScreen extends StatefulWidget {
  final String metricId;
  final String metricTitle;

  const MetricDetailScreen({
    super.key,
    required this.metricId,
    required this.metricTitle,
  });

  @override
  State<MetricDetailScreen> createState() => _MetricDetailScreenState();
}

class _MetricDetailScreenState extends State<MetricDetailScreen> {
  List<Map<String, dynamic>> readings = [];
  bool loading = true;
  double? userHeight;
  int userAge = 0;
  String userGender = "Male";
  bool userIsDiabetic = false;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> loadReadings() async {
    setState(() => loading = true);

    final supabase = Supabase.instance.client;
    final userId = context.read<ActiveProfileProvider>().activeProfileId;

    final data = await supabase
        .from('metric_readings')
        .select()
        .eq('user_id', userId)
        .eq('metric_id', widget.metricId)
        .order('created_at', ascending: false);

    if (!mounted) return;

    setState(() {
      readings = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  Future<void> initializeData() async {
    await loadUserProfile();
    await loadReadings();
  }

  Future<void> loadUserProfile() async {
    final supabase = Supabase.instance.client;
    final userId = context.read<ActiveProfileProvider>().activeProfileId;

    final data =
        await supabase.from('profiles').select().eq('id', userId).single();

    userHeight = (data['height'] as num?)?.toDouble();
    userAge = data['age'] ?? 0;
    userGender = data['gender'] ?? "Male";
    userIsDiabetic = data['is_diabetic'] ?? false;
  }

  /* ---------------- STATUS ---------------- */
  String calculateStatus(double value) {
    // 1️⃣ Blood Sugar
    if (widget.metricTitle == "Blood Sugar") {
      bool isFastingReading = false;

      if (readings.isNotEmpty) {
        isFastingReading = readings.first['is_fasting'] ?? false;
      }

      final range = getSugarRange(
        isDiabetic: userIsDiabetic,
        isFasting: isFastingReading,
      );

      if (value < range.min) return "Low";
      if (value > range.max) return "High";
      return "Normal";
    }

    // 2️⃣ Cholesterol
    if (widget.metricTitle == "Cholesterol") {
      return getCholesterolCategory(value);
    }

    // 3️⃣ HbA1c
    if (widget.metricTitle == "HbA1c") {
      return getHbA1cCategory(value);
    }

    // 4️⃣ TSH
    if (widget.metricTitle == "TSH") {
      return getTSHCategory(value);
    }
// 6️⃣ Heart Rate
    if (widget.metricTitle == "Heart Rate") {
      return getHeartRateCategory(value, userAge);
    }
    // 7️⃣ Hemoglobin
    if (widget.metricTitle == "Hemoglobin") {
      return getHemoglobinCategory(value, userGender);
    }
    // Sleep Intelligence
    if (widget.metricTitle == "Sleep Hours") {
      return getSleepCategory(value);
    }
    // Steps Intelligence
    if (widget.metricTitle == "Steps") {
      return getStepsCategory(value);
    }
    if (widget.metricTitle == "Vitamin D") {
      return "Deficient: < 20 ng/mL\nNormal: 30 – 100 ng/mL";
    }

    // 5️⃣ Weight (BMI)
    if (widget.metricTitle == "Weight") {
      final bmi = calculateBMI(
        heightCm: userHeight,
        weightKg: value,
      );

      if (bmi == null) return "Normal";

      final category = getBMICategory(bmi);

      if (category == "Normal") return "Normal";
      if (category == "Underweight") return "Low";
      return "High";
    }

    // 6️⃣ Default fallback
    final range = resolveHealthRange(
      metric: widget.metricTitle,
      height: userHeight,
      age: userAge,
      gender: userGender,
      isDiabetic: userIsDiabetic,
    );

    if (range == null) return "Normal";
    if (value < range.min) return "Low";
    if (value > range.max) return "High";

    return "Normal";
  }

/* ---------------- HEART RATE ---------------- */
  String getHeartRateCategory(double value, int age) {
    double min;
    double max;

    if (age < 18) {
      min = 70;
      max = 110;
    } else if (age <= 60) {
      min = 60;
      max = 100;
    } else {
      min = 60;
      max = 95;
    }

    if (value < min) return "Low";
    if (value > max) return "High";
    return "Normal";
  }

/* ---------------- HEMOGLOBIN ---------------- */
  String getHemoglobinCategory(double value, String gender) {
    double min;
    double max;

    if (gender == "Female") {
      min = 12.0;
      max = 15.5;
    } else {
      min = 13.5;
      max = 17.5;
    }

    if (value < min) return "Low";
    if (value > max) return "High";
    return "Normal";
  }

/* ---------------- SLEEP ---------------- */
  String getSleepCategory(double hours) {
    if (hours < 5) return "Critical Low";
    if (hours < 6) return "Low";
    if (hours <= 8) return "Optimal";
    if (hours <= 9) return "Slightly High";
    return "High";
  }

/* ---------------- STEPS ---------------- */
  String getStepsCategory(double steps) {
    if (steps < 3000) return "Sedentary";
    if (steps < 6000) return "Low Activity";
    if (steps <= 10000) return "Moderate";
    return "Active";
  }

  /* ---------------- UNIT ---------------- */
  String getUnit() {
    return metricConfigs[widget.metricTitle]?.unit ?? "";
  }
  /* ---------------- NORMAL RANGE ---------------- */

  String getNormalRange() {
    // ✅ Special case for Blood Pressure
    if (widget.metricTitle == "Blood Pressure") {
      return "Systolic: 90 – 120 mmHg\nDiastolic: 60 – 80 mmHg";
    }

    if (widget.metricTitle == "Cholesterol") {
      return "Normal: < 200 mg/dL\nBorderline: 200–239\nHigh: ≥ 240";
    }

    if (widget.metricTitle == "HbA1c") {
      return "Normal: < 5.7%\nPrediabetes: 5.7–6.4%\nDiabetes: ≥ 6.5%";
    }

    if (widget.metricTitle == "TSH") {
      return "Normal: 0.4 – 4.0 mIU/L\nLow: < 0.4\nHigh: > 4.0";
    }

    if (widget.metricTitle == "Hemoglobin") {
      if (userGender == "Female") {
        return "Normal: 12.0 – 15.5 g/dL";
      } else {
        return "Normal: 13.5 – 17.5 g/dL";
      }
    }
    if (widget.metricTitle == "Sleep Hours") {
      return "Optimal: 6 – 8 hrs\nLow: < 6 hrs\nHigh: > 9 hrs";
    }
    if (widget.metricTitle == "Steps") {
      return "Sedentary: < 3000\nModerate: 6000 – 10000\nActive: > 10000";
    }
    if (widget.metricTitle == "Vitamin D") {
      return "Deficient: < 20 ng/mL\n"
          "Insufficient: 20 – 29 ng/mL\n"
          "Normal: 30 – 100 ng/mL";
    }

    final range = resolveHealthRange(
      metric: widget.metricTitle,
      height: userHeight,
      age: userAge,
      gender: userGender,
      isDiabetic: userIsDiabetic,
    );

    if (range == null) return "--";

    return "${range.min.toStringAsFixed(1)} – ${range.max.toStringAsFixed(1)} ${getUnit()}";
  }

  /* ---------------- CHART ---------------- */
  Color statusColor(String s) {
    final status = s.toLowerCase();

    if (status.contains("critical") ||
        status.contains("high") ||
        status.contains("sedentary")) {
      return Colors.red;
    }

    if (status.contains("low") ||
        status.contains("borderline") ||
        status.contains("prediabetes") ||
        status.contains("elevated") ||
        status.contains("slightly")) {
      return Colors.orange;
    }

    return Colors.green;
  }

  Widget buildChart() {
    if (readings.isEmpty) return const SizedBox();

    final values = readings
        .map((e) => double.tryParse(e['reading_value'].toString()) ?? 0)
        .where((v) => v > 0)
        .toList()
        .reversed
        .toList();

    if (values.isEmpty) return const SizedBox();
    final spots = values
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final range = resolveHealthRange(
      metric: widget.metricTitle,
      height: userHeight,
      age: userAge,
      gender: userGender,
      isDiabetic: userIsDiabetic,
    );

    double minValue = values.reduce((a, b) => a < b ? a : b);
    double maxValue = values.reduce((a, b) => a > b ? a : b);

    if (range != null) {
      if (range.min < minValue) minValue = range.min;
      if (range.max > maxValue) maxValue = range.max;
    }

    double padding = (maxValue - minValue) * 0.15;
    if (padding == 0) padding = 5;

    double minY = minValue - padding;
    double maxY = maxValue + padding;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: SizedBox(
        height: 230,
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            extraLinesData: ExtraLinesData(
              horizontalLines: range == null
                  ? []
                  : [
                      HorizontalLine(
                        y: range.min,
                        color: Colors.green.withOpacity(0.3),
                        strokeWidth: 2,
                        dashArray: [5, 5],
                      ),
                      HorizontalLine(
                        y: range.max,
                        color: Colors.red.withOpacity(0.3),
                        strokeWidth: 2,
                        dashArray: [5, 5],
                      ),
                    ],
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.amber,
                barWidth: 3,
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.amber.withOpacity(0.15),
                ),
                dotData: FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
  /* ---------------- ADD READING ---------------- */

  void showAddReadingSheet() {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool isFasting = false;
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.addReading,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (widget.metricTitle == "Blood Pressure") ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: systolicController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Systolic",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: diastolicController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Diastolic",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: t.enterValue,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(DateFormat("dd MMM yyyy").format(selectedDate)),
                      const Spacer(),
                      TextButton(
                        child: Text(t.change),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setSheetState(() => selectedDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                  if (widget.metricTitle == "Blood Sugar")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Fasting Reading"),
                        Switch(
                          value: isFasting,
                          onChanged: (v) {
                            setSheetState(() {
                              isFasting = v;
                            });
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 100),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(t.save),
                    onPressed: () async {
                      final supabase = Supabase.instance.client;
                      final userId =
                          context.read<ActiveProfileProvider>().activeProfileId;

                      if (widget.metricTitle == "Blood Pressure") {
                        final systolic =
                            double.tryParse(systolicController.text);
                        final diastolic =
                            double.tryParse(diastolicController.text);

                        if (systolic == null || diastolic == null) return;

                        String status;

                        if (systolic < 120 && diastolic < 80) {
                          status = "Normal";
                        } else if (systolic < 130 && diastolic < 80) {
                          status = "Elevated";
                        } else if (systolic < 140 || diastolic < 90) {
                          status = "High Stage 1";
                        } else {
                          status = "High Stage 2";
                        }

                        try {
                          await supabase.from('metric_readings').insert({
                            'user_id': userId,
                            'metric_id': widget.metricId,
                            'systolic': systolic,
                            'diastolic': diastolic,
                            'reading_value': systolic,
                            'reading_date': selectedDate.toIso8601String(),
                          });

                          print("BP INSERT SUCCESS");
                        } catch (e) {
                          print("BP INSERT ERROR: $e");
                        }

                        await supabase
                            .from('health_metrics')
                            .update({'value': systolic, 'status': status}).eq(
                                'id', widget.metricId);
                      } else {
                        final value = double.tryParse(controller.text);
                        if (value == null) return;
                        if (widget.metricTitle == "Heart Rate") {
                          if (value < 30 || value > 220) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Enter valid heart rate (30–220 bpm)"),
                              ),
                            );
                            return;
                          }
                        }

                        if (widget.metricTitle == "Weight") {
                          if (value < 30 || value > 250) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Enter valid weight")),
                            );
                            return;
                          }
                        }

                        final status = calculateStatus(value);

                        await supabase.from('metric_readings').insert({
                          'user_id': userId,
                          'metric_id': widget.metricId,
                          'reading_value': value,
                          'reading_date': selectedDate.toIso8601String(),
                          'is_fasting': widget.metricTitle == "Blood Sugar"
                              ? isFasting
                              : null,
                        });

                        await supabase.from('health_metrics').update({
                          'value': value.toString(),
                          'status': status
                        }).eq('id', widget.metricId);
                      }

                      Navigator.pop(context);
                      loadReadings();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final latest = readings.isNotEmpty ? readings.first : null;

    double latestValue = latest != null
        ? double.tryParse(latest['reading_value'].toString()) ?? 0
        : 0;

    String displayValue = "--";

    if (latest != null) {
      if (widget.metricTitle == "Blood Pressure") {
        final sys = latest['systolic'];
        final dia = latest['diastolic'];

        if (sys != null && dia != null) {
          displayValue = "$sys/$dia";
        }
      } else {
        displayValue = latestValue == 0 ? "--" : latestValue.toStringAsFixed(1);
      }
    }
    String status = getMetricStatus(
      title: widget.metricTitle,
      value: latestValue,
      age: userAge,
      gender: userGender,
      isDiabetic: userIsDiabetic,
      heightCm: userHeight,
      systolic: widget.metricTitle == "Blood Pressure" && latest != null
          ? (latest['systolic'] as num?)?.toDouble()
          : null,
      diastolic: widget.metricTitle == "Blood Pressure" && latest != null
          ? (latest['diastolic'] as num?)?.toDouble()
          : null,
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(widget.metricTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* VALUE */
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              displayValue,
                              style: TextStyle(
                                fontSize: 46,
                                fontWeight: FontWeight.bold,
                                color: statusColor(status),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              getUnit(),
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          status,
                          style: TextStyle(color: statusColor(status)),
                        ),
                        if (widget.metricTitle == "Sleep Hours" &&
                            latestValue > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              latestValue < 6
                                  ? "Low sleep increases BP, sugar & stress risk"
                                  : latestValue > 9
                                      ? "Excess sleep may indicate fatigue or hormonal imbalance"
                                      : "Sleep duration is within optimal health range",
                              style: TextStyle(
                                fontSize: 13,
                                color: statusColor(status),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (widget.metricTitle == "Steps" && latestValue > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              latestValue < 3000
                                  ? "Low activity increases diabetes & heart risk"
                                  : latestValue < 6000
                                      ? "Increase daily movement to reduce metabolic risk"
                                      : latestValue <= 10000
                                          ? "Healthy activity level"
                                          : "Excellent activity level",
                              style: TextStyle(
                                fontSize: 13,
                                color: statusColor(status),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (widget.metricTitle == "Weight" && latestValue > 0)
                          Builder(
                            builder: (_) {
                              final bmi = calculateBMI(
                                heightCm: userHeight,
                                weightKg: latestValue,
                              );

                              if (bmi == null) return const SizedBox();

                              final category = getBMICategory(bmi);

                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  "BMI: ${bmi.toStringAsFixed(1)} ($category)",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        if (latest != null)
                          Text(
                            "${t.lastReadingOn} ${DateFormat("dd MMM yyyy").format(DateTime.parse(latest['reading_date']))}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  buildChart(),
                  const SizedBox(height: 16),

                  /* NORMAL RANGE */
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "NORMAL RANGE",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          getNormalRange(), // ← COMMA HERE
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    t.history,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...readings.map((r) {
                    String v = "--";
                    double numericValue = 0;

                    if (widget.metricTitle == "Blood Pressure") {
                      final sys = r['systolic'];
                      final dia = r['diastolic'];

                      if (sys != null && dia != null) {
                        v = "$sys/$dia";
                        numericValue = double.tryParse(sys.toString()) ?? 0;
                      }
                    } else {
                      final value = double.tryParse(
                              r['reading_value']?.toString() ?? "0") ??
                          0;

                      numericValue = value;
                      v = value.toString();
                    }

                    final s = getMetricStatus(
                      title: widget.metricTitle,
                      value: numericValue,
                      age: userAge,
                      gender: userGender,
                      isDiabetic: userIsDiabetic,
                      heightCm: userHeight,
                      systolic: widget.metricTitle == "Blood Pressure"
                          ? (r['systolic'] as num?)?.toDouble()
                          : null,
                      diastolic: widget.metricTitle == "Blood Pressure"
                          ? (r['diastolic'] as num?)?.toDouble()
                          : null,
                    );
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat("dd MMM yyyy")
                                .format(DateTime.parse(r['reading_date'])),
                          ),
                          Text(
                            v,
                            style: TextStyle(
                              color: statusColor(s),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 90),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        minimumSize: const Size(double.infinity, 55),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: Text(t.addNewReading),
                      onPressed: showAddReadingSheet,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

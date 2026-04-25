import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vediqlog/providers/active_profile_provider.dart';
import '../l10n/app_localizations.dart';

class AddMetricSheet extends StatefulWidget {
  const AddMetricSheet({super.key});

  @override
  State<AddMetricSheet> createState() => _AddMetricSheetState();
}

class _AddMetricSheetState extends State<AddMetricSheet> {
  String selectedMetric = "Weight";
  bool saving = false;

  final metrics = [
    {"key": "Weight", "unit": "kg"},
    {"key": "Heart Rate", "unit": "bpm"},
    {"key": "Blood Pressure", "unit": "mmHg"},
    {"key": "Blood Sugar", "unit": "mg/dL"},
    {"key": "HbA1c", "unit": "%"},
    {"key": "Hemoglobin", "unit": "g/dL"},
    {"key": "Cholesterol", "unit": "mg/dL"},
    {"key": "Vitamin D", "unit": "ng/mL"},
    {"key": "TSH", "unit": "mIU/L"},
    {"key": "Steps", "unit": "steps"},
    {"key": "Sleep Hours", "unit": "hrs"},
  ];

  Future<void> saveMetric() async {
    final supabase = Supabase.instance.client;
    final profileId = context.read<ActiveProfileProvider>().activeProfileId;

    if (profileId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.profileNotReady)),
      );
      return;
    }

    setState(() => saving = true);

    try {
      /// Check if already exists
      final existing = await supabase
          .from('health_metrics')
          .select('id')
          .eq('user_id', profileId)
          .eq('title', selectedMetric)
          .maybeSingle();

      if (existing != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Metric already added")));

        setState(() => saving = false);
        return;
      }

      /// Insert metric
      await supabase.from('health_metrics').insert({
        'user_id': profileId,
        'title': selectedMetric,
        'value': 0,
        'status': "NORMAL",
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.metricSaveError)),
      );
    }

    if (mounted) setState(() => saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
            l10n.addMetric,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          /// Metric list
          SizedBox(
            height: 320,
            child: ListView.builder(
              itemCount: metrics.length,
              itemBuilder: (_, i) {
                final m = metrics[i];
                final selected = selectedMetric == m["key"];

                return GestureDetector(
                  onTap: () => setState(() => selectedMetric = m["key"]!),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.amber.withOpacity(.15)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? Colors.amber : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.amber),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            m["key"]!,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),

                        Text(
                          m["unit"]!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: saving ? null : saveMetric,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.all(14),
              ),
              child: saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(l10n.saveMetric),
            ),
          ),
        ],
      ),
    );
  }
}

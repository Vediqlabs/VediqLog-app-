import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vediqlog/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'report_pdf_preview_screen.dart';
import 'report_image_preview_screen.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> filteredReports = [];
  final searchController = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() => loading = false);
      return;
    }

    try {
      final data = await supabase
          .from('reports')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        reports = List<Map<String, dynamic>>.from(data);
        filteredReports = reports;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  void filterReports(String query) {
    final q = query.toLowerCase();

    setState(() {
      filteredReports = reports.where((r) {
        final name = (r['file_name'] ?? '').toString().toLowerCase();
        return name.contains(q);
      }).toList();
    });
  }

  String formatDate(String? dateString) {
    if (dateString == null) return "--";
    final dt = DateTime.parse(dateString);
    return DateFormat("MMM dd, yyyy").format(dt);
  }

  Future<void> openFile(String? url) async {
    if (url == null || url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Text(
                t.healthTimeline,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.graphite,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t.timelineSubtitle,
                style: const TextStyle(color: AppColors.graphiteLight),
              ),

              const SizedBox(height: 20),

              /// SEARCH BAR
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: filterReports,
                        decoration: InputDecoration(
                          hintText: t.searchReports,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Icon(Icons.tune, color: Colors.grey),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// CONTENT
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredReports.isEmpty
                    ? Center(child: Text(t.noReportsUploaded))
                    : ListView.builder(
                        itemCount: filteredReports.length,
                        itemBuilder: (context, index) {
                          final report = filteredReports[index];

                          final title =
                              (report['file_name'] ?? '').toString().isEmpty
                              ? t.defaultReport
                              : report['file_name'];

                          final date = formatDate(report['created_at']);

                          final fileUrl = report['file_url'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                if (fileUrl == null) return;

                                final lower = fileUrl.toLowerCase();

                                if (lower.endsWith('.pdf')) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ReportPdfPreviewScreen(url: fileUrl),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReportImagePreviewScreen(
                                        url: fileUrl,
                                      ),
                                    ),
                                  );
                                }
                              },

                              child: _timelineCard(
                                title: title,
                                tag: t.report,
                                date: date,
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

  Widget _timelineCard({
    required String title,
    required String tag,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.goldLight,
            child: Icon(Icons.menu_book, color: AppColors.gold),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.graphite,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.graphiteLight,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}

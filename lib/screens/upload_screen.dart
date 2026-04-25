import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vediqlog/providers/active_profile_provider.dart';
import '../l10n/app_localizations.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool uploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> captureAndUpload() async {
    final t = AppLocalizations.of(context)!;

    List<XFile> photos = [];

    while (true) {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

      if (photo == null) break;

      photos.add(photo);

      final addMore = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Add another page?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Done"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Add More"),
            ),
          ],
        ),
      );

      if (addMore != true) break;
    }

    if (photos.isEmpty) return;

    final activeProfileId =
        context.read<ActiveProfileProvider>().activeProfileId;

    if (activeProfileId.isEmpty) return;

    setState(() => uploading = true);

    final supabase = Supabase.instance.client;

    try {
      final reportBatchId = DateTime.now().millisecondsSinceEpoch.toString();

      final pdf = pw.Document();

      for (final photo in photos) {
        final bytes = await File(photo.path).readAsBytes();

        final image = pw.MemoryImage(bytes);

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
      }

      final pdfBytes = await pdf.save();

      final fileName = "report_${DateTime.now().millisecondsSinceEpoch}.pdf";

      final storagePath = 'uploads/$activeProfileId/$fileName';

      await supabase.storage
          .from('REPORTS')
          .uploadBinary(storagePath, pdfBytes);

      final fileUrl =
          supabase.storage.from('REPORTS').getPublicUrl(storagePath);

      await supabase.from('reports').insert({
        'user_id': activeProfileId,
        'file_name': fileName,
        'file_url': fileUrl,
        'category': 'REPORT',
        'created_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.reportUploadedSuccess)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }

    setState(() => uploading = false);
  }

  void showUploadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Scan using Camera"),
                onTap: () {
                  Navigator.pop(context);
                  captureAndUpload();
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text("Upload from Phone"),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUpload();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickAndUpload() async {
    final t = AppLocalizations.of(context)!;

    final result = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: true,
    );

    if (result == null) return;

    final activeProfileId =
        context.read<ActiveProfileProvider>().activeProfileId;

    if (activeProfileId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.noActiveProfile)));
      return;
    }

    setState(() => uploading = true);

    final supabase = Supabase.instance.client;

    try {
      for (final file in result.files) {
        final fileBytes = file.bytes;
        if (fileBytes == null) continue;

        final fileName = file.name;

        final storagePath =
            'uploads/$activeProfileId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

        await supabase.storage
            .from('REPORTS')
            .uploadBinary(storagePath, fileBytes);

        final fileUrl =
            supabase.storage.from('REPORTS').getPublicUrl(storagePath);

        await supabase.from('reports').insert({
          'user_id': activeProfileId,
          'file_name': fileName,
          'file_url': fileUrl,
          'category': 'REPORT',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.reportUploadedSuccess)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${t.uploadFailed}: $e")));
    }

    setState(() => uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final activeName = context.watch<ActiveProfileProvider>().activeProfileName;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text("${t.uploadReport} ($activeName)"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            /// Upload Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.upload_file,
                    size: 60,
                    color: Color(0xFF0F172A),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.uploadMedicalReport,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.uploadFormats,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  uploading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: showUploadOptions,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              t.pickUpload,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// Info Section
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t.uploadInfo,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

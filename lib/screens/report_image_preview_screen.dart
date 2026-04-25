import 'package:flutter/material.dart';

class ReportImagePreviewScreen extends StatelessWidget {
  final String url;

  const ReportImagePreviewScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report Preview")),
      body: Center(child: InteractiveViewer(child: Image.network(url))),
    );
  }
}

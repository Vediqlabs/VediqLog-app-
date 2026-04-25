import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReportPdfPreviewScreen extends StatefulWidget {
  final String url;

  const ReportPdfPreviewScreen({super.key, required this.url});

  @override
  State<ReportPdfPreviewScreen> createState() => _ReportPdfPreviewScreenState();
}

class _ReportPdfPreviewScreenState extends State<ReportPdfPreviewScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    final viewerUrl =
        "https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(widget.url)}";

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(viewerUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report Preview")),
      body: WebViewWidget(controller: controller),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DocsScreen extends StatefulWidget {
  const DocsScreen({super.key});

  @override
  State<DocsScreen> createState() => _DocsScreenState();
}

class _DocsScreenState extends State<DocsScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    
    // Исправленный URL (убраны лишние пробелы)
    final url = 'https://getsouf.github.io/food-recognizer-client/';
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            // Можно добавить логику
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Документация')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
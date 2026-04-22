import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StartupWebViewScreen extends StatefulWidget {
  const StartupWebViewScreen({
    super.key,
    required this.initialUrl,
  });

  final String initialUrl;

  @override
  State<StartupWebViewScreen> createState() => _StartupWebViewScreenState();
}

class _StartupWebViewScreenState extends State<StartupWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FanArena'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

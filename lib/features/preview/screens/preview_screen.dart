import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/console_drawer.dart';

class PreviewScreen extends StatefulWidget {
  final String html;
  final String css;
  final String js;

  const PreviewScreen({
    super.key,
    required this.html,
    required this.css,
    required this.js,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late final WebViewController _controller;
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'ConsoleChannel',
        onMessageReceived: (JavaScriptMessage message) {
          setState(() {
            _logs.add(message.message);
          });
        },
      )
      ..loadHtmlString(_combineCode());
  }

  String _combineCode() {
    // Inject CSS into <style> and JS into <script>
    // Also inject a bridge for console.log
    String combined = widget.html;

    // Bridge for console.log
    const String consoleBridge = '''
      <script>
        (function() {
          var oldLog = console.log;
          console.log = function(message) {
            ConsoleChannel.postMessage(message.toString());
            oldLog.apply(console, arguments);
          };
        })();
      </script>
    ''';

    // Inject CSS
    if (combined.contains('</head>')) {
      combined = combined.replaceFirst('</head>', '<style>${widget.css}</style></head>');
    } else {
      combined = '<style>${widget.css}</style>$combined';
    }

    // Inject JS and Bridge
    if (combined.contains('</body>')) {
      combined = combined.replaceFirst('</body>', '$consoleBridge<script>${widget.js}</script></body>');
    } else {
      combined = '$combined$consoleBridge<script>${widget.js}</script>';
    }

    return combined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.terminal),
            tooltip: 'Console',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => ConsoleDrawer(logs: _logs),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.loadHtmlString(_combineCode());
            },
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

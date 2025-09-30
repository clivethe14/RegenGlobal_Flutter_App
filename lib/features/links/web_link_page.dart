import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class WebLinkPage extends StatelessWidget {
  final String url;
  const WebLinkPage({super.key, required this.url});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open Link')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(url, textAlign: TextAlign.center),
            ),
            FilledButton(
              onPressed: () async {
                final uri = Uri.parse(url);
                final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open $url')),
                  );
                }
              },
              child: const Text('Open in Browser'),
            ),
          ],
        ),
      ),
    );
  }
}
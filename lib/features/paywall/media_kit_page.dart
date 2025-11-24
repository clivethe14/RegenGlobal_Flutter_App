import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Media Kit hub page with 2 buttons:
/// 1) View Regen Media Kit PPT (external link)
/// 2) Place an Ad in Regen Media (form)
class MediaKitPage extends StatelessWidget {
  const MediaKitPage({super.key});

  static const String defaultMediaKitUrl =
      'https://example.com/regen-media-kit.pptx'; // Update this link later

  Future<void> _launchMediaKitUrl() async {
    final url = Uri.parse(defaultMediaKitUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regen Media Kit'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Regen Global Magazine',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sponsorship • Advertisement • Content Submission',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 48),

              // Button 1: View Media Kit PPT
              ElevatedButton.icon(
                icon: const Icon(Icons.file_download_outlined),
                label: const Text('View Media Kit (PDF/PPT)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  try {
                    await _launchMediaKitUrl();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error opening media kit: $e')),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 16),

              // Button 2: Place an Ad
              ElevatedButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Place an Ad'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  context.push('/form/magazine_ad_request');
                },
              ),
              const SizedBox(height: 48),

              // Description
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How it works:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Download our media kit to see advertising options, pricing, and reach\n'
                      '• Fill out the ad request form to submit your advertisement\n'
                      '• Our team will contact you to finalize details and placement',
                      style: TextStyle(fontSize: 14, height: 1.6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

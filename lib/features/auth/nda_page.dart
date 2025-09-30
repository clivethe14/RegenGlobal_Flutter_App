import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NdaPage extends StatefulWidget {
  final String nextRoute; // where to go after accepting
  const NdaPage({super.key, required this.nextRoute});

  @override
  State<NdaPage> createState() => _NdaPageState();
}

class _NdaPageState extends State<NdaPage> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NDA Agreement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  // Replace with your actual NDA text
                  'This Non-Disclosure Agreement (NDA) is between Regeneration Global and the user. '
                      'By continuing, you agree not to share or misuse confidential information obtained '
                      'through use of this app. Full legal text goes here…',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _agreed,
              onChanged: (v) => setState(() => _agreed = v ?? false),
              title: const Text('I have read and agree to the NDA terms'),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _agreed ? () => context.go(widget.nextRoute) : null,
                child: const Text('I Agree'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// IMPORTANT: import the canonical models file with package path & alias
import '../../core/form_engine/models.dart' as fe;

// Common dashboard catalog (tiles) + helpers
import '../catalogs/catalog.dart';     // exports: dashboardLinks and your tile model
import '../../dev/dev_tools.dart';       // currentPlan(), switchPlan(), dashboardPathForPlan()

class AllianceDashboardPage extends StatelessWidget {
  const AllianceDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = dashboardLinks;

    // Alliance-only extra cards (append to the end)
    // 1) Spatial booking
    // 2) Magazine ad request  <-- NEW
    const extraCount = 2;
    final itemCount = tiles.length + extraCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alliance Dashboard'),
        actions: [
          if (kDebugMode)
            PopupMenuButton<String>(
              icon: const Icon(Icons.bug_report_outlined),
              onSelected: (value) async {
                final m = ScaffoldMessenger.of(context);
                try {
                  switch (value) {
                    case 'alliance':
                      await switchPlan('alliance');
                      m.showSnackBar(const SnackBar(content: Text('Switched to Alliance')));
                      if (!context.mounted) return;
                      context.go(dashboardPathForPlan('alliance'));
                      break;
                    case 'general':
                      await switchPlan('general');
                      m.showSnackBar(const SnackBar(content: Text('Switched to General')));
                      if (!context.mounted) return;
                      context.go(dashboardPathForPlan('general'));
                      break;
                    case 'signout':
                      await Supabase.instance.client.auth.signOut();
                      if (!context.mounted) return;
                      context.go('/free');
                      break;
                  }
                } catch (e) {
                  m.showSnackBar(SnackBar(content: Text('Dev action failed: $e')));
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'alliance', child: Text('Switch to Alliance')),
                PopupMenuItem(value: 'general', child: Text('Switch to General')),
                PopupMenuDivider(),
                PopupMenuItem(value: 'signout', child: Text('Sign out')),
              ],
            ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.15,
        ),
        itemCount: itemCount,
        itemBuilder: (context, i) {
          final isExtra = i >= tiles.length;
          if (isExtra) {
            final extraIndex = i - tiles.length;
            switch (extraIndex) {
              case 0: // Spatial booking (existing)
                return Card(
                  child: InkWell(
                    onTap: () => context.push('/form/spatial_booking'),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_seat_outlined, size: 40),
                          SizedBox(height: 8),
                          Text('Book a Spatial.io Table', textAlign: TextAlign.center),
                          SizedBox(height: 4),
                          Text('Promote your organization in our virtual world',
                              textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                );
              case 1: // NEW: Magazine Ad Request
                return Card(
                  child: InkWell(
                    onTap: () => context.push('/form/magazine_ad_request'),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book_outlined, size: 40),
                          SizedBox(height: 8),
                          Text('Regen Media Kit', textAlign: TextAlign.center),
                          SizedBox(height: 4),
                          Text('Sponsorship · Advertisment · Content Submission',
                              textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                );
            }
          }

          // Otherwise render your existing catalog tile at index i
          final data = tiles[i];
          return Card(
            child: InkWell(
              onTap: () {
                switch (data.destinationType) {
                  case fe.DestinationType.form:
                    if (data.formId != null) context.push('/form/${data.formId}');
                    break;
                  case fe.DestinationType.external:
                    if (data.url != null) {
                      final u = Uri.encodeComponent(data.url!);
                      context.push('/link?url=$u');
                    }
                    break;
                  case fe.DestinationType.list:
                    if (data.listId != null) context.push('/list/${data.listId}');
                    break;
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(data.icon, size: 40),
                    const SizedBox(height: 8),
                    Text(data.title, textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium),
                    if (data.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(data.subtitle, textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

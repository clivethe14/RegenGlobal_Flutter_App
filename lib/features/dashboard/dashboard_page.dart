// lib/features/dashboard/dashboard_page.dart
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Use the canonical package import + alias to avoid duplicate-type issues
import 'package:regen_global/core/form_engine/models.dart' as fe;

// Adjust these paths to your structure if needed
import '../catalogs/catalog.dart';   // exports: dashboardLinks + tile model
import '../../dev/dev_tools.dart';     // switchPlan(), dashboardPathForPlan()

class DashboardPage extends StatelessWidget {
  final String title;
  const DashboardPage({super.key, this.title = 'Dashboard'});

  @override
  Widget build(BuildContext context) {
    final tiles = dashboardLinks;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
                      context.go('/dashboard/alliance');
                      break;
                    case 'general':
                      await switchPlan('general');
                      m.showSnackBar(const SnackBar(content: Text('Switched to General')));
                      if (!context.mounted) return;
                      context.go('/dashboard/general');
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
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          // Slightly taller cards to reduce risk of overflow on long titles
          childAspectRatio: 1.05,
        ),
        itemCount: tiles.length,
        itemBuilder: (context, i) {
          final data = tiles[i];

          return Card(
            child: InkWell(
              onTap: () {
                if (data.destinationType case fe.DestinationType.form) {
                  if (data.formId != null) {
                    context.push('/form/${data.formId}');
                  }
                } else if (data.destinationType case fe.DestinationType.external) {
                  if (data.url != null) {
                    final u = Uri.encodeComponent(data.url!);
                    context.push('/link?url=$u');
                  }
                } else if (data.destinationType case fe.DestinationType.list) {
                  if (data.listId != null) {
                    context.push('/list/${data.listId}');
                  }
                }
              },
              child: _TileCardContent(
                icon: data.icon,
                title: data.title,
                subtitle: (data.subtitle.isNotEmpty) ? data.subtitle : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A compact, overflow-safe tile body used by all dashboard cards.
/// - Makes text flexible & ellipsized (prevents RenderFlex overflow)
/// - Keeps the same look/feel as your previous tiles
class _TileCardContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const _TileCardContent({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final subStyle = Theme.of(context).textTheme.bodySmall;

    return Padding(
      padding: const EdgeInsets.all(10), // a touch smaller than 12
      child: Column(
        mainAxisSize: MainAxisSize.max,     // take full tile height
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 6),
          Icon(icon, size: 34),             // slightly smaller icon
          const SizedBox(height: 6),

          // EXPANDED block: forces texts to layout within remaining space
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                    softWrap: true,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: subStyle,
                      softWrap: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}


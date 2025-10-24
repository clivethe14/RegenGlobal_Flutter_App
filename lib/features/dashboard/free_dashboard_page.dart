import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Use the canonical package import + alias to avoid duplicate-type issues
import 'package:regen_global/core/form_engine/models.dart' as fe;

// Pull the same LinkSpecs the paid dashboard uses
import '../catalogs/catalog.dart'; // exports: dashboardLinks + model types

class FreeDashboardPage extends StatelessWidget {
  const FreeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use EXACTLY the two tiles from catalog.dart by id
    final tiles = dashboardLinks
        .where((t) =>
    t.id == 'latest_regen_global_magazine' ||
        t.id == 'tile_events')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Regeneration Global'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Grid (two tiles only)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  // Match paid dashboard sizing
                  childAspectRatio: 1.05,
                ),
                itemCount: tiles.length,
                itemBuilder: (context, i) {
                  final data = tiles[i];
                  return Card(
                    child: InkWell(
                      onTap: () {
                        // ⚡ EXACT navigation behavior as paid dashboard_page.dart
                        if (data.destinationType case fe.DestinationType.form) {
                          if (data.formId != null) {
                            context.push('/form/${data.formId}');
                          }
                        } else if (data.destinationType
                        case fe.DestinationType.external) {
                          if (data.url != null) {
                            final u = Uri.encodeComponent(data.url!);
                            context.push('/link?url=$u');
                          }
                        } else if (data.destinationType
                        case fe.DestinationType.list) {
                          if (data.listId != null) {
                            context.push('/list/${data.listId}');
                          }
                        }
                      },
                      child: _FreeTileCardContent(
                        icon: data.icon,
                        title: data.title,
                        subtitle: (data.subtitle.isNotEmpty)
                            ? data.subtitle
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Sign in / Create account row (push so back returns to Free)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.push('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Sign In'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => context.push('/signup'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Create Account'),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

/// A compact, overflow-safe tile body matching the paid dashboard’s look.
class _FreeTileCardContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const _FreeTileCardContent({
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
      // mirror paid dashboard spacing
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const SizedBox(height: 6),
          Icon(icon, size: 34),
          const SizedBox(height: 6),
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

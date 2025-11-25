import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Use the canonical package import + alias to avoid duplicate-type issues
import 'package:regen_global/core/form_engine/models.dart' as fe;

// Pull the same LinkSpecs the paid dashboard uses
import '../catalogs/catalog.dart'; // exports: dashboardLinks + model types
import 'dashboard_theme.dart';

class FreeDashboardPage extends StatelessWidget {
  const FreeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use EXACTLY the two tiles from catalog.dart by id
    final tiles = dashboardLinks
        .where((t) =>
            t.id == 'latest_regen_global_magazine' || t.id == 'tile_events')
        .toList();

    final colors = DashboardTheme.generalColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Regeneration Global'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.gradient1, colors.gradient2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 8,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.light.withOpacity(0.3), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Grid (two tiles only)
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(DashboardTheme.gridSpacing),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: DashboardTheme.gridSpacing,
                    crossAxisSpacing: DashboardTheme.gridSpacing,
                    // Larger cards for only 2 tiles
                    childAspectRatio: 0.75,
                  ),
                  itemCount: tiles.length,
                  itemBuilder: (context, i) {
                    final data = tiles[i];
                    return Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(DashboardTheme.borderRadius),
                      ),
                      shadowColor: colors.primary.withOpacity(0.3),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              DashboardTheme.borderRadius),
                          gradient: LinearGradient(
                            colors: [
                              colors.light.withOpacity(0.5),
                              Colors.white
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                              DashboardTheme.borderRadius),
                          onTap: () {
                            // ⚡ EXACT navigation behavior as paid dashboard_page.dart
                            if (data.destinationType
                                case fe.DestinationType.form) {
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
                            colors: colors,
                          ),
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
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () => context.push('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: OutlinedButton(
                      onPressed: () => context.push('/signup'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: colors.primary, width: 2),
                      ),
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                            color: colors.primary, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact, overflow-safe tile body matching the paid dashboard's look.
class _FreeTileCardContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final ColorPalette colors;
  const _FreeTileCardContent({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        );
    final subStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey.shade600,
        );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 36, color: colors.primary),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                    softWrap: true,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Flexible(
                    child: Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: subStyle,
                      softWrap: true,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

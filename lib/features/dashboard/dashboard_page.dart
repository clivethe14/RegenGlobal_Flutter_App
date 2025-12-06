// lib/features/dashboard/dashboard_page.dart
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Use the canonical package import + alias to avoid duplicate-type issues
import 'package:regen_global/core/form_engine/models.dart' as fe;

// Adjust these paths to your structure if needed
import '../catalogs/catalog.dart'; // exports: dashboardLinks + tile model
import '../../dev/dev_tools.dart'; // switchPlan(), dashboardPathForPlan()
import 'dashboard_theme.dart';

class DashboardPage extends StatelessWidget {
  final String title;
  const DashboardPage({super.key, this.title = 'Dashboard'});

  @override
  Widget build(BuildContext context) {
    // Replace social_channels with tier-specific general version
    final tiles = dashboardLinks.map((link) {
      if (link.id == 'tile_social') {
        return fe.LinkSpec(
          id: link.id,
          title: link.title,
          subtitle: link.subtitle,
          icon: link.icon,
          destinationType: link.destinationType,
          listId: 'social_channels_general',
        );
      }
      return link;
    }).toList();
    final colors = DashboardTheme.generalColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
        titleSpacing: 8,
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
                      m.showSnackBar(const SnackBar(
                          content: Text('Switched to Affiliate')));
                      if (!context.mounted) return;
                      context.go('/dashboard/alliance');
                      break;
                    case 'general':
                      await switchPlan('general');
                      m.showSnackBar(
                          const SnackBar(content: Text('Switched to General')));
                      if (!context.mounted) return;
                      context.go('/dashboard/general');
                      break;
                    case 'associate':
                      await switchPlan('associate');
                      m.showSnackBar(const SnackBar(
                          content: Text('Switched to Associate')));
                      if (!context.mounted) return;
                      context.go('/dashboard/associate');
                      break;
                    case 'signout':
                      await Supabase.instance.client.auth.signOut();
                      if (!context.mounted) return;
                      context.go('/free');
                      break;
                  }
                } catch (e) {
                  m.showSnackBar(
                      SnackBar(content: Text('Dev action failed: $e')));
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                    value: 'alliance', child: Text('Switch to Affiliate')),
                PopupMenuItem(
                    value: 'general', child: Text('Switch to General')),
                PopupMenuItem(
                    value: 'associate', child: Text('Switch to Associate')),
                PopupMenuDivider(),
                PopupMenuItem(value: 'signout', child: Text('Sign out')),
              ],
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.light.withOpacity(0.3), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(DashboardTheme.gridSpacing),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: DashboardTheme.gridSpacing,
            crossAxisSpacing: DashboardTheme.gridSpacing,
            childAspectRatio: 0.95,
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
                  borderRadius:
                      BorderRadius.circular(DashboardTheme.borderRadius),
                  gradient: LinearGradient(
                    colors: [colors.light.withOpacity(0.5), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(DashboardTheme.borderRadius),
                  onTap: () {
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
                    } else if (data.destinationType
                        case fe.DestinationType.route) {
                      if (data.routePath != null) {
                        context.push(data.routePath!);
                      }
                    }
                  },
                  child: _TileCardContent(
                    icon: data.icon,
                    title: data.title,
                    subtitle: (data.subtitle.isNotEmpty) ? data.subtitle : null,
                  ),
                ),
              ),
            );
          },
        ),
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
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
          fontSize: 13,
        );
    final subStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey.shade600,
          fontSize: 11,
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
            child: Icon(icon, size: 29, color: Colors.blue.shade600),
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

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// IMPORTANT: import the canonical models file with package path & alias
import '../../core/form_engine/models.dart' as fe;

// Common dashboard catalog (tiles) + helpers
import '../catalogs/catalog.dart'; // exports: dashboardLinks and your tile model
import '../../dev/dev_tools.dart'; // currentPlan(), switchPlan(), dashboardPathForPlan()
import 'dashboard_theme.dart';

class AssociateDashboardPage extends StatelessWidget {
  const AssociateDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = dashboardLinks;
    final colors = DashboardTheme.associateColors;

    // Associate-only extra cards (append to the end)
    // 1) Spatial booking
    // 2) Magazine ad request
    const extraCount = 2;
    final itemCount = tiles.length + extraCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Associate Dashboard'),
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
                          content: Text('Switched to Alliance')));
                      if (!context.mounted) return;
                      context.go(dashboardPathForPlan('alliance'));
                      break;
                    case 'general':
                      await switchPlan('general');
                      m.showSnackBar(
                          const SnackBar(content: Text('Switched to General')));
                      if (!context.mounted) return;
                      context.go(dashboardPathForPlan('general'));
                      break;
                    case 'associate':
                      await switchPlan('associate');
                      m.showSnackBar(const SnackBar(
                          content: Text('Switched to Associate')));
                      if (!context.mounted) return;
                      context.go(dashboardPathForPlan('associate'));
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
            childAspectRatio: 1.15,
          ),
          itemCount: itemCount,
          itemBuilder: (context, i) {
            final isExtra = i >= tiles.length;
            if (isExtra) {
              final extraIndex = i - tiles.length;
              switch (extraIndex) {
                case 0:
                  return _buildExtraCard(
                      context,
                      Icons.event_seat_outlined,
                      'Book a Spatial.io Table',
                      'Promote your organization in our virtual world',
                      colors,
                      () => context.push('/form/spatial_booking'));
                case 1:
                  return _buildExtraCard(
                      context,
                      Icons.menu_book_outlined,
                      'Regen Media Kit',
                      'Sponsorship · Advertisement · Content Submission',
                      colors,
                      () => context.push('/media-kit'));
              }
            }

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
                    switch (data.destinationType) {
                      case fe.DestinationType.form:
                        if (data.formId != null)
                          context.push('/form/${data.formId}');
                        break;
                      case fe.DestinationType.external:
                        if (data.url != null) {
                          final u = Uri.encodeComponent(data.url!);
                          context.push('/link?url=$u');
                        }
                        break;
                      case fe.DestinationType.list:
                        if (data.listId != null)
                          context.push('/list/${data.listId}');
                        break;
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(DashboardTheme.cardPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child:
                              Icon(data.icon, size: 40, color: colors.primary),
                        ),
                        const SizedBox(height: 12),
                        Flexible(
                          child: Text(data.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        if (data.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Flexible(
                            child: Text(data.subtitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey.shade600)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExtraCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    ColorPalette colors,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DashboardTheme.borderRadius),
      ),
      shadowColor: colors.primary.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DashboardTheme.borderRadius),
          gradient: LinearGradient(
            colors: [colors.light.withOpacity(0.5), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(DashboardTheme.borderRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(DashboardTheme.cardPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 40, color: colors.primary),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Text(title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey.shade600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

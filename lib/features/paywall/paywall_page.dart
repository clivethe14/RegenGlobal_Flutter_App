import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../payments/purchases_provider.dart';
import '../../payments/purchase_service.dart';

String _nextRouteForEntitlements(Entitlements e) {
  if (e.alliance) return '/dashboard/alliance';
  if (e.general)  return '/dashboard/general';
  // fallback if something odd happens
  return '/';
}

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  final _svc = getPurchasesService();
  late Future<List<PurchasePackage>> _pkgs;

  @override
  void initState() {
    super.initState();
    _pkgs = _svc.getPackages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your plan')),
      body: FutureBuilder<List<PurchasePackage>>(
        future: _pkgs,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Failed to load plans: ${snap.error}'));
          }
          final pkgs = snap.data ?? const [];
          if (pkgs.isEmpty) {
            return const Center(child: Text('No plans available right now.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pkgs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final p = pkgs[i];
              return Card(
                child: ListTile(
                  title: Text(p.display),
                  subtitle: Text(p.price),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () async {
                    final m = ScaffoldMessenger.of(context);
                    try {
                      final ents = await _svc.purchase(p);
                      m.showSnackBar(SnackBar(
                          content: Text('Activated ${ents.plan} (${ents.term})')));
                      if (!mounted) return;
                      // context.go(
                      //   ents.alliance
                      //       ? '/dashboard/alliance'
                      //       : '/dashboard/general',
                      // );
                      final nextRoute = _nextRouteForEntitlements(ents);
                      context.go('/nda?next=$nextRoute');
                    } catch (e) {
                      m.showSnackBar(
                          SnackBar(content: Text('Purchase failed: $e')));
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Text(
            'You can change available plans later (e.g. remove Quarterly) '
                'without updating the app.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}

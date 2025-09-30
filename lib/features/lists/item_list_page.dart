import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../catalogs/catalog.dart';

class ItemListPage extends StatelessWidget {
  final String listId;
  const ItemListPage({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    final cfg = listCatalog[listId];
    if (cfg == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('List')),
        body: Center(child: Text('List "$listId" not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(cfg.title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: cfg.items.length + (cfg.description == null ? 0 : 1),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (cfg.description != null && index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(cfg.description!, style: Theme.of(context).textTheme.bodyMedium),
            );
          }
          final i = cfg.description == null ? index : index - 1;
          final item = cfg.items[i];
          return Card(
            child: ListTile(
              leading: item.leadingIcon != null ? Icon(item.leadingIcon) : null,
              title: Text(item.title),
              subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if (item.linkUrl != null && item.linkUrl!.isNotEmpty) {
                  context.push('/link?url=${Uri.encodeComponent(item.linkUrl!)}');
                } else if (cfg.targetFormId != null) {
                  context.push('/form/${cfg.targetFormId}', extra: item.prefill);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

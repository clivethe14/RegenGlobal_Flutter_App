import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'payments/initialize.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://ytzylyxshlshrawikfkb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl0enlseXhzaGxzaHJhd2lrZmtiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg1NzU5NTUsImV4cCI6MjA3NDE1MTk1NX0.OzoQ2WX1BXFRps7bwceLCc6kdwBA20uXPTkS50bejZU',
  );

  // Initialize RevenueCat
  await initializeRevenueCat();

  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Modular Forms Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

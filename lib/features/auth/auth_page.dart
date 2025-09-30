import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 8),
            TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: loading ? null : () async {
                setState(() => loading = true);
                try {
                  await Supabase.instance.client.auth.signInWithPassword(
                    email: emailCtrl.text.trim(),
                    password: passCtrl.text,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed in.')));
                } on AuthException catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                } finally {
                  if (mounted) setState(() => loading = false);
                }
              },
              child: Text(loading ? 'Signing in...' : 'Sign in'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                try {
                  await Supabase.instance.client.auth.signUp(
                    email: emailCtrl.text.trim(),
                    password: passCtrl.text,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account created. Check email if confirmations are on.')),
                  );
                } on AuthException catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                }
              },
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dev/dev_tools.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String plan = 'general'; // default
  bool loading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final email = emailCtrl.text.trim();
    final password = passCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }
    setState(() => loading = true);
    try {
      // Save plan in user_metadata
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'plan': plan}, // store plan now
      );

      // If email confirmations ON, user might need to confirm first.
      // For now, route based on what we just set / current session state:
      final session = res.session ?? Supabase.instance.client.auth.currentSession;
      if (!mounted) return;

      if (session == null) {
        // No session yet (confirmations ON) – go to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created. Please sign in.')),
        );
        context.go('/login');
        return;
      }

      // Session present: route to dashboard by plan
      context.go('/');

    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        appBar: AppBar(title: const Text('Sign Up')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 120,
                        ),
                      ),
                    ),
                    TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                    const SizedBox(height: 8),
                    TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                    const SizedBox(height: 16),
                    // DropdownButtonFormField<String>(
                    //   value: plan,
                    //   items: const [
                    //     DropdownMenuItem(value: 'general', child: Text('General (for normal customers)')),
                    //     DropdownMenuItem(value: 'alliance', child: Text('Alliance (for businesses)')),
                    //   ],
                    //   onChanged: (v) => setState(() => plan = v ?? 'general'),
                    //   decoration: const InputDecoration(labelText: 'Subscription Type'),
                    // ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: loading ? null : _signUp,
                      child: Text(loading ? 'Creating...' : 'Create account'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Already have an account? Login'),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
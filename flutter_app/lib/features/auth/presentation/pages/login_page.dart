import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();

  bool _isLoading   = false;
  bool _obscurePass = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (mounted) context.go('/dashboard');
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding:    const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:        theme.colorScheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(Icons.language_rounded,
                            size: 48, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      Text('Bienvenue', style: theme.textTheme.displayMedium),
                      const SizedBox(height: 4),
                      Text('登入繼續學習法語',
                          style: theme.textTheme.bodyLarge!.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(153))),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                TextFormField(
                  controller:   _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration:   const InputDecoration(
                    labelText:  'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) =>
                      v == null || !v.contains('@') ? '請輸入有效的 Email' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller:  _passwordCtrl,
                  obscureText: _obscurePass,
                  decoration:  InputDecoration(
                    labelText:  '密碼',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? '密碼至少 6 個字元' : null,
                ),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_error!,
                        style: TextStyle(color: theme.colorScheme.error)),
                  ),

                const SizedBox(height: 24),

                FilledButton(
                  onPressed: _isLoading ? null : _signIn,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('登入'),
                ),
                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: () => context.push('/auth/register'),
                    child: const Text('還沒有帳號？點此註冊'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

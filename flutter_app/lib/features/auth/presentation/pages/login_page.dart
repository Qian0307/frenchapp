import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_theme.dart';

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
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (mounted) context.go('/dashboard');
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } on Exception catch (e) {
      final msg = e.toString();
      setState(() => _error = msg.contains('SocketException') || msg.contains('Failed host lookup')
          ? '網路連線失敗，請確認網路後重試'
          : '登入失敗，請稍後再試');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient ──────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [AppTheme.surfaceDark, const Color(0xFF161E35)]
                    : [AppTheme.primary, const Color(0xFF2A4D8F)],
                stops: const [0.0, 1.0],
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
                  child: Column(
                    children: [
                      // French flag tricolor
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _FlagBar(Colors.white.withAlpha(200)),
                          const SizedBox(width: 3),
                          _FlagBar(Colors.white.withAlpha(200)),
                          const SizedBox(width: 3),
                          _FlagBar(AppTheme.red.withAlpha(220)),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Bonjour',
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '歡迎回來，繼續你的法語旅程',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.white.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // ── Form card ─────────────────────────────
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('登入帳號',
                                style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 8),
                            _GoldDivider(),
                            const SizedBox(height: 28),

                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (v) =>
                                  v == null || !v.contains('@') ? '請輸入有效的 Email' : null,
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePass,
                              decoration: InputDecoration(
                                labelText: '密碼',
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

                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppTheme.red.withAlpha(15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.red.withAlpha(60)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: AppTheme.red, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(_error!,
                                        style: TextStyle(color: AppTheme.red, fontSize: 13))),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 28),

                            FilledButton(
                              onPressed: _isLoading ? null : _signIn,
                              child: _isLoading
                                  ? const SizedBox(width: 22, height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('登入'),
                            ),

                            const SizedBox(height: 16),

                            Center(
                              child: TextButton(
                                onPressed: () => context.push('/auth/register'),
                                child: RichText(
                                  text: TextSpan(
                                    text: '還沒有帳號？',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    children: [
                                      TextSpan(
                                        text: ' 立即註冊',
                                        style: TextStyle(
                                          color: AppTheme.gold,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlagBar extends StatelessWidget {
  const _FlagBar(this.color);
  final Color color;
  @override
  Widget build(BuildContext context) =>
      Container(width: 28, height: 5, decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(3)));
}

class _GoldDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 48, height: 3, margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
              color: AppTheme.gold, borderRadius: BorderRadius.circular(2)));
}

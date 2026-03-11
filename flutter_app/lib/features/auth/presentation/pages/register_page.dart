import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  String  _selectedLevel = 'A1';
  bool    _isLoading     = false;
  bool    _obscurePass   = true;
  String? _error;
  bool    _registered    = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        data: {
          'username': _usernameCtrl.text.trim(),
          'target_level': _selectedLevel,
        },
      );
      if (!mounted) return;
      if (response.session != null) {
        context.go('/dashboard');
      } else {
        setState(() => _registered = true);
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } on Exception catch (e) {
      final msg = e.toString();
      setState(() => _error = msg.contains('SocketException') || msg.contains('Failed host lookup')
          ? '網路連線失敗，請確認網路後重試'
          : '註冊失敗，請稍後再試');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_registered) return _VerifyEmailScreen(email: _emailCtrl.text.trim());

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [AppTheme.surfaceDark, const Color(0xFF161E35)]
                    : [AppTheme.primary, const Color(0xFF2A4D8F)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    children: [
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
                      const SizedBox(height: 24),
                      Text('Commençons',
                          style: Theme.of(context).textTheme.displayMedium!
                              .copyWith(color: Colors.white, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Text('建立帳號，開始法語學習之旅',
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(color: Colors.white.withAlpha(180))),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('建立帳號',
                                style: Theme.of(context).textTheme.headlineMedium),
                            _GoldDivider(),
                            const SizedBox(height: 24),

                            TextFormField(
                              controller: _usernameCtrl,
                              decoration: const InputDecoration(
                                labelText: '暱稱',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) =>
                                  v == null || v.length < 2 ? '至少 2 個字元' : null,
                            ),
                            const SizedBox(height: 14),

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
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePass,
                              decoration: InputDecoration(
                                labelText: '密碼',
                                hintText: '至少 6 個字元',
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
                            const SizedBox(height: 24),

                            Text('目前法語程度',
                                style: Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: AppConstants.cefrLevels.map((level) {
                                final selected = _selectedLevel == level;
                                final color = AppTheme.cefrColors[level]!;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedLevel = level),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: selected ? color : color.withAlpha(20),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: selected ? color : color.withAlpha(60),
                                        width: selected ? 2 : 1,
                                      ),
                                    ),
                                    child: Text(level,
                                        style: TextStyle(
                                          color: selected ? Colors.white : color,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        )),
                                  ),
                                );
                              }).toList(),
                            ),

                            if (_error != null) ...[
                              const SizedBox(height: 16),
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
                              onPressed: _isLoading ? null : _register,
                              child: _isLoading
                                  ? const SizedBox(width: 22, height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('建立帳號'),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: TextButton(
                                onPressed: () => context.pop(),
                                child: RichText(
                                  text: TextSpan(
                                    text: '已有帳號？',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    children: [
                                      TextSpan(
                                        text: ' 返回登入',
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

class _VerifyEmailScreen extends StatelessWidget {
  const _VerifyEmailScreen({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mark_email_unread_rounded,
                    size: 64, color: AppTheme.gold),
              ),
              const SizedBox(height: 28),
              Text('確認你的 Email',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                '我們已寄送驗證信到\n$email\n\n請點擊信中的連結完成註冊。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(160)),
              ),
              const SizedBox(height: 36),
              FilledButton(
                onPressed: () => context.go('/auth/login'),
                child: const Text('回到登入頁'),
              ),
            ],
          ),
        ),
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
      Container(width: 48, height: 3, margin: const EdgeInsets.only(top: 6, bottom: 0),
          decoration: BoxDecoration(
              color: AppTheme.gold, borderRadius: BorderRadius.circular(2)));
}

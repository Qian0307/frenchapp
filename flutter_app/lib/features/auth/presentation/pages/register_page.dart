import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';

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
  String? _error;
  bool    _registered    = false; // 顯示「請驗證 Email」畫面

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
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        data: {
          'username':     _usernameCtrl.text.trim(),
          'target_level': _selectedLevel,
        },
      );

      if (!mounted) return;

      // 已有 session → 直接進入（Supabase 關閉 email 確認時）
      if (response.session != null) {
        context.go('/dashboard');
      } else {
        // 需要 email 確認
        setState(() => _registered = true);
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('SocketException') || msg.contains('Failed host lookup') || msg.contains('network')) {
        setState(() => _error = '網路連線失敗，請確認網路後重試');
      } else {
        setState(() => _error = '註冊失敗：$msg');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ── 已送出，等待 Email 驗證 ──────────────────────────────
    if (_registered) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mark_email_unread_rounded,
                      size: 72, color: theme.colorScheme.primary),
                  const SizedBox(height: 24),
                  Text('確認你的 Email', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  Text(
                    '我們已寄送驗證信到\n${_emailCtrl.text.trim()}\n\n請點擊信中的連結後再回來登入。',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge!.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(180)),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => context.go('/auth/login'),
                    child: const Text('回到登入頁'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ── 註冊表單 ─────────────────────────────────────────────
    return Scaffold(
      appBar: AppBar(title: const Text('建立帳號')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('開始你的法語學習旅程', style: theme.textTheme.titleLarge),
                const SizedBox(height: 32),

                TextFormField(
                  controller:  _usernameCtrl,
                  decoration:  const InputDecoration(
                    labelText:  '暱稱',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      v == null || v.length < 2 ? '至少 2 個字元' : null,
                ),
                const SizedBox(height: 12),

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
                  obscureText: true,
                  decoration:  const InputDecoration(
                    labelText:  '密碼',
                    prefixIcon: Icon(Icons.lock_outline),
                    hintText:   '至少 6 個字元',
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? '密碼至少 6 個字元' : null,
                ),
                const SizedBox(height: 24),

                Text('目標程度', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: AppConstants.cefrLevels.map((level) {
                    final selected = _selectedLevel == level;
                    return ChoiceChip(
                      label:    Text(level),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedLevel = level),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!,
                        style: TextStyle(color: theme.colorScheme.error)),
                  ),

                FilledButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('建立帳號'),
                ),
                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('已有帳號？返回登入'),
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

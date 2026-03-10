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
      await Supabase.instance.client.auth.signUp(
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        data: {
          'username':      _usernameCtrl.text.trim(),
          'target_level':  _selectedLevel,
        },
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
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your learning journey starts here.',
                    style: theme.textTheme.titleLarge),
                const SizedBox(height: 32),

                TextFormField(
                  controller:  _usernameCtrl,
                  decoration:  const InputDecoration(
                    labelText:  'Username',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v == null || v.length < 3
                      ? 'Min 3 characters' : null,
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
                      v == null || !v.contains('@') ? 'Valid email required' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller:  _passwordCtrl,
                  obscureText: true,
                  decoration:  const InputDecoration(
                    labelText:  'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) => v == null || v.length < 6
                      ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 24),

                Text('Target CEFR Level', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: AppConstants.cefrLevels.map((level) {
                    final selected = _selectedLevel == level;
                    return ChoiceChip(
                      label:    Text(level),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedLevel = level),
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
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Create Account'),
                ),

                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Already have an account? Sign in'),
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

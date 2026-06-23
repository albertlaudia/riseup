import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isSignUp = false;
  bool _busy = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;
    setState(() => _busy = true);
    final notifier = ref.read(userStateProvider.notifier);
    if (_isSignUp) {
      await notifier.signUp(_emailCtrl.text.trim(), _passCtrl.text, name: _nameCtrl.text.trim());
    } else {
      await notifier.signIn(_emailCtrl.text.trim(), _passCtrl.text);
    }
    if (!mounted) return;
    setState(() => _busy = false);
    final state = ref.read(userStateProvider);
    if (state.hasValue && state.value!.userId.isNotEmpty) {
      context.go('/');
    } else if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: ${state.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 64, height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.ink, shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text('R', style: AppText.display(size: 30, color: AppColors.paper)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isSignUp ? 'Create your account' : 'Welcome back',
                    textAlign: TextAlign.center,
                    style: AppText.display(size: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp
                        ? 'A small daily practice. A streak that doesn\'t care about your mood.'
                        : 'Pick up where you left off.',
                    textAlign: TextAlign.center,
                    style: AppText.body(size: 14, color: AppColors.inkMute),
                  ),
                  const SizedBox(height: 28),
                  if (_isSignUp) ...[
                    _field(controller: _nameCtrl, label: 'Name', keyboardType: TextInputType.name),
                    const SizedBox(height: 12),
                  ],
                  _field(controller: _emailCtrl, label: 'Email', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _field(controller: _passCtrl, label: 'Password', obscure: true),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.paper, strokeWidth: 2,
                              ),
                            )
                          : Text(_isSignUp ? 'Create account' : 'Sign in'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(
                      _isSignUp ? 'Already have an account? Sign in' : 'New here? Create an account',
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Text(
                      'You can browse without signing in. Sign in to keep a streak and unlock Pro.',
                      textAlign: TextAlign.center,
                      style: AppText.body(size: 11, color: AppColors.inkMute),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Continue without signing in'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.paperCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.ink.withValues(alpha: 0.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.ink.withValues(alpha: 0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}

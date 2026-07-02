import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/app_constants.dart';
import '../providers/app_providers.dart';
import '../providers/auth_providers.dart';
import '../services/appwrite_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/errors.dart';
import '../widgets/empty_state.dart';
import '../widgets/haptic.dart';

class SigninScreen extends ConsumerStatefulWidget {
  const SigninScreen({super.key});

  @override
  ConsumerState<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends ConsumerState<SigninScreen> {
  bool _isSignUp = false;
  bool _obscure = true;
  bool _submitting = false;
  String? _error;
  bool _agreedToTerms = false;
  bool _marketingOptIn = false;
  String _displayName = '';

  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    Haptic.light();
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      if (_isSignUp) {
        if (!_agreedToTerms) {
          throw _FriendlyException('Please agree to the Terms and Privacy Policy to continue.');
        }
        final strength = passwordStrength(_password.text);
        if (!strength.isAcceptable) {
          throw _FriendlyException('Pick a stronger password (8+ characters, mixing letters and numbers).');
        }
        final name = _displayName.trim().isNotEmpty
            ? _displayName.trim()
            : _email.text.split('@').first;
        await ref.read(userStateProvider.notifier).signUp(
              email: _email.text.trim(),
              password: _password.text,
              displayName: name,
              marketingOptIn: _marketingOptIn,
            );
        // First-time sign-up goes to Welcome screen.
        if (mounted) context.go('/auth/welcome?name=${Uri.encodeComponent(name)}');
      } else {
        await ref.read(userStateProvider.notifier).signIn(
              email: _email.text.trim(),
              password: _password.text,
            );
        // Returning sign-in: silent, just go to library.
        if (mounted) context.go('/library');
      }
    } catch (e) {
      Haptic.notify('error');
      if (mounted) {
        setState(() {
          _error = e is _FriendlyException ? e.message : formatAuthError(e);
        });
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _forgotPassword() async {
    final emailCtrl = TextEditingController(text: _email.text);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.walrus,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Forgot password?', style: AppText.display(size: 22)),
              const SizedBox(height: 8),
              Text(
                'Enter your email and we\'ll send a recovery link.',
                style: AppText.body(size: 14, color: AppColors.inkSoft, height: 1.5),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: AppText.body(size: 15),
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: AppColors.walrus,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(emailCtrl.text.trim()),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.paper,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Send recovery link', style: AppText.body(size: 15)),
              ),
            ],
          ),
        );
      },
    );
    if (result == null || result.isEmpty || !mounted) return;
    try {
      await ref.read(appwriteProvider).recover(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check $result\'s inbox for a recovery link.'),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formatAuthError(e)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = passwordStrength(_password.text);
    final canSubmit = _email.text.trim().isNotEmpty &&
        _password.text.isNotEmpty &&
        !_submitting &&
        (!_isSignUp || (_agreedToTerms && strength.isAcceptable));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            const SizedBox(height: 24),
            Text(AppConstants.appName, style: AppText.display(size: 28)),
            const SizedBox(height: 4),
            Text(AppConstants.appTagline, style: AppText.body(size: 14, color: AppColors.inkSoft)),
            const SizedBox(height: 32),

            // Toggle between Sign in / Create account
            _ModeToggle(
              isSignUp: _isSignUp,
              onChanged: (v) {
                Haptic.selection();
                setState(() {
                  _isSignUp = v;
                  _error = null;
                });
              },
            ),
            const SizedBox(height: 24),

            // Email field
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
              style: AppText.body(size: 15),
              decoration: _decoration(label: 'Email', icon: Icons.email_outlined),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Display name (sign-up only)
            if (_isSignUp) ...[
              TextField(
                onChanged: (v) => _displayName = v,
                textCapitalization: TextCapitalization.words,
                style: AppText.body(size: 15),
                decoration: _decoration(
                  label: 'Name (optional)',
                  hint: "We'll use this to greet you.",
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Password field
            TextField(
              controller: _password,
              obscureText: _obscure,
              style: AppText.body(size: 15),
              decoration: _decoration(
                label: 'Password',
                icon: Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.inkMute,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ).copyWith(
                errorText: _isSignUp && _password.text.isNotEmpty && !strength.isAcceptable
                    ? 'Pick a stronger password'
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),

            // Password strength meter (sign-up only)
            if (_isSignUp && _password.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              _PasswordStrengthMeter(strength: strength),
            ],

            // Forgot password (sign-in only)
            if (!_isSignUp) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: Text('Forgot password?',
                      style: AppText.body(size: 12, color: AppColors.inkSoft)),
                ),
              ),
            ],

            // Terms + Privacy (sign-up only)
            if (_isSignUp) ...[
              const SizedBox(height: 8),
              _ConsentRow(
                text: 'I agree to the Terms and Privacy Policy',
                richText: _TermsRichText(),
                value: _agreedToTerms,
                onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
              ),
              const SizedBox(height: 4),
              _ConsentRow(
                text: 'Send me product updates (optional)',
                value: _marketingOptIn,
                onChanged: (v) => setState(() => _marketingOptIn = v ?? false),
              ),
            ],

            // Error display
            if (_error != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: _error!),
            ],

            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: canSubmit ? _submit : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.paper,
                  disabledBackgroundColor: AppColors.walrus,
                  disabledForegroundColor: AppColors.inkMute,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.paper),
                      )
                    : Text(
                        _isSignUp ? 'Create account' : 'Sign in',
                        style: AppText.display(size: 17, color: AppColors.paper),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Continue without signing in
            Center(
              child: TextButton(
                onPressed: _submitting ? null : () {
                  Haptic.light();
                  context.go('/library');
                },
                child: Text('Continue without an account',
                    style: AppText.body(size: 13, color: AppColors.inkMute)),
              ),
            ),

            const SizedBox(height: 24),

            // Support link
            Center(
              child: Text.rich(
                TextSpan(
                  style: AppText.body(size: 11, color: AppColors.inkMute),
                  children: [
                    const TextSpan(text: 'Need help? '),
                    TextSpan(
                      text: AppConstants.supportEmail,
                      style: const TextStyle(decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        // ignore: deprecated_member_use
                        // launchUrl(Uri.parse('mailto:${AppConstants.supportEmail}'));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    String? hint,
    IconData? icon,
    Widget? suffix,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: AppColors.inkMute, size: 20) : null,
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.walrus,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      );
}

class _ModeToggle extends StatelessWidget {
  final bool isSignUp;
  final ValueChanged<bool> onChanged;
  const _ModeToggle({required this.isSignUp, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.walrus,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _btn('Sign in', !isSignUp, () => onChanged(false)),
          _btn('Create account', isSignUp, () => onChanged(true)),
        ],
      ),
    );
  }

  Widget _btn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppConstants.shortAnim,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.paper : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppText.body(size: 14, color: active ? AppColors.ink : AppColors.inkMute),
          ),
        ),
      ),
    );
  }
}

class _PasswordStrengthMeter extends StatelessWidget {
  final PasswordStrength strength;
  const _PasswordStrengthMeter({required this.strength});

  @override
  Widget build(BuildContext context) {
    final filled = strength.score.clamp(0, 4);
    final color = switch (strength.score) {
      0 => AppColors.walrus,
      1 => const Color(0xFFC97D60),
      2 => const Color(0xFFD4A574),
      3 => const Color(0xFFA8B89A),
      _ => AppColors.accent,
    };
    return Row(
      children: [
        for (var i = 0; i < 4; i++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i < filled ? color : AppColors.walrus,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i < 3) const SizedBox(width: 4),
        ],
        const SizedBox(width: 12),
        SizedBox(
          width: 56,
          child: Text(
            strength.label,
            style: AppText.body(size: 11, color: AppColors.inkMute),
          ),
        ),
      ],
    );
  }
}

class _ConsentRow extends StatelessWidget {
  final String? text;
  final TextSpan? richText;
  final bool value;
  final ValueChanged<bool?> onChanged;
  const _ConsentRow({
    this.text,
    this.richText,
    required this.value,
    required this.onChanged,
  }) : assert(text != null || richText != null);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22, height: 22,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.accent,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: richText != null
                  ? RichText(text: richText!)
                  : Text(text!, style: AppText.body(size: 13, color: AppColors.inkSoft, height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsRichText extends TextSpan {
  _TermsRichText()
      : super(
          style: AppText.body(size: 13, color: AppColors.inkSoft, height: 1.4),
          children: [
            const TextSpan(text: 'I agree to the '),
            TextSpan(
              text: 'Terms',
              style: const TextStyle(decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()..onTap = () {
                // launchUrl(Uri.parse(AppConstants.termsUrl));
              },
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: const TextStyle(decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()..onTap = () {
                // launchUrl(Uri.parse(AppConstants.privacyUrl));
              },
            ),
          ],
        );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E6DF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🌧️', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: AppText.body(size: 13, color: AppColors.ink, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _FriendlyException implements Exception {
  final String message;
  _FriendlyException(this.message);
}
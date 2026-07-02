import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/plan.dart';
import '../providers/app_providers.dart';
import '../providers/auth_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/plan_card.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  String? _selectedCode;
  bool _busy = false;

  Future<void> _checkout(Plan plan) async {
    final user = ref.read(userStateProvider).valueOrNull;
    if (user == null || user.userId.isEmpty) {
      context.push('/signin');
      return;
    }
    if (plan.isFree) return;
    setState(() => _busy = true);
    try {
      await ref.read(appwriteProvider).startMockSubscription(user.userId, plan.code);
      await ref.read(userStateProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome to ${plan.name}. (mock checkout — wire Stripe/RevenueCat to replace)')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Checkout didn't go through. Try again, or contact support."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(plansProvider);
    final user = ref.watch(userStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: const Text(''),
      ),
      body: plans.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No plans available.'));
          }
          // Free plan first, then pro options
          list.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
          final pro = list.where((p) => !p.isFree).toList();

          _selectedCode ??= pro.firstWhere((p) => p.highlight, orElse: () => pro.first).code;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text('Unlock RiseUP Pro', style: AppText.display(size: 36)),
              const SizedBox(height: 8),
              Text(
                user?.isPro ?? false
                    ? 'You\'re already Pro. Manage your subscription from your profile.'
                    : 'Full library · daily reminders · offline reading · favorites sync.',
                style: AppText.body(size: 14, color: AppColors.inkMute, height: 1.5),
              ),
              const SizedBox(height: 24),

              for (final p in pro) Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PlanCard(
                  plan: p,
                  selected: _selectedCode == p.code,
                  onTap: () => setState(() => _selectedCode = p.code),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _busy || (user?.isPro ?? false) ? null : () {
                    final selected = pro.firstWhere(
                      (p) => p.code == _selectedCode,
                      orElse: () => pro.first,
                    );
                    _checkout(selected);
                  },
                  child: _busy
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.paper, strokeWidth: 2))
                      : Text(
                          user?.isPro ?? false
                              ? 'You\'re Pro'
                              : 'Continue with ${pro.firstWhere((p) => p.code == _selectedCode).name}',
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Mock checkout for now. Real payments via Stripe (web) and RevenueCat (iOS/Android) plug in here.',
                  textAlign: TextAlign.center,
                  style: AppText.body(size: 11, color: AppColors.inkMute),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _busy ? null : () {
                    final free = list.firstWhere((p) => p.isFree, orElse: () => list.first);
                    _checkout(free);  // no-op for free
                    context.pop();
                  },
                  child: const Text('Continue with Free'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

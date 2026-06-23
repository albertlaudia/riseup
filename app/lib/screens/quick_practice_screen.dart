import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/prompt.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class QuickPracticeScreen extends ConsumerStatefulWidget {
  const QuickPracticeScreen({super.key});

  @override
  ConsumerState<QuickPracticeScreen> createState() => _QuickPracticeScreenState();
}

class _QuickPracticeScreenState extends ConsumerState<QuickPracticeScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final practices = ref.watch(quickPracticesProvider);
    final user = ref.watch(userStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: const Text('Quick practice'),
      ),
      body: practices.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No quick practices yet.'));
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('60-second scroll', style: AppText.label(size: 10, color: AppColors.inkMute)),
                    Text('${_index + 1} / ${list.length}', style: AppText.body(size: 12, color: AppColors.inkMute)),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final p = list[i];
                    final locked = p.isPro && (user?.isPro ?? false) == false;
                    return _PracticeCard(
                      practice: p,
                      locked: locked,
                      onLockedTap: () => context.push('/paywall'),
                    );
                  },
                ),
              ),
              _Dots(count: list.length, index: _index),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_index < list.length - 1) {
                        _controller.nextPage(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOut);
                      } else {
                        context.go('/');
                      }
                    },
                    child: Text(_index < list.length - 1 ? 'Next practice' : 'Done — open today'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({required this.practice, required this.locked, required this.onLockedTap});
  final QuickPractice practice;
  final bool locked;
  final VoidCallback onLockedTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.paperCard,
          border: Border.all(color: AppColors.ink.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (practice.theme != null) ...[
                    Text(practice.theme!.toUpperCase(), style: AppText.label(size: 10, color: AppColors.accent)),
                    const SizedBox(height: 8),
                  ],
                  Text(practice.hook, style: AppText.display(size: 22, height: 1.2)),
                  const SizedBox(height: 16),
                  Text(practice.body, style: AppText.body(size: 15, color: AppColors.inkSoft, height: 1.65)),
                  if (practice.action != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.paperWarm,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TRY THIS', style: AppText.label(size: 10, color: AppColors.accent)),
                          const SizedBox(height: 6),
                          Text(practice.action!, style: AppText.body(size: 14, color: AppColors.ink, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (locked)
              Positioned.fill(
                child: GestureDetector(
                  onTap: onLockedTap,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.paper.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_outline, color: AppColors.inkMute, size: 32),
                          const SizedBox(height: 8),
                          Text('Pro practice', style: AppText.display(size: 18)),
                          const SizedBox(height: 4),
                          Text('Tap to unlock', style: AppText.body(size: 13, color: AppColors.inkMute)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.accent : AppColors.ink.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

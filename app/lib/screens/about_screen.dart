import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
        children: [
          Text('Why RiseUP exists', style: AppText.display(size: 32)),
          const SizedBox(height: 16),
          Text(
            'RiseUP is a daily Stoic practice app. A short lesson in the morning. A quote to carry through the day. A streak that doesn\'t care about your mood.',
            style: AppText.body(size: 16, color: AppColors.inkSoft, height: 1.7),
          ),
          const SizedBox(height: 16),
          Text(
            'It\'s built on a simple premise: most of what we call motivation is really just attention. Pay attention, on purpose, to the right things, for thirty seconds a day, and the rest of the day behaves differently.',
            style: AppText.body(size: 16, color: AppColors.inkSoft, height: 1.7),
          ),
          const SizedBox(height: 24),
          Text('How it\'s built', style: AppText.display(size: 22)),
          const SizedBox(height: 8),
          _bullet('PocketBase', 'Static content: lessons, quotes, authors, themes, plans.'),
          _bullet('Appwrite', 'User data: auth, progress, favorites, subscriptions, settings.'),
          _bullet('Flutter', 'One codebase, every device. iOS, Android, web, desktop.'),
          const SizedBox(height: 24),
          Text('Subscription', style: AppText.display(size: 22)),
          const SizedBox(height: 8),
          Text(
            'The free tier is generous on purpose. Pro adds the deeper lessons, daily reminders, favorites sync, and offline reading — the things that turn a daily visit into a daily practice.',
            style: AppText.body(size: 14, color: AppColors.inkSoft, height: 1.6),
          ),
          const SizedBox(height: 24),
          Text('The rest', style: AppText.display(size: 22)),
          const SizedBox(height: 8),
          Text(
            '“Waste no more time arguing what a good man should be. Be one.” — Marcus Aurelius',
            style: AppText.display(size: 18, color: AppColors.ink, height: 1.4).copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: 6, color: AppColors.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppText.body(size: 14, color: AppColors.inkSoft, height: 1.5),
                children: [
                  TextSpan(text: title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink)),
                  TextSpan(text: ' — $body'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

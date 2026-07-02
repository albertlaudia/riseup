import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  PackageInfo? _info;
  String get _version => _info == null ? '…' : 'v${_info!.version} (${_info!.buildNumber})';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final i = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _info = i);
    } catch (_) {/* fine */}
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t open $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
        children: [
          // Brand mark
          Center(
            child: Column(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text('R', style: AppText.display(size: 40, color: AppColors.paper)),
                ),
                const SizedBox(height: 12),
                Text(AppConstants.appName, style: AppText.display(size: 28)),
                Text(_version, style: AppText.body(size: 12, color: AppColors.inkMute)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Text('Why RiseUP exists', style: AppText.display(size: 24)),
          const SizedBox(height: 12),
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
            '"Waste no more time arguing what a good man should be. Be one." — Marcus Aurelius',
            style: AppText.body(size: 18, color: AppColors.ink, height: 1.4).copyWith(fontStyle: FontStyle.italic),
          ),

          const SizedBox(height: 32),
          // Legal
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                _link('Privacy Policy', AppConstants.privacyUrl),
                _link('Terms of Service', AppConstants.termsUrl),
                _link('Support', 'mailto:${AppConstants.supportEmail}'),
                _link('Acknowledgements', 'https://riseup.app/acknowledgements'),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              '© ${DateTime.now().year} RiseUP',
              style: AppText.body(size: 11, color: AppColors.inkMute),
            ),
          ),
        ],
      ),
    );
  }

  Widget _link(String label, String url) {
    return InkWell(
      onTap: () => _open(url),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: AppText.body(size: 12, color: AppColors.inkSoft)
              .copyWith(decoration: TextDecoration.underline),
        ),
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../providers/auth_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Bottom sheet shown after a lesson is marked complete — "What will you try today?"
/// Saves the response to Appwrite `user_journal` (max 280 chars).
class ReflectionSheet extends ConsumerStatefulWidget {
  const ReflectionSheet({super.key, required this.lessonSlug, required this.promptText});
  final String lessonSlug;
  final String promptText;

  @override
  ConsumerState<ReflectionSheet> createState() => _ReflectionSheetState();
}

class _ReflectionSheetState extends ConsumerState<ReflectionSheet> {
  final _ctrl = TextEditingController();
  bool _saving = false;
  bool _saved = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = ref.read(userStateProvider).valueOrNull;
    if (user == null || user.userId.isEmpty) {
      // Not signed in — just close. The lesson was already saved on its own.
      if (mounted) Navigator.of(context).pop();
      return;
    }
    setState(() => _saving = true);
    try {
      final aw = ref.read(appwriteProvider);
      await aw._db.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: 'user_journal',
        documentId: ID.unique(),
        data: {
          'userId': user.userId,
          'lessonSlug': widget.lessonSlug,
          'promptText': widget.promptText,
          'responseText': _ctrl.text,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        },
        permissions: [
          Permission.read(Role.user(user.userId)),
          Permission.write(Role.user(user.userId)),
          Permission.delete(Role.user(user.userId)),
        ],
      );
      if (mounted) {
        setState(() => _saved = true);
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Couldn't save that. Tap to try again."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: const BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('REFLECTION', style: AppText.label(size: 10, color: AppColors.accent)),
            const SizedBox(height: 6),
            Text(widget.promptText, style: AppText.display(size: 22, height: 1.3)),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              autofocus: true,
              maxLines: 4,
              maxLength: 280,
              enabled: !_saving && !_saved,
              decoration: InputDecoration(
                hintText: 'A sentence, a fragment, whatever came up…',
                hintStyle: AppText.body(size: 14, color: AppColors.inkMute),
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
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: _saving || _saved ? null : () => Navigator.of(context).pop(),
                  child: const Text('Skip'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _saving || _saved ? null : _save,
                  child: _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: AppColors.paper, strokeWidth: 2))
                      : Text(_saved ? 'Saved ✓' : 'Save'),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

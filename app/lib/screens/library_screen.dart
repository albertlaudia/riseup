import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/content.dart';
import '../models/lesson.dart';
import '../providers/app_providers.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/empty_state.dart';
import '../widgets/lesson_card.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String? _themeSlug;
  String? _authorSlug;
  String? _difficulty;

  @override
  Widget build(BuildContext context) {
    final lessons = ref.watch(allLessonsProvider);
    final categories = ref.watch(categoriesProvider);
    final authors = ref.watch(authorsProvider);
    final lookup = ref.watch(lookupMapsProvider);
    final user = ref.watch(userStateProvider).valueOrNull;

    return Scaffold(
      body: lessons.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (all) {
          final cats = categories.valueOrNull ?? const <Category>[];
          final auths = authors.valueOrNull ?? const <Author>[];

          final selectedCategory = _themeSlug == null
              ? null
              : cats.where((c) => c.slug == _themeSlug).cast<Category?>().firstWhere(
                    (c) => c != null, orElse: () => null);
          final selectedAuthor = _authorSlug == null
              ? null
              : auths.where((a) => a.slug == _authorSlug).cast<Author?>().firstWhere(
                    (a) => a != null, orElse: () => null);

          final query = ref.watch(searchQueryProvider).trim().toLowerCase();
          var visible = all.where((l) {
            if (selectedCategory != null && l.themeId != selectedCategory.id) return false;
            if (selectedAuthor   != null && l.authorId != selectedAuthor.id)   return false;
            if (_difficulty != null && l.difficulty?.name != _difficulty)     return false;
            if (query.isNotEmpty) {
              final hay = '${l.title} ${l.intro ?? ''} ${l.content}'.toLowerCase();
              if (!hay.contains(query)) return false;
            }
            return true;
          }).toList();

          final byLevel = <LessonDifficulty, List<Lesson>>{
            for (final d in LessonDifficulty.values) d: [],
          };
          for (final l in visible) {
            if (l.difficulty != null) byLevel[l.difficulty!]!.add(l);
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allLessonsProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
              children: [
                Text('The library', style: AppText.display(size: 36)),
                const SizedBox(height: 6),
                Text(
                  _summaryLine(visible.length, selectedCategory, selectedAuthor, _difficulty),
                  style: AppText.body(size: 14, color: AppColors.inkMute),
                ),
                const SizedBox(height: 16),
                _SearchField(
                  onChanged: (q) =>
                      ref.read(searchQueryProvider.notifier).set(q),
                  onClear: () =>
                      ref.read(searchQueryProvider.notifier).clear(),
                ),
                const SizedBox(height: 16),

                _filterRow(
                  label: 'Theme',
                  child: Wrap(
                    spacing: 6, runSpacing: 6,
                    children: [
                      _chip(label: 'All', selected: _themeSlug == null,
                          onTap: () => setState(() => _themeSlug = null)),
                      ...cats.map((c) => _chip(
                            label: '${c.icon ?? '✦'} ${c.name}',
                            selected: _themeSlug == c.slug,
                            color: AppColors.forTheme(c.slug),
                            onTap: () => setState(() => _themeSlug = c.slug),
                          )),
                    ],
                  ),
                ),
                _filterRow(
                  label: 'Author',
                  child: Wrap(
                    spacing: 6, runSpacing: 6,
                    children: [
                      _chip(label: 'All', selected: _authorSlug == null,
                          onTap: () => setState(() => _authorSlug = null)),
                      ...auths.map((a) => _chip(
                            label: a.name,
                            selected: _authorSlug == a.slug,
                            onTap: () => setState(() => _authorSlug = a.slug),
                          )),
                    ],
                  ),
                ),
                _filterRow(
                  label: 'Difficulty',
                  child: Wrap(
                    spacing: 6, runSpacing: 6,
                    children: [
                      _chip(label: 'All', selected: _difficulty == null,
                          onTap: () => setState(() => _difficulty = null)),
                      for (final d in LessonDifficulty.values)
                        _chip(label: d.label, selected: _difficulty == d.name,
                            onTap: () => setState(() => _difficulty = d.name)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                if (visible.isEmpty)
                  EmptyState(
                    icon: query.isNotEmpty ? '🔍' : '🌫️',
                    title: query.isNotEmpty ? 'Nothing matches' : 'No lessons in this view',
                    body: query.isNotEmpty
                        ? 'Try a different word, or clear filters.'
                        : 'Try a different filter.',
                    ctaLabel: query.isNotEmpty ? 'Clear search' : null,
                    onCta: query.isNotEmpty
                        ? () => ref.read(searchQueryProvider.notifier).clear()
                        : null,
                  ),

                for (final entry in byLevel.entries)
                  if (entry.value.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Text(
                        '${entry.key.label}  ·  ${entry.value.length}',
                        style: AppText.display(size: 20),
                      ),
                    ),
                    ...entry.value.map((l) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: lookup.when(
                            loading: () => const SizedBox(height: 100),
                            error: (e, _) => Text('$e'),
                            data: (maps) => LessonCard(
                              lesson: l,
                              author: l.authorId == null ? null : maps.authors[l.authorId!],
                              theme:  l.themeId  == null ? null : maps.categories[l.themeId!],
                              variant: LessonCardVariant.compact,
                              locked: l.isPro && (user?.isPro ?? false) == false,
                              onTap: () => context.push('/library/${l.slug}'),
                            ),
                          ),
                        )),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _summaryLine(int n, Category? cat, Author? author, String? diff) {
    final parts = <String>['$n ${n == 1 ? "lesson" : "lessons"}'];
    if (cat != null) parts.add('in ${cat.name}');
    if (author != null) parts.add('by ${author.name}');
    if (diff != null) parts.add('· $diff');
    return parts.join(' ');
  }

  Widget _filterRow({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppText.label(size: 10, color: AppColors.inkMute)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.paperWarm,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppText.body(
            size: 12,
            color: selected ? AppColors.paper : (color ?? AppColors.inkSoft),
          ).copyWith(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  const _SearchField({required this.onChanged, required this.onClear});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _ctrl = TextEditingController();
  bool _focused = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.walrus,
          borderRadius: BorderRadius.circular(12),
          border: _focused
              ? Border.all(color: AppColors.accent.withValues(alpha: 0.5), width: 1.5)
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.search, size: 18, color: AppColors.inkMute),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _ctrl,
                onChanged: widget.onChanged,
                style: AppText.body(size: 14),
                decoration: const InputDecoration(
                  hintText: 'Search lessons…',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_ctrl.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _ctrl.clear();
                  widget.onClear();
                },
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 16, color: AppColors.inkMute),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

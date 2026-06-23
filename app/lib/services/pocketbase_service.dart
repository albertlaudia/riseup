import 'package:pocketbase/pocketbase.dart';
import '../models/achievement.dart';
import '../models/content.dart';
import '../models/lesson.dart';
import '../models/plan.dart';
import '../models/prompt.dart';
import '../models/quote.dart';

/// Read-only client for the static content in PocketBase.
class PocketBaseService {
  PocketBaseService._(this._pb);

  final PocketBase _pb;

  /// Build a service pointed at the live PocketBase instance.
  /// Override the URL at build time:
  ///   flutter build apk --dart-define=PB_URL=https://your-pb.example
  static PocketBaseService build({String? url}) {
    final pb = PocketBase(url ?? const String.fromEnvironment('PB_URL',
        defaultValue: 'https://pocketbase.scaleupcrm.com'));
    return PocketBaseService._(pb);
  }

  PocketBase get rawClient => _pb;

  // ---------- authors ----------
  Future<List<Author>> getAuthors() async {
    final r = await _pb.collection('rup_authors').getList(perPage: 200, sort: 'order,name');
    return r.items.map(Author.fromRecord).toList();
  }

  // ---------- categories ----------
  Future<List<Category>> getCategories() async {
    final r = await _pb.collection('rup_categories').getList(perPage: 200, sort: 'order,name');
    return r.items.map(Category.fromRecord).toList();
  }

  // ---------- works ----------
  Future<List<Work>> getWorks() async {
    final r = await _pb.collection('rup_works').getList(perPage: 200, sort: 'year,title');
    return r.items.map(Work.fromRecord).toList();
  }

  // ---------- lessons ----------
  Future<List<Lesson>> getLessons({String? themeSlug, String? authorSlug, String? difficulty}) async {
    final filters = <String>[];
    if (themeSlug != null) {
      // Resolve theme id from slug
      final cats = await getCategories();
      final cat = cats.firstWhere(
        (c) => c.slug == themeSlug,
        orElse: () => const Category(id: '', name: '', slug: ''),
      );
      if (cat.id.isNotEmpty) filters.add('theme="${cat.id}"');
    }
    if (authorSlug != null) {
      final authors = await getAuthors();
      final a = authors.firstWhere(
        (au) => au.slug == authorSlug,
        orElse: () => const Author(id: '', name: '', slug: ''),
      );
      if (a.id.isNotEmpty) filters.add('author="${a.id}"');
    }
    if (difficulty != null && difficulty != 'all') {
      filters.add('difficulty="$difficulty"');
    }
    final filter = filters.isEmpty ? null : filters.join(' && ');
    final r = await _pb.collection('rup_lessons').getList(
          perPage: 200,
          sort: 'order,title',
          filter: filter,
        );
    return r.items.map(Lesson.fromRecord).toList();
  }

  Future<Lesson?> getLessonBySlug(String slug) async {
    try {
      final r = await _pb.collection('rup_lessons').getFirstListItem('slug="$slug"');
      return Lesson.fromRecord(r.toJson());
    } on ClientException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<List<Lesson>> getFeaturedLessons() async {
    final r = await _pb.collection('rup_lessons')
        .getList(perPage: 200, filter: 'is_featured=true', sort: 'order');
    return r.items.map(Lesson.fromRecord).toList();
  }

  // ---------- quotes ----------
  Future<List<Quote>> getQuotes({String? themeSlug, String? authorSlug, bool featuredOnly = false}) async {
    final filters = <String>[];
    if (featuredOnly) filters.add('is_featured=true');
    if (themeSlug != null) {
      final cats = await getCategories();
      final cat = cats.firstWhere(
        (c) => c.slug == themeSlug,
        orElse: () => const Category(id: '', name: '', slug: ''),
      );
      if (cat.id.isNotEmpty) filters.add('theme="${cat.id}"');
    }
    if (authorSlug != null) {
      final authors = await getAuthors();
      final a = authors.firstWhere(
        (au) => au.slug == authorSlug,
        orElse: () => const Author(id: '', name: '', slug: ''),
      );
      if (a.id.isNotEmpty) filters.add('author="${a.id}"');
    }
    final filter = filters.isEmpty ? null : filters.join(' && ');
    final r = await _pb.collection('rup_quotes').getList(
          perPage: 500,
          sort: '-is_featured,text',
          filter: filter,
        );
    return r.items.map(Quote.fromRecord).toList();
  }

  // ---------- achievements ----------
  Future<List<Achievement>> getAchievements() async {
    final r = await _pb.collection('rup_achievements').getList(perPage: 200, sort: 'order');
    return r.items.map(Achievement.fromRecord).toList();
  }

  // ---------- plans ----------
  Future<List<Plan>> getPlans() async {
    final r = await _pb.collection('rup_plans').getList(
          perPage: 50,
          filter: 'active=true',
          sort: 'order',
        );
    return r.items.map(Plan.fromRecord).toList();
  }

  // ---------- reflection prompts ----------
  Future<ReflectionPrompt?> getPromptForLesson(String lessonId) async {
    try {
      final r = await _pb.collection('rup_prompts').getFirstListItem('lesson="$lessonId"');
      return ReflectionPrompt.fromRecord(r.toJson());
    } on ClientException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  // ---------- quick practices ----------
  Future<List<QuickPractice>> getQuickPractices() async {
    final r = await _pb.collection('rup_quick_practices').getList(
          perPage: 50,
          sort: 'order',
        );
    return r.items.map(QuickPractice.fromRecord).toList();
  }

  // ---------- onboarding ----------
  Future<List<OnboardingCard>> getOnboarding() async {
    final r = await _pb.collection('rup_onboarding').getList(
          perPage: 10,
          sort: 'order',
        );
    return r.items.map(OnboardingCard.fromRecord).toList();
  }
}

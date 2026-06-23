import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../models/content.dart';
import '../models/lesson.dart';
import '../models/plan.dart';
import '../models/quote.dart';
import '../services/pocketbase_service.dart';
import '../services/appwrite_service.dart';

/// ---------- service providers (singletons) ----------
final pocketBaseProvider = Provider<PocketBaseService>((ref) {
  return PocketBaseService.build();
});

final appwriteProvider = Provider<AppwriteService>((ref) {
  return AppwriteService.build();
});

// ---------- static content providers ----------
final authorsProvider = FutureProvider<List<Author>>((ref) async {
  return ref.read(pocketBaseProvider).getAuthors();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return ref.read(pocketBaseProvider).getCategories();
});

final allLessonsProvider = FutureProvider<List<Lesson>>((ref) async {
  return ref.read(pocketBaseProvider).getLessons();
});

final featuredLessonsProvider = FutureProvider<List<Lesson>>((ref) async {
  return ref.read(pocketBaseProvider).getFeaturedLessons();
});

final allQuotesProvider = FutureProvider<List<Quote>>((ref) async {
  return ref.read(pocketBaseProvider).getQuotes();
});

final featuredQuotesProvider = FutureProvider<List<Quote>>((ref) async {
  return ref.read(pocketBaseProvider).getQuotes(featuredOnly: true);
});

final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  return ref.read(pocketBaseProvider).getAchievements();
});

final plansProvider = FutureProvider<List<Plan>>((ref) async {
  return ref.read(pocketBaseProvider).getPlans();
});

// ---------- single lesson lookup ----------
final lessonBySlugProvider = FutureProvider.family<Lesson?, String>((ref, slug) async {
  return ref.read(pocketBaseProvider).getLessonBySlug(slug);
});

// ---------- lookup maps (for resolving relations) ----------
class LookupMaps {
  final Map<String, Author> authors;
  final Map<String, Category> categories;
  const LookupMaps({required this.authors, required this.categories});
}

final lookupMapsProvider = FutureProvider<LookupMaps>((ref) async {
  final authors = await ref.watch(authorsProvider.future);
  final categories = await ref.watch(categoriesProvider.future);
  return LookupMaps(
    authors: {for (final a in authors) a.id: a},
    categories: {for (final c in categories) c.id: c},
  );
});

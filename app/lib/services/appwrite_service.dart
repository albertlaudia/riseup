import 'package:appwrite/appwrite.dart';
import '../models/user_state.dart';

/// All user-data operations live here. PB is for static content only.
class AppwriteService {
  AppwriteService._(this._client, this._db, this._account);

  final Client _client;
  final Databases _db;
  final Account _account;

  static const String databaseId = String.fromEnvironment(
    'APPWRITE_DATABASE_ID',
    defaultValue: 'riseup',
  );

  // Collection ids — match appwrite-setup.mjs
  static const String colProgress      = 'user_progress';
  static const String colAchievements  = 'user_achievements';
  static const String colFavorites     = 'user_favorites';
  static const String colSubscriptions = 'user_subscriptions';
  static const String colSettings      = 'user_settings';

  static AppwriteService build({String? endpoint, String? projectId}) {
    final c = Client()
      ..setEndpoint(endpoint ?? const String.fromEnvironment('APPWRITE_ENDPOINT',
          defaultValue: 'https://cloud.appwrite.io/v1'))
      ..setProject(projectId ?? const String.fromEnvironment('APPWRITE_PROJECT_ID'));
    return AppwriteService._(c, Databases(c), Account(c));
  }

  Client get rawClient => _client;
  Account get account => _account;

  // ---------- auth ----------
  Future<dynamic> signInEmail(String email, String password) async {
    return _account.createEmailPasswordSession(email: email, password: password);
  }

  Future<dynamic> signUpEmail(String email, String password, {String? name}) async {
    return _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
  }

  Future<void> signOut() async {
    try { await _account.deleteSession(sessionId: 'current'); } catch (_) {}
  }

  Future<dynamic> currentUser() async {
    try { return await _account.get(); } catch (_) { return null; }
  }

  // ---------- progress ----------
  Future<bool> hasCompleted(String userId, String lessonSlug) async {
    final r = await _db.listDocuments(
      databaseId: databaseId,
      collectionId: colProgress,
      queries: [
        Query.equal('userId', userId),
        Query.equal('lessonSlug', lessonSlug),
        Query.limit(1),
      ],
    );
    return r.total > 0;
  }

  Future<void> markLessonComplete(String userId, String lessonSlug, {int xpEarned = 10}) async {
    if (await hasCompleted(userId, lessonSlug)) return;
    await _db.createDocument(
      databaseId: databaseId,
      collectionId: colProgress,
      documentId: ID.unique(),
      data: {
        'userId': userId,
        'lessonSlug': lessonSlug,
        'xpEarned': xpEarned,
        'completedAt': DateTime.now().toUtc().toIso8601String(),
      },
      permissions: [
        Permission.read(Role.user(userId)),
        Permission.write(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ],
    );
  }

  Future<int> totalLessons(String userId) async {
    final r = await _db.listDocuments(
      databaseId: databaseId,
      collectionId: colProgress,
      queries: [Query.equal('userId', userId), Query.limit(1)],
    );
    return r.total;
  }

  // ---------- favorites ----------
  Future<List<({String id, String kind, String targetId})>> getFavorites(String userId) async {
    final r = await _db.listDocuments(
      databaseId: databaseId,
      collectionId: colFavorites,
      queries: [Query.equal('userId', userId), Query.orderDesc('createdAt')],
    );
    return r.documents.map((d) {
      final data = d.data;
      return (
        id: d.$id,
        kind: data['kind'] as String? ?? '',
        targetId: data['targetId'] as String? ?? '',
      );
    }).toList();
  }

  Future<bool> isFavorited(String userId, String kind, String targetId) async {
    final r = await _db.listDocuments(
      databaseId: databaseId,
      collectionId: colFavorites,
      queries: [
        Query.equal('userId', userId),
        Query.equal('kind', kind),
        Query.equal('targetId', targetId),
        Query.limit(1),
      ],
    );
    return r.total > 0;
  }

  Future<void> addFavorite(String userId, String kind, String targetId) async {
    if (await isFavorited(userId, kind, targetId)) return;
    await _db.createDocument(
      databaseId: databaseId,
      collectionId: colFavorites,
      documentId: ID.unique(),
      data: {
        'userId': userId,
        'kind': kind,
        'targetId': targetId,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      },
      permissions: [
        Permission.read(Role.user(userId)),
        Permission.write(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ],
    );
  }

  Future<void> removeFavorite(String userId, String kind, String targetId) async {
    final r = await _db.listDocuments(
      databaseId: databaseId,
      collectionId: colFavorites,
      queries: [
        Query.equal('userId', userId),
        Query.equal('kind', kind),
        Query.equal('targetId', targetId),
        Query.limit(1),
      ],
    );
    for (final d in r.documents) {
      await _db.deleteDocument(databaseId: databaseId, collectionId: colFavorites, documentId: d.$id);
    }
  }

  // ---------- subscriptions ----------
  /// Returns the active subscription for this user, or null.
  Future<({String planCode, DateTime? expiresAt})?> activeSubscription(String userId) async {
    final r = await _db.listDocuments(
      databaseId: databaseId,
      collectionId: colSubscriptions,
      queries: [
        Query.equal('userId', userId),
        Query.equal('status', 'active'),
        Query.orderDesc('startedAt'),
        Query.limit(1),
      ],
    );
    if (r.documents.isEmpty) return null;
    final d = r.documents.first.data;
    final code = d['planCode'] as String? ?? '';
    final expStr = d['expiresAt'] as String?;
    final exp = expStr == null ? null : DateTime.tryParse(expStr);
    if (code.isEmpty) return null;
    // Treat lifetime (no expiry) as always active. Otherwise require future expiry.
    if (exp != null && exp.isBefore(DateTime.now().toUtc())) return null;
    return (planCode: code, expiresAt: exp);
  }

  /// Mock checkout — creates a subscription row. Real money goes through
  /// Stripe / RevenueCat later; this is the seam where the webhook
  /// server would call createDocument.
  Future<void> startMockSubscription(String userId, String planCode, {String source = 'admin'}) async {
    final now = DateTime.now().toUtc();
    DateTime? expiresAt;
    switch (planCode) {
      case 'pro_monthly':  expiresAt = now.add(const Duration(days: 30)); break;
      case 'pro_yearly':   expiresAt = now.add(const Duration(days: 365)); break;
      case 'pro_lifetime': expiresAt = null; break;
    }
    await _db.createDocument(
      databaseId: databaseId,
      collectionId: colSubscriptions,
      documentId: ID.unique(),
      data: {
        'userId': userId,
        'planCode': planCode,
        'status': 'active',
        'source': source,
        'startedAt': now.toIso8601String(),
        if (expiresAt != null) 'expiresAt': expiresAt.toIso8601String(),
      },
      permissions: [
        Permission.read(Role.user(userId)),
        Permission.write(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ],
    );
  }

  Future<void> cancelSubscription(String userId) async {
    final r = await _db.listDocuments(
      databaseId: databaseId,
      collectionId: colSubscriptions,
      queries: [
        Query.equal('userId', userId),
        Query.equal('status', 'active'),
      ],
    );
    for (final d in r.documents) {
      await _db.updateDocument(
        databaseId: databaseId,
        collectionId: colSubscriptions,
        documentId: d.$id,
        data: {
          'status': 'cancelled',
          'cancelledAt': DateTime.now().toUtc().toIso8601String(),
        },
      );
    }
  }

  // ---------- settings ----------
  Future<Map<String, dynamic>> getSettings(String userId) async {
    final r = await _db.listDocuments(
      databaseId: databaseId,
      collectionId: colSettings,
      queries: [Query.equal('userId', userId), Query.limit(1)],
    );
    if (r.documents.isEmpty) return <String, dynamic>{};
    return r.documents.first.data;
  }

  Future<void> saveSettings(String userId, Map<String, dynamic> patch) async {
    final current = await getSettings(userId);
    if (current.isEmpty) {
      await _db.createDocument(
        databaseId: databaseId,
        collectionId: colSettings,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          ...patch,
        },
        permissions: [
          Permission.read(Role.user(userId)),
          Permission.write(Role.user(userId)),
          Permission.delete(Role.user(userId)),
        ],
      );
    } else {
      // Find the doc id by re-querying (current is a data map, not the doc).
      final r = await _db.listDocuments(
        databaseId: databaseId,
        collectionId: colSettings,
        queries: [Query.equal('userId', userId), Query.limit(1)],
      );
      if (r.documents.isNotEmpty) {
        await _db.updateDocument(
          databaseId: databaseId,
          collectionId: colSettings,
          documentId: r.documents.first.$id,
          data: patch,
        );
      }
    }
  }

  // ---------- journal (reflection entries) ----------
  static const String colJournal = 'user_journal';

  Future<void> saveJournalEntry({
    required String userId,
    required String lessonSlug,
    required String promptText,
    required String responseText,
  }) async {
    await _db.createDocument(
      databaseId: databaseId,
      collectionId: colJournal,
      documentId: ID.unique(),
      data: {
        'userId': userId,
        'lessonSlug': lessonSlug,
        'promptText': promptText,
        'responseText': responseText,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      },
      permissions: [
        Permission.read(Role.user(userId)),
        Permission.write(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ],
    );
  }

  Future<List<({String lessonSlug, String promptText, String responseText, DateTime createdAt})>>
      getJournalEntries(String userId, {int limit = 14}) async {
    final r = await _db.listDocuments(
      databaseId: databaseId,
      collectionId: colJournal,
      queries: [
        Query.equal('userId', userId),
        Query.orderDesc('createdAt'),
        Query.limit(limit),
      ],
    );
    return r.documents.map((d) {
      final data = d.data;
      return (
        lessonSlug: data['lessonSlug'] as String? ?? '',
        promptText: data['promptText'] as String? ?? '',
        responseText: data['responseText'] as String? ?? '',
        createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
    }).toList();
  }
}

/// Helper extension: a User's email + id + name.
extension AppwriteUserExt on User {
  String get emailSafe => email;
  String get nameSafe => name.isEmpty ? email.split('@').first : name;
}

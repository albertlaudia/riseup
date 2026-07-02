# RiseUP — Content Caching + Audio + Smart Downloads

> Spec for offline reading, audio lessons, and Netflix-style smart download.
> Implementation is a 2-3 sprint effort. This doc is the contract.

Last reviewed: 2026-07-02

---

## TL;DR

| Feature | Status | Sprint |
|---------|--------|--------|
| Content cache (lessons / quotes / authors / etc) — stale-while-revalidate | ⬜ | Sprint 1 |
| Audio lesson playback (TTS, streamed from CDN) | ⬜ | Sprint 2 |
| Per-lesson / per-quote audio download | ⬜ | Sprint 2 |
| Smart download rules (auto-download next, auto-delete watched) | ⬜ | Sprint 2 |
| Network-aware download (Wi-Fi only, cellular allowed) | ⬜ | Sprint 2 |
| Storage management UI | ⬜ | Sprint 2 |
| Background pre-fetch (when charging + Wi-Fi) | ⬜ | Sprint 3 |

---

## 1. Content Cache

### Why cache

The user opens RiseUP at 7am on the train. No signal. They want today's lesson.

Today: blank screen. Tomorrow: today's lesson, today's quote, yesterday's journal, all there.

### What to cache

| Collection | Always cache | Size | Refresh |
|------------|--------------|------|---------|
| `rup_lessons` | All (≤15 today, grows) | ~50 KB each | On open |
| `rup_quotes` | All | ~2 KB each | Daily |
| `rup_authors` | All | ~5 KB each | Weekly |
| `rup_works` | All | ~3 KB each | Weekly |
| `rup_categories` | All | ~1 KB each | Weekly |
| `rup_achievements` | All | ~3 KB each | Weekly |
| `rup_plans` | All | ~2 KB each | Weekly |
| `rup_prompts` | All | ~3 KB each | Weekly |
| `rup_quick_practices` | All | ~5 KB each | Weekly |
| `rup_onboarding_cards` | All | ~5 KB each | On version change |

### User-data (Appwrite — also cache locally)

| Collection | Cache policy |
|------------|--------------|
| `user_progress` | Always mirror (offline-first writes) |
| `user_favorites` | Always mirror |
| `user_journal` | Always mirror |
| `user_achievements` | Always mirror |
| `user_settings` | Always mirror |
| `user_subscriptions` | Cache but server-authoritative on entitlement |

### Storage technology

**drift** (sqlite on device) — recommended because:
- Already used in Warisan Nusantara / 1perc / HEAL
- Strong typing, migrations
- Vector search via `sqlite-vec` if we add semantic search later

Schema sketch:

```dart
class LessonsTable extends Table {
  TextColumn get slug => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get authorSlug => text()();
  TextColumn get category => text()();
  TextColumn get difficulty => text()();
  IntColumn  get xpReward => integer()();
  TextColumn get cachedAt => text()();
  TextColumn get pbUpdated => text().nullable()();
  @override Set<Column> get primaryKey => {slug};
}
```

### Read-through pattern

```dart
class ContentRepository {
  Future<Lesson?> getLesson(String slug, {bool forceRefresh = false}) async {
    final local = await _db.lessons.bySlug(slug).getSingleOrNull();
    final stale = local == null || DateTime.now().difference(local.cachedAt) > const Duration(hours: 24);

    if (local != null && !stale && !forceRefresh) {
      // Fire background refresh; return local immediately
      _refresh(slug);
      return local.toLesson();
    }

    // Network — fall back to cache if offline
    try {
      final fresh = await _pb.getLesson(slug);
      await _db.lessons.insertOnConflictUpdate(fresh.toRow());
      return fresh;
    } catch (e) {
      if (local != null) return local.toLesson(); // stale-while-offline
      rethrow;
    }
  }
}
```

### Cache invalidation

Each PB collection has an `updated_at` field (we'll add it). On app start:

1. `GET /collections/rup_lessons/updated-since?since={lastSync}` — only fetch what changed.
2. If the manifest version stamp changes, invalidate everything for that collection.

### Sync queue for offline writes

User marks a lesson complete while offline:

1. Write to `drift.user_progress` with `synced_at = null`.
2. Show as "Saved" in UI (local source of truth).
3. On reconnect, push to Appwrite. On conflict, server wins but show a banner if delta is significant.

This is the same pattern as HEAL / 1perc / Warisan Nusantara.

---

## 2. Audio Lessons

### Why audio

Some users read. Some users listen. A 5-minute walk to the train is a perfect audio slot.

Audio also helps:
- Retention (the same lesson in audio form is 2x more memorable)
- Accessibility (visually impaired users)
- Differentiation (no Stoic app does audio well today)

### Pipeline

```
┌─────────────┐    ┌──────────────┐    ┌───────────────┐    ┌─────────────┐
│ rup_lessons │ →  │ TTS provider │ →  │ CDN bucket    │ →  │ Flutter     │
│ (text body) │    │ (MiniMax TTS)│    │ (per-lesson   │    │ just_audio  │
│             │    │              │    │  .mp3)        │    │             │
└─────────────┘    └──────────────┘    └───────────────┘    └─────────────┘
```

### TTS provider

**MiniMax TTS** (already integrated in this agent's tooling) — gives us:
- 12+ voices (warm, deep, female, male)
- Streaming or full-file output
- ~$15 per 1M characters; a 1500-char lesson = $0.02; 1000 lessons = $20

**Self-hostable later:** Coqui TTS / Piper TTS on the server. Defer.

### Storage model

Each lesson gets **two audio files**:

| Variant | Use case | Size | Cost |
|---------|----------|------|------|
| `lo` (32 kbps) | Smart-download / cellular | ~600 KB per 5-min lesson | $0.005 |
| `hi` (128 kbps) | Wi-Fi / premium | ~2.4 MB per 5-min lesson | $0.005 |

Total per lesson: ~3 MB. 100 lessons = 300 MB. Fine for a "download everything" mode, but we don't.

### CDN

Cloudflare R2 (`$0.015 / GB / month`) — same provider as the Cloudflare Worker.
URL pattern: `https://audio.riseup.app/{lessonSlug}/{variant}.mp3`

### URLs in PB

Add to `rup_lessons`:
- `audioUrlLo` (text, optional)
- `audioUrlHi` (text, optional)
- `audioDurationSec` (integer)

Pre-generation cron (server-side, runs once per lesson):
1. Take `rup_lessons.body` (stripped markdown)
2. Call MiniMax TTS
3. Upload to R2
4. Patch PB with `audioUrlLo` / `audioUrlHi` / `audioDurationSec`

For v1, **all lessons are pre-generated at seed time**. No on-demand generation.

### Playback

Use `just_audio` package:
```dart
final player = AudioPlayer();
await player.setAudioSource(AudioSource.uri(Uri.parse(lesson.audioUrlHi)));
await player.play();
```

Background audio:
- iOS: `audio_session` package + `UIBackgroundModes: audio` in Info.plist
- Android: foreground service with notification

Lock-screen / control-center art:
- Lesson card image as the artwork
- Title = lesson title, artist = "RiseUP"

### Per-quote audio

Each quote also gets a short audio (~30 sec). Same pipeline, different duration.

---

## 3. Smart Downloads (Netflix pattern)

### Why smart downloads

User has 3 GB free on phone. We could pre-load everything. We shouldn't:
- Wastes their data
- Wastes their battery
- Wastes our CDN bandwidth

Netflix's rule: keep the next N unwatched + delete the last M watched. Same idea here.

### Rules (default)

| Setting | Default | Configurable |
|---------|---------|--------------|
| Smart download on/off | ON | yes |
| Max downloads | 5 lessons + 10 quotes | yes |
| Audio quality | High | yes |
| Download over | Wi-Fi only | yes |
| Cellular allowed | OFF | yes |
| Auto-delete after completed | 3 days | yes |
| Storage cap | 500 MB | yes |

### UI: Settings → Downloads

```
┌─ DOWNLOADS ─────────────────────────────┐
│ Smart downloads                    [●━○] │
│ ┌────────────────────────────────────┐  │
│ │ Auto-downloads the next few lessons│  │
│ │ and quotes. Removes ones you've    │  │
│ │ finished.                           │  │
│ └────────────────────────────────────┘  │
│                                          │
│ Network                                  │
│ ○ Wi-Fi only (recommended)               │
│ ○ Wi-Fi + cellular                       │
│                                          │
│ Quality                                  │
│ ● High (~2.4 MB / lesson)                │
│ ○ Low  (~0.6 MB / lesson)                │
│                                          │
│ Auto-delete                              │
│ ● After 1 day                            │
│ ○ After 3 days                           │
│ ○ After 1 week                           │
│ ○ Never                                  │
│                                          │
│ Storage                                  │
│ Using 47 MB of 500 MB · 5 lessons, 12 q  │
│ [Manage storage →]                       │
└──────────────────────────────────────────┘
```

### UI: Downloads tab in Library

```
┌─ DOWNLOADS ─────────────────────────────┐
│ 5 lessons · 12 quotes · 47 MB            │
│ [⏸ Pause smart downloads]                │
│                                          │
│ Today                                    │
│ 🎧 The Obstacle Is the Way · 6:42   [▶] │
│ 🎧 Memento Mori · 4:30            [▶] │
│                                          │
│ Up next (auto-downloaded)                │
│ 🎧 Amor Fati · 5:12                [×] │
│ 🎧 The Dichotomy of Control · 7:08  [×] │
│                                          │
│ Quotes                                   │
│ 🎧 "Waste no more time..." — Marcus [▶] │
│ 🎧 "You have power over your mind..." [▶] │
└──────────────────────────────────────────┘
```

### Implementation

```dart
class SmartDownloadManager {
  Future<void> reconcile() async {
    final settings = await _settings.read();
    if (!settings.smartDownloadEnabled) return;
    if (!await _network.allowsDownload(settings)) return;

    final listened = await _progress.listenedLessons();
    final downloaded = await _downloads.all();
    final todayAndNext = await _nextN(settings.maxLessons);

    // 1. Delete completed older than retention
    final deleteBefore = DateTime.now().subtract(settings.retention);
    for (final d in downloaded.where((d) => d.completedAt?.isBefore(deleteBefore) ?? false)) {
      await _storage.delete(d.localPath);
    }

    // 2. Download what's next but not yet downloaded
    final needed = todayAndNext.where((s) => !downloaded.any((d) => d.slug == s));
    for (final slug in needed) {
      if (await _storage.usedBytes() + _estimatedSize(slug) > settings.maxBytes) break;
      await _download(slug, settings.quality);
    }

    // 3. Trim oldest non-listened if over cap
    // (so the next-3-most-recent are always available)
  }
}
```

### Triggers

Reconcile runs:
- On app start
- After lesson marked complete
- When a download finishes
- Every 6 hours while app is in background (via `workmanager`)
- On connectivity change

### Background work

Use `workmanager` package:

```dart
Workmanager().registerOneOffTask(
  'smart-download-reconcile',
  'reconcile',
  initialDelay: const Duration(minutes: 1),
  constraints: Constraints(networkType: NetworkType.unmetered, requiresCharging: false),
);
```

### Network detection

```dart
class NetworkGate {
  Future<bool> allowsDownload(DownloadSettings s) async {
    final connectivity = await Connectivity().checkConnectivity();
    final wifi = connectivity == ConnectivityResult.wifi;
    if (s.wifiOnly && !wifi) return false;
    return true;
  }
}
```

---

## 4. Storage management UI

Library → Settings → Manage storage:

```
┌─ STORAGE ────────────────────────────────┐
│ ┌──────────────────────────────────────┐ │
│ │ ████████████░░░░░░░ 47 MB / 500 MB   │ │
│ │                                      │ │
│ │ Lessons    5 files  · 32 MB          │ │
│ │ Quotes    12 files  · 11 MB          │ │
│ │ Journal   17 files  ·  4 MB          │ │
│ └──────────────────────────────────────┘ │
│                                          │
│ [Delete all downloads]                    │
└──────────────────────────────────────────┘
```

---

## 5. Edge cases

| Case | Handling |
|------|----------|
| Disk full mid-download | Catch error, log, do not retry automatically |
| User changes quality | Re-download affected (delete then re-fetch) |
| Lesson updated by PB | Re-download |
| Subscription lapses (Pro → Free) | Keep Pro audio for 7 days, then downgrade (delete `hi`, keep `lo`) |
| App reinstalled | User data restored via Appwrite, downloads gone (re-download on first open) |
| Roaming | Treat as cellular → blocked if `wifiOnly` |

---

## 6. Privacy

- Audio downloaded to **app-private storage** — not user-visible in Files app.
- Smart downloads never run unless user opted in.
- Network usage counted toward user's data plan (we surface this in Settings).
- We don't share download telemetry — only aggregate counts.

---

## 7. Cost projection (Year 1)

100k users, 30% enable smart downloads:

| Item | Cost |
|------|------|
| TTS pre-generation (200 lessons × 2 variants) | $10 one-time |
| CDN bandwidth (R2 egress) | ~$50/mo |
| Storage (R2 storage, 30% × 100k × 50MB) | ~$75/mo |
| TTS for new lessons (10/month) | $1/mo |
| **Total** | **~$130/mo** |

Trivially absorbed.

---

## 8. Sequencing

### Sprint 1 — content cache + audio playback
- drift setup + migrations
- ContentRepository (stale-while-revalidate)
- Audio playback from CDN (no downloads yet)
- Pre-generate audio for all 15 lessons, upload to R2
- Add audio buttons to lesson detail + quote card

### Sprint 2 — downloads
- Per-lesson download button
- Downloads tab in Library
- Settings → Downloads screen
- Smart download reconcile loop

### Sprint 3 — background polish
- workmanager background tasks
- Storage management UI
- Cellular permission flow
- Network-aware UI banners

---

## 9. Acceptance criteria

A user should be able to:
1. Open the app on a flight with no signal — see today's lesson, today's quote, their last journal entry.
2. Download 3 lessons, close the app, kill the network, listen on the plane.
3. Mark a downloaded lesson complete — see it removed from storage within the retention window.
4. See the next auto-downloaded lesson on the Downloads tab without doing anything.
5. Toggle "Wi-Fi only" — see smart downloads pause when on cellular.
6. Use Settings → Storage to see exactly what's downloaded and delete manually.
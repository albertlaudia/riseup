package com.albertlaudia.riseup

import io.flutter.embedding.android.FlutterActivity

/// Single-activity host for the Flutter app. The MainActivity is referenced
/// by AndroidManifest.xml — keep the package + class name stable or update
/// the manifest in lockstep.
///
/// For deep-link routing (e.g. `riseup://library/{slug}`), FlutterActivity
/// already reads `flutter_deeplinking_enabled` from the manifest and routes
/// accordingly. No additional platform code needed.
class MainActivity : FlutterActivity()
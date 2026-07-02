# ProGuard / R8 rules for release builds.
# Strip unused code from the APK; preserve classes Flutter / plugin code
# reflects on.

# Keep our main class
-keep class com.albertlaudia.riseup.MainActivity { *; }

# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Appwrite SDK (uses reflection)
-keep class io.appwrite.** { *; }
-dontwarn io.appwrite.**

# Keep PocketBase SDK
-keep class com.alexanderschilli.pocketbase.** { *; }
-dontwarn com.alexanderschilli.pocketbase.**

# flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Keep generic Kotlin metadata
-keep class kotlin.Metadata { *; }

# Allow R8 optimization but don't strip the line numbers for crash reports.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
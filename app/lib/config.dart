/// Build-time configuration. Override with:
///   flutter run --dart-define=APPWRITE_ENDPOINT=https://...
///                 --dart-define=APPWRITE_PROJECT_ID=...
///                 --dart-define=PB_URL=https://...
class AppConfig {
  AppConfig._();

  /// PocketBase URL — static content only.
  static const String pbUrl = String.fromEnvironment(
    'PB_URL',
    defaultValue: 'https://pocketbase.scaleupcrm.com',
  );

  /// Appwrite endpoint — user data.
  static const String appwriteEndpoint = String.fromEnvironment(
    'APPWRITE_ENDPOINT',
    defaultValue: 'https://cloud.appwrite.io/v1',
  );

  /// Appwrite project ID.
  static const String appwriteProjectId = String.fromEnvironment(
    'APPWRITE_PROJECT_ID',
    defaultValue: 'YOUR_APPWRITE_PROJECT_ID',
  );

  /// Appwrite database id (created by `appwrite-setup.mjs`).
  static const String appwriteDatabaseId = String.fromEnvironment(
    'APPWRITE_DATABASE_ID',
    defaultValue: 'riseup',
  );

  /// Web app URL — used by the in-app "open in browser" links and TWA fallback.
  static const String webAppUrl = String.fromEnvironment(
    'WEB_APP_URL',
    defaultValue: 'https://xyc4pio8o5le.space.minimax.io',
  );
}

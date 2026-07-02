import Flutter
import UIKit

/// Entry point for the iOS Runner. The Flutter engine handles the actual
/// UI; we just bootstrap here.
///
/// To add a deep-link or notification handler at the native level, you
/// can do it before or after `super.application(...)`:
///   - For local notifications: flutter_local_notifications package handles
///     tap → payload routing automatically.
///   - For FCM: firebase_messaging's AppDelegate methods are added by the
///     plugin via swizzling.
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
/// Haptic feedback wrapper. Centralized so we tune the "feel" of the app in
/// one place. Stoic apps should not buzz for no reason — use sparingly.
library;

import 'package:flutter/services.dart';

class Haptic {
  Haptic._();

  /// Lightest touch — toggle switches, segmented controls, tap-and-release.
  static void light() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
  }

  /// Selection click — swipe, scroll snapping, picker wheels.
  static void selection() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
  }

  /// Medium — completing a lesson, saving settings, favorite toggle.
  static void medium() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Heavy — achievement unlock, payment success.
  static void heavy() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Notification-style tap. Different pattern than a button.
  static void notify(String type) {
    if (!_enabled) return;
    switch (type) {
      case 'success':
      case 'error':
        HapticFeedback.vibrate();
        break;
      case 'warning':
        HapticFeedback.mediumImpact();
        break;
      default:
        HapticFeedback.selectionClick();
    }
  }

  // Master toggle — disabled in tests, or if user opts out via Settings.
  static bool _enabled = true;
  static void setEnabled(bool v) => _enabled = v;
}
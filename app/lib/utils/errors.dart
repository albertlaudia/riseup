/// Map raw Appwrite / network errors to friendly, Stoic-toned user copy.
///
/// Usage:
///   catch (e) {
///     setState(() => _error = formatAuthError(e));
///   }
///
/// Keeps screens from showing HTTP status codes to the user.
library;

import 'package:appwrite/appwrite.dart' as appwrite;

String formatAuthError(Object error) {
  if (error is appwrite.AppwriteException) {
    switch (error.type) {
      case 'user_invalid_credentials':
      case 'user_unauthorized':
        return 'That email and password don\'t match an account. Try again, or tap "Forgot password?" below.';
      case 'user_already_exists':
        return 'An account with that email already exists. Sign in instead.';
      case 'user_email_already_exists':
        return 'That email is taken. Try signing in instead.';
      case 'user_not_found':
        return 'No account with that email. Create one instead?';
      case 'password_recently_used':
        return 'Pick a password you haven\'t used here before.';
      case 'password_too_short':
      case 'user_password_recently_used':
        return 'Passwords need at least 8 characters. Try a phrase you\'ll remember.';
      case 'email_invalid':
        return 'That doesn\'t look like an email. Check the spelling.';
      case 'general_rate_limit':
      case 'user_blocked':
        return 'Too many tries. Take a breath and try again in a minute.';
      case 'user_session_already_exists':
        return 'You\'re already signed in on another device. Sign out there first, or continue here.';
      case 'user_invalid_code':
        return 'That code didn\'t match. Try again, or request a new one.';
      case 'user_code_expired':
        return 'That code has expired. Request a new one.';
      case 'network':
      case 'fetch_failure':
        return 'No connection. Check Wi-Fi or mobile data, then retry.';
      case 'service_disabled':
        return 'Sign-in is temporarily unavailable. Please try again shortly.';
      default:
        return 'Something went sideways on our end. We\'re looking into it.';
    }
  }
  // Generic / non-Appwrite errors
  final msg = error.toString();
  if (msg.contains('SocketException') || msg.contains('Connection refused')) {
    return 'No connection. Check Wi-Fi or mobile data, then retry.';
  }
  if (msg.contains('TimeoutException')) {
    return 'The network is slow. Try again in a moment.';
  }
  return 'Something went sideways. We\'re looking into it.';
}

String formatNetworkError(Object error) {
  final msg = error.toString();
  if (msg.contains('SocketException')) {
    return 'No connection. Showing your last cached content.';
  }
  if (msg.contains('TimeoutException')) {
    return 'That took too long. Tap to try again.';
  }
  return 'Something went sideways. Tap to try again.';
}

/// Convert an int 0-4 strength into a label + color hint.
class PasswordStrength {
  final int score; // 0-4
  final String label;
  const PasswordStrength._(this.score, this.label);

  static const empty = PasswordStrength._(0, '');
  static const weak = PasswordStrength._(1, 'Weak');
  static const ok = PasswordStrength._(2, 'OK');
  static const good = PasswordStrength._(3, 'Good');
  static const strong = PasswordStrength._(4, 'Strong');

  bool get isAcceptable => score >= 2;
}

/// Quick strength check — length + mix of character classes.
PasswordStrength passwordStrength(String value) {
  if (value.isEmpty) return PasswordStrength.empty;
  var score = 0;
  if (value.length >= 8) score++;
  if (value.length >= 12) score++;
  if (RegExp(r'[A-Z]').hasMatch(value) && RegExp(r'[a-z]').hasMatch(value)) score++;
  if (RegExp(r'\d').hasMatch(value)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;
  // Cap at 4
  score = score.clamp(1, 4);
  switch (score) {
    case 1: return PasswordStrength.weak;
    case 2: return PasswordStrength.ok;
    case 3: return PasswordStrength.good;
    case 4: return PasswordStrength.strong;
    default: return PasswordStrength.empty;
  }
}
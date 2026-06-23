import 'dart:convert';

/// Subscription plan definitions from PB.
/// `features` is a list of feature codes unlocked by this plan.
class Plan {
  final String id;
  final String code;
  final String name;
  final String? tagline;
  final String? description;
  final int priceCents;
  final String currency;
  final String interval;     // free | monthly | yearly | lifetime
  final List<String> features;
  final bool highlight;
  final int? order;
  final bool active;

  const Plan({
    required this.id,
    required this.code,
    required this.name,
    this.tagline,
    this.description,
    required this.priceCents,
    required this.currency,
    required this.interval,
    required this.features,
    this.highlight = false,
    this.order,
    this.active = true,
  });

  bool get isFree => interval == 'free' || priceCents == 0;

  /// Pretty price for the paywall.
  String get priceDisplay {
    if (priceCents == 0) return 'Free';
    final dollars = priceCents / 100;
    return dollars.truncateToDouble() == dollars
        ? '\$${dollars.toInt()}'
        : '\$${dollars.toStringAsFixed(2)}';
  }

  /// "$5.99 / month", "$49.99 / year", "Forever free"
  String get priceWithInterval {
    if (isFree) return 'Forever free';
    switch (interval) {
      case 'monthly':  return '$priceDisplay / month';
      case 'yearly':   return '$priceDisplay / year';
      case 'lifetime': return '$priceDisplay once';
      default:         return priceDisplay;
    }
  }

  factory Plan.fromRecord(Map<String, dynamic> r) {
    final raw = r['features'];
    final features = <String>[];
    if (raw is List) {
      features.addAll(raw.map((e) => e.toString()));
    } else if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) features.addAll(decoded.map((e) => e.toString()));
      } catch (_) {/* ignore */}
    }
    return Plan(
      id: r['id'] as String,
      code: r['code'] as String? ?? '',
      name: r['name'] as String? ?? '',
      tagline: r['tagline'] as String?,
      description: r['description'] as String?,
      priceCents: (r['price_cents'] as num?)?.toInt() ?? 0,
      currency: r['currency'] as String? ?? 'USD',
      interval: r['interval'] as String? ?? 'free',
      features: features,
      highlight: r['highlight'] == true,
      order: (r['order'] as num?)?.toInt(),
      active: r['active'] != false,
    );
  }
}

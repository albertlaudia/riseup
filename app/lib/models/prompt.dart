// Reflection prompt + quick practice + onboarding card — PB-side static data.

class ReflectionPrompt {
  final String id;
  final String lessonId;
  final String text;
  final int? order;

  const ReflectionPrompt({required this.id, required this.lessonId, required this.text, this.order});

  factory ReflectionPrompt.fromRecord(Map<String, dynamic> r) => ReflectionPrompt(
        id: r['id'] as String,
        lessonId: r['lesson'] as String? ?? '',
        text: r['text'] as String? ?? '',
        order: (r['order'] as num?)?.toInt(),
      );
}

class QuickPractice {
  final String id;
  final String slug;
  final String title;
  final String hook;
  final String body;
  final String? action;
  final String? theme;
  final int? order;
  final bool isPro;

  const QuickPractice({
    required this.id,
    required this.slug,
    required this.title,
    required this.hook,
    required this.body,
    this.action,
    this.theme,
    this.order,
    this.isPro = false,
  });

  factory QuickPractice.fromRecord(Map<String, dynamic> r) => QuickPractice(
        id: r['id'] as String,
        slug: r['slug'] as String? ?? '',
        title: r['title'] as String? ?? '',
        hook: r['hook'] as String? ?? '',
        body: r['body'] as String? ?? '',
        action: r['action'] as String?,
        theme: r['theme'] as String?,
        order: (r['order'] as num?)?.toInt(),
        isPro: r['is_pro'] == true,
      );
}

class OnboardingCard {
  final String id;
  final int order;
  final String title;
  final String body;
  final String? icon;
  final String? cta;

  const OnboardingCard({
    required this.id,
    required this.order,
    required this.title,
    required this.body,
    this.icon,
    this.cta,
  });

  factory OnboardingCard.fromRecord(Map<String, dynamic> r) => OnboardingCard(
        id: r['id'] as String,
        order: (r['order'] as num?)?.toInt() ?? 0,
        title: r['title'] as String? ?? '',
        body: r['body'] as String? ?? '',
        icon: r['icon'] as String?,
        cta: r['cta'] as String?,
      );
}

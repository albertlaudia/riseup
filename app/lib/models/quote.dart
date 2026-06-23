class Quote {
  final String id;
  final String text;
  final String? authorId;
  final String? workId;
  final String? themeId;
  final String? reflection;
  final bool isFeatured;
  final bool isPro;

  const Quote({
    required this.id,
    required this.text,
    this.authorId,
    this.workId,
    this.themeId,
    this.reflection,
    this.isFeatured = false,
    this.isPro = false,
  });

  factory Quote.fromRecord(Map<String, dynamic> r) => Quote(
        id: r['id'] as String,
        text: r['text'] as String? ?? '',
        authorId: r['author'] as String?,
        workId: r['work'] as String?,
        themeId: r['theme'] as String?,
        reflection: r['reflection'] as String?,
        isFeatured: r['is_featured'] == true,
        isPro: r['is_pro'] == true,
      );
}

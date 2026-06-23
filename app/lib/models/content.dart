// Author, Work, Category — the static content trio from PB.

class Author {
  final String id;
  final String name;
  final String slug;
  final String? era;
  final String? bio;
  final String? avatarUrl;
  final int? order;

  const Author({
    required this.id,
    required this.name,
    required this.slug,
    this.era,
    this.bio,
    this.avatarUrl,
    this.order,
  });

  factory Author.fromRecord(Map<String, dynamic> r) => Author(
        id: r['id'] as String,
        name: r['name'] as String? ?? '',
        slug: r['slug'] as String? ?? '',
        era: r['era'] as String?,
        bio: r['bio'] as String?,
        avatarUrl: r['avatar_url'] as String?,
        order: (r['order'] as num?)?.toInt(),
      );
}

class Work {
  final String id;
  final String authorId;
  final String title;
  final String slug;
  final String? description;
  final int? year;

  const Work({
    required this.id,
    required this.authorId,
    required this.title,
    required this.slug,
    this.description,
    this.year,
  });

  factory Work.fromRecord(Map<String, dynamic> r) => Work(
        id: r['id'] as String,
        authorId: r['author'] as String? ?? '',
        title: r['title'] as String? ?? '',
        slug: r['slug'] as String? ?? '',
        description: r['description'] as String?,
        year: (r['year'] as num?)?.toInt(),
      );
}

class Category {
  final String id;
  final String name;
  final String slug;
  final String? icon;
  final String? color;
  final String? description;
  final int? order;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.color,
    this.description,
    this.order,
  });

  factory Category.fromRecord(Map<String, dynamic> r) => Category(
        id: r['id'] as String,
        name: r['name'] as String? ?? '',
        slug: r['slug'] as String? ?? '',
        icon: r['icon'] as String?,
        color: r['color'] as String?,
        description: r['description'] as String?,
        order: (r['order'] as num?)?.toInt(),
      );
}

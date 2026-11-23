/// Pre-defined standard news categories and subcategories
/// matching Google News and MSN structures.
class NewsCategory {
  final String id;
  final String name;
  final String slug;
  final String icon;
  final String description;
  final List<String> subcategories;

  const NewsCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.description,
    this.subcategories = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'icon': icon,
        'description': description,
        'subcategories': subcategories,
      };

  factory NewsCategory.fromJson(Map<String, dynamic> json) => NewsCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        icon: json['icon'] as String,
        description: json['description'] as String,
        subcategories: (json['subcategories'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );

  // Pre-configured global categories
  static const NewsCategory top = NewsCategory(
    id: 'top',
    name: 'Top Stories',
    slug: 'top',
    icon: 'flame',
    description: 'Major developing headlines and global breaking news',
    subcategories: ['Breaking', 'Trending', 'Headlines'],
  );

  static const NewsCategory forYou = NewsCategory(
    id: 'for-you',
    name: 'For You',
    slug: 'for-you',
    icon: 'sparkles',
    description: 'Personalized news matching your interests and habits',
    subcategories: ['Recommended', 'Based on your history', 'Followed topics'],
  );

  static const NewsCategory local = NewsCategory(
    id: 'local',
    name: 'Local News',
    slug: 'local',
    icon: 'map-pin',
    description: 'Stories and events happening near your current location',
    subcategories: ['City', 'Regional', 'Local Government', 'Community'],
  );

  static const NewsCategory international = NewsCategory(
    id: 'international',
    name: 'World & International',
    slug: 'international',
    icon: 'globe',
    description: 'Global politics, diplomacy, treaties, and international events',
    subcategories: ['Americas', 'Europe', 'Asia-Pacific', 'Africa', 'Middle East'],
  );

  static const NewsCategory tech = NewsCategory(
    id: 'tech',
    name: 'Technology',
    slug: 'tech',
    icon: 'cpu',
    description: 'Artificial intelligence, gadgets, software, cybersecurity, and startups',
    subcategories: ['AI & Machine Learning', 'Mobile', 'Startups', 'Cybersecurity', 'Big Tech'],
  );

  static const NewsCategory business = NewsCategory(
    id: 'business',
    name: 'Business & Finance',
    slug: 'business',
    icon: 'trending-up',
    description: 'Stock markets, economy, crypto, real estate, and personal finance',
    subcategories: ['Markets', 'Crypto', 'Economy', 'Personal Finance', 'Real Estate'],
  );

  static const NewsCategory sports = NewsCategory(
    id: 'sports',
    name: 'Sports',
    slug: 'sports',
    icon: 'trophy',
    description: 'Live scores, football, basketball, motorsport, tennis, and highlights',
    subcategories: ['Football/Soccer', 'Basketball', 'Tennis', 'Motorsport', 'Combat Sports'],
  );

  static const NewsCategory entertainment = NewsCategory(
    id: 'entertainment',
    name: 'Entertainment',
    slug: 'entertainment',
    icon: 'film',
    description: 'Movies, music, celebrity news, television, and streaming',
    subcategories: ['Movies', 'Music', 'Celebrity', 'TV & Streaming', 'Pop Culture'],
  );

  static const NewsCategory gists = NewsCategory(
    id: 'gists',
    name: 'Gists & Viral',
    slug: 'gists',
    icon: 'message-circle',
    description: 'Trending gossip, social media buzz, viral stories, and memes',
    subcategories: ['Trending Gossip', 'Social Buzz', 'Viral Videos', 'Internet Culture'],
  );

  static const NewsCategory food = NewsCategory(
    id: 'food',
    name: 'Food & Dining',
    slug: 'food',
    icon: 'utensils',
    description: 'Recipes, culinary culture, restaurant reviews, and food trends',
    subcategories: ['Recipes', 'Restaurant Reviews', 'Culinary Trends', 'Drinks & Wine'],
  );

  static const NewsCategory lifestyle = NewsCategory(
    id: 'lifestyle',
    name: 'Lifestyle & Wellness',
    slug: 'lifestyle',
    icon: 'heart',
    description: 'Health, wellness, travel, fashion, relationships, and home living',
    subcategories: ['Health & Fitness', 'Travel', 'Fashion & Beauty', 'Relationships', 'Home & Living'],
  );

  static const NewsCategory science = NewsCategory(
    id: 'science',
    name: 'Science & Environment',
    slug: 'science',
    icon: 'atom',
    description: 'Space exploration, environment, climate, physics, and medical discoveries',
    subcategories: ['Space Exploration', 'Climate & Nature', 'Physics', 'Biotech & Health Science'],
  );

  static const List<NewsCategory> allCategories = [
    top,
    forYou,
    local,
    international,
    tech,
    business,
    sports,
    entertainment,
    gists,
    food,
    lifestyle,
    science,
  ];

  static NewsCategory? findBySlug(String slug) {
    for (final cat in allCategories) {
      if (cat.slug.toLowerCase() == slug.toLowerCase()) return cat;
    }
    return null;
  }
}

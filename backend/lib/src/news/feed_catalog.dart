import 'package:news_models/news_models.dart';

/// Pre-configured catalog of verified public RSS feeds categorized into sections
class FeedDefinition {
  final String id;
  final String name;
  final String url;
  final String category;
  final String country;
  final String language;
  final String domain;
  final String? iconUrl;

  const FeedDefinition({
    required this.id,
    required this.name,
    required this.url,
    required this.category,
    this.country = 'global',
    this.language = 'en',
    required this.domain,
    this.iconUrl,
  });

  NewsSource toSource() => NewsSource(
        id: id,
        name: name,
        slug: id,
        domain: domain,
        iconUrl: iconUrl ?? 'https://www.google.com/s2/favicons?domain=$domain&sz=128',
        country: country,
        language: language,
        reliabilityScore: 0.95,
        isVerified: true,
      );
}

class FeedCatalog {
  static const List<FeedDefinition> feeds = [
    // Top Stories / Breaking
    FeedDefinition(
      id: 'bbc-world',
      name: 'BBC News',
      url: 'https://feeds.bbci.co.uk/news/world/rss.xml',
      category: 'top',
      domain: 'bbc.co.uk',
    ),
    FeedDefinition(
      id: 'npr-news',
      name: 'NPR News',
      url: 'https://feeds.npr.org/1001/rss.xml',
      category: 'top',
      domain: 'npr.org',
    ),
    FeedDefinition(
      id: 'sky-news-world',
      name: 'Sky News',
      url: 'https://feeds.skynews.com/feeds/rss/world.xml',
      category: 'top',
      domain: 'news.sky.com',
    ),

    // Technology
    FeedDefinition(
      id: 'techcrunch',
      name: 'TechCrunch',
      url: 'https://techcrunch.com/feed/',
      category: 'tech',
      domain: 'techcrunch.com',
    ),
    FeedDefinition(
      id: 'the-verge',
      name: 'The Verge',
      url: 'https://www.theverge.com/rss/index.xml',
      category: 'tech',
      domain: 'theverge.com',
    ),
    FeedDefinition(
      id: 'ars-technica',
      name: 'Ars Technica',
      url: 'https://feeds.arstechnica.com/arstechnica/index',
      category: 'tech',
      domain: 'arstechnica.com',
    ),
    FeedDefinition(
      id: 'wired-tech',
      name: 'Wired',
      url: 'https://www.wired.com/feed/category/gear/latest/rss',
      category: 'tech',
      domain: 'wired.com',
    ),

    // Business & Finance
    FeedDefinition(
      id: 'cnbc-business',
      name: 'CNBC',
      url: 'https://search.cnbc.com/rs/search/view.html?partnerId=2000&keywords=business&sort=date',
      category: 'business',
      domain: 'cnbc.com',
    ),
    FeedDefinition(
      id: 'marketwatch',
      name: 'MarketWatch',
      url: 'https://feeds.content.dowjones.io/public/rss/mw_topstories',
      category: 'business',
      domain: 'marketwatch.com',
    ),

    // Sports
    FeedDefinition(
      id: 'bbc-sport',
      name: 'BBC Sport',
      url: 'https://feeds.bbci.co.uk/sport/rss.xml',
      category: 'sports',
      domain: 'bbc.com/sport',
    ),
    FeedDefinition(
      id: 'espn',
      name: 'ESPN',
      url: 'https://www.espn.com/espn/rss/news',
      category: 'sports',
      domain: 'espn.com',
    ),

    // Entertainment
    FeedDefinition(
      id: 'variety',
      name: 'Variety',
      url: 'https://variety.com/feed/',
      category: 'entertainment',
      domain: 'variety.com',
    ),
    FeedDefinition(
      id: 'billboard',
      name: 'Billboard',
      url: 'https://www.billboard.com/feed/',
      category: 'entertainment',
      domain: 'billboard.com',
    ),

    // Gists & Viral
    FeedDefinition(
      id: 'buzzfeed',
      name: 'BuzzFeed News',
      url: 'https://www.buzzfeed.com/world.xml',
      category: 'gists',
      domain: 'buzzfeed.com',
    ),

    // Food & Dining
    FeedDefinition(
      id: 'seriouseats',
      name: 'Serious Eats',
      url: 'https://www.seriouseats.com/feeds/all',
      category: 'food',
      domain: 'seriouseats.com',
    ),

    // Lifestyle
    FeedDefinition(
      id: 'lifehacker',
      name: 'Lifehacker',
      url: 'https://lifehacker.com/rss',
      category: 'lifestyle',
      domain: 'lifehacker.com',
    ),

    // Science & Nature
    FeedDefinition(
      id: 'nasa-breaking',
      name: 'NASA Breaking News',
      url: 'https://www.nasa.gov/news-release/feed/',
      category: 'science',
      domain: 'nasa.gov',
    ),
    FeedDefinition(
      id: 'sciencedaily',
      name: 'ScienceDaily',
      url: 'https://www.sciencedaily.com/rss/all.xml',
      category: 'science',
      domain: 'sciencedaily.com',
    ),

    // International
    FeedDefinition(
      id: 'al-jazeera',
      name: 'Al Jazeera',
      url: 'https://www.aljazeera.com/xml/rss/all.xml',
      category: 'international',
      domain: 'aljazeera.com',
    ),
    FeedDefinition(
      id: 'france24',
      name: 'France 24',
      url: 'https://www.france24.com/en/rss',
      category: 'international',
      domain: 'france24.com',
    ),
  ];

  static List<FeedDefinition> getFeedsByCategory(String category) {
    return feeds.where((f) => f.category.toLowerCase() == category.toLowerCase()).toList();
  }
}

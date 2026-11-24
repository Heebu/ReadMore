import 'package:news_models/news_models.dart';

class ArticleComment {
  final String id;
  final String author;
  final String avatarUrl;
  final String text;
  final String timeAgo;
  int likes;
  bool isLiked;

  ArticleComment({
    required this.id,
    required this.author,
    required this.avatarUrl,
    required this.text,
    required this.timeAgo,
    this.likes = 0,
    this.isLiked = false,
  });
}

class TimelineEvent {
  final String time;
  final String title;
  final String summary;
  final String sourceName;

  const TimelineEvent({
    required this.time,
    required this.title,
    required this.summary,
    required this.sourceName,
  });
}

class AppNotification {
  final String id;
  final String title;
  final String timeAgo;
  final bool isBreaking;
  final String articleId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.timeAgo,
    this.isBreaking = false,
    required this.articleId,
  });
}

class WebMockData {
  static final Map<String, NewsSource> sources = {
    'bbc': const NewsSource(
      id: 'bbc',
      name: 'BBC News',
      slug: 'bbc',
      domain: 'bbc.com',
      iconUrl: 'https://www.google.com/s2/favicons?domain=bbc.com&sz=128',
    ),
    'reuters': const NewsSource(
      id: 'reuters',
      name: 'Reuters',
      slug: 'reuters',
      domain: 'reuters.com',
      iconUrl: 'https://www.google.com/s2/favicons?domain=reuters.com&sz=128',
    ),
    'techcrunch': const NewsSource(
      id: 'techcrunch',
      name: 'TechCrunch',
      slug: 'techcrunch',
      domain: 'techcrunch.com',
      iconUrl: 'https://www.google.com/s2/favicons?domain=techcrunch.com&sz=128',
    ),
    'verge': const NewsSource(
      id: 'verge',
      name: 'The Verge',
      slug: 'verge',
      domain: 'theverge.com',
      iconUrl: 'https://www.google.com/s2/favicons?domain=theverge.com&sz=128',
    ),
    'bloomberg': const NewsSource(
      id: 'bloomberg',
      name: 'Bloomberg',
      slug: 'bloomberg',
      domain: 'bloomberg.com',
      iconUrl: 'https://www.google.com/s2/favicons?domain=bloomberg.com&sz=128',
    ),
    'espn': const NewsSource(
      id: 'espn',
      name: 'ESPN',
      slug: 'espn',
      domain: 'espn.com',
      iconUrl: 'https://www.google.com/s2/favicons?domain=espn.com&sz=128',
    ),
    'variety': const NewsSource(
      id: 'variety',
      name: 'Variety',
      slug: 'variety',
      domain: 'variety.com',
      iconUrl: 'https://www.google.com/s2/favicons?domain=variety.com&sz=128',
    ),
    'nature': const NewsSource(
      id: 'nature',
      name: 'Nature Journal',
      slug: 'nature',
      domain: 'nature.com',
      iconUrl: 'https://www.google.com/s2/favicons?domain=nature.com&sz=128',
    ),
    'seriouseats': const NewsSource(
      id: 'seriouseats',
      name: 'Serious Eats',
      slug: 'seriouseats',
      domain: 'seriouseats.com',
      iconUrl: 'https://www.google.com/s2/favicons?domain=seriouseats.com&sz=128',
    ),
    'vogue': const NewsSource(
      id: 'vogue',
      name: 'Vogue',
      slug: 'vogue',
      domain: 'vogue.com',
      iconUrl: 'https://www.google.com/s2/favicons?domain=vogue.com&sz=128',
    ),
  };

  static final List<Article> sampleArticles = [
    // Top Story / Spotlight Hero
    Article(
      id: 'art-hero-1',
      title: 'Global Climate Summit Reaches Landmark Accord on Renewable Grid Transition',
      slug: 'global-climate-summit-reaches-landmark-accord',
      summary: 'Delegates from 195 nations have ratified an unprecedented binding treaty mandating a 300% expansion in cross-border clean energy transmission lines by 2035.',
      content: 'Delegates from 195 nations reached an extraordinary breakthrough after 14 days of intense diplomatic negotiations. The treaty provides \$500 billion in annual public-private guarantees to rapidly deploy high-voltage direct current (HVDC) transmission lines connecting continental solar, wind, and storage hubs. Leading economic institutes project this agreement will create over 12 million clean-tech jobs while drastically cutting global fossil fuel reliance.',
      originalUrl: 'https://www.reuters.com/environment/summit-agreement-2026',
      imageUrl: 'https://images.unsplash.com/photo-1497435334941-8c899ee9e8e9?auto=format&fit=crop&w=1200&q=80',
      source: sources['reuters']!,
      category: 'top',
      subcategory: 'Global Accord',
      tags: ['Climate', 'Clean Energy', 'Diplomacy', 'Treaty'],
      publishedAt: DateTime.now().subtract(const Duration(minutes: 25)),
      readTimeMinutes: 4,
      isBreaking: true,
      viewCount: 14250,
      likeCount: 3890,
      clusterId: 'cluster-climate-summit',
    ),

    // Tech 1: Autonomous AI
    Article(
      id: 'art-tech-1',
      title: 'Next-Gen Autonomous AI Agents Shift Paradigms Across Enterprise Engineering',
      slug: 'next-gen-autonomous-ai-agents-shift-paradigms',
      summary: 'State-of-the-art multi-agent networks can now ingest design architectures, write verified code, execute test suites, and deploy infrastructure end-to-end.',
      content: 'Software development is experiencing its most seismic inflection point in four decades. Enterprise research labs have unveiled recursive agent swarms capable of inspecting legacy codebases, refactoring monolithic architectures into reactive microservices, and enforcing automated zero-trust security audits.',
      originalUrl: 'https://techcrunch.com/2026/11/ai-agents-paradigm-shift/',
      imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=1200&q=80',
      source: sources['techcrunch']!,
      category: 'tech',
      subcategory: 'Artificial Intelligence',
      tags: ['AI', 'Software Engineering', 'Autonomous Agents', 'Deep Learning'],
      publishedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
      readTimeMinutes: 3,
      viewCount: 22800,
      likeCount: 5410,
    ),

    // Tech 2: Quantum Computing
    Article(
      id: 'art-tech-2',
      title: 'Commercial Fault-Tolerant Quantum Processor Achieves Real-Time Error Correction',
      slug: 'commercial-fault-tolerant-quantum-processor',
      summary: 'Physicists demonstrate 10,000 logical qubits operating under active syndrome decoding, solving complex molecular simulation challenges in seconds.',
      content: 'The long-standing holy grail of quantum physics—fault-tolerant active error correction—has officially crossed into commercial viability. The breakthrough paves the way for catalyst discovery and next-generation battery chemistries previously impossible to model on classical supercomputers.',
      originalUrl: 'https://www.theverge.com/quantum/2026/fault-tolerant-quantum-milestone',
      imageUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=1200&q=80',
      source: sources['verge']!,
      category: 'tech',
      subcategory: 'Quantum Computing',
      tags: ['Quantum', 'Hardware', 'Physics', 'Deep Tech'],
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      readTimeMinutes: 5,
      viewCount: 9400,
      likeCount: 2100,
    ),

    // Business 1: Wall Street & Crypto
    Article(
      id: 'art-bus-1',
      title: 'Global Markets Rally as Tech Giants Post Record Capital Expenditure Returns',
      slug: 'global-markets-rally-tech-capex-returns',
      summary: 'Major indices surge to fresh all-time highs as enterprise monetization of automated digital infrastructure surges 65% year-over-year.',
      content: 'Wall Street and international equity markets experienced explosive upward momentum this morning. Financial analysts noted that capital expenditures into computing clusters and energy grids are now generating immediate margin expansions, defying previous recessionary fears.',
      originalUrl: 'https://www.bloomberg.com/markets/2026-rally-capex-surge',
      imageUrl: 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?auto=format&fit=crop&w=1200&q=80',
      source: sources['bloomberg']!,
      category: 'business',
      subcategory: 'Stock Markets',
      tags: ['Wall Street', 'Economy', 'Markets', 'Tech Stocks'],
      publishedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 40)),
      readTimeMinutes: 3,
      viewCount: 16700,
      likeCount: 3200,
    ),

    // Sports 1: Football / Soccer
    Article(
      id: 'art-sport-1',
      title: 'Champions League Thriller: Stoppage-Time Overhead Volley Caps Impossible Comeback',
      slug: 'champions-league-thriller-stoppage-time-volley',
      summary: 'Trailing by two goals on aggregate with five minutes remaining, underdog squad orchestrates an immortal Champions League miracle.',
      content: 'In what commentators are already labeling one of the greatest European football nights of the 21st century, a breathtaking 94th-minute bicycle kick completed a sensational second-half turnaround, securing a ticket to the prestigious semi-finals.',
      originalUrl: 'https://www.espn.com/soccer/story/ucl-miracle-volley',
      imageUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&w=1200&q=80',
      source: sources['espn']!,
      category: 'sports',
      subcategory: 'Football',
      tags: ['Champions League', 'Football', 'Highlights', 'Sports Drama'],
      publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
      readTimeMinutes: 2,
      viewCount: 31200,
      likeCount: 9800,
    ),

    // Entertainment: Cinema & Streaming
    Article(
      id: 'art-ent-1',
      title: 'Groundbreaking Sci-Fi Odyssey Smashes All-Time Global Box Office Benchmarks',
      slug: 'groundbreaking-sci-fi-odyssey-smashes-box-office',
      summary: 'Directed with visionary in-camera practical effects and next-gen immersive spatial audio, the epic crosses \$400M worldwide in its first 72 hours.',
      content: 'Audiences around the globe are flocking back to premier large-format theaters in historic numbers. Critics have widely praised the films seamless blend of tactile practical miniatures and cutting-edge holographic cinematography.',
      originalUrl: 'https://variety.com/film/box-office-phenomenon-2026',
      imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1200&q=80',
      source: sources['variety']!,
      category: 'entertainment',
      subcategory: 'Movies & Cinema',
      tags: ['Movies', 'Box Office', 'Hollywood', 'Sci-Fi'],
      publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
      readTimeMinutes: 3,
      viewCount: 18400,
      likeCount: 4200,
    ),

    // Science 1: Astronomy
    Article(
      id: 'art-sci-1',
      title: 'Deep Space Observatory Confirms Atmospheric Water Vapor on Nearby Super-Earth',
      slug: 'deep-space-observatory-confirms-atmospheric-water',
      summary: 'Spectroscopic analysis reveals clear signatures of atmospheric moisture and methane in the habitable zone of star system Gliese 486.',
      content: 'Astrophysicists analyzing infrared light curves from the orbital telescope array confirmed the presence of dynamic cloud formations and potential surface ocean reservoirs on an exoplanet located just 26 light years from Earth.',
      originalUrl: 'https://www.nature.com/articles/habitable-exoplanet-atmosphere-2026',
      imageUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1200&q=80',
      source: sources['nature']!,
      category: 'science',
      subcategory: 'Astronomy',
      tags: ['Space', 'Astronomy', 'Exoplanet', 'Discovery'],
      publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
      readTimeMinutes: 4,
      viewCount: 15300,
      likeCount: 6100,
    ),

    // Food & Dining
    Article(
      id: 'art-food-1',
      title: 'The Fermentation Renaissance: How Ancient Techniques are Reimagining Fine Dining',
      slug: 'fermentation-renaissance-reimagining-fine-dining',
      summary: 'Master chefs worldwide are embracing centuries-old koji, garum, and wild lacto-fermentation to unlock unprecedented umami depths.',
      content: 'In Michelin-starred kitchens from Tokyo to Copenhagen and San Francisco, the newest revolution isn’t molecular foam—it is centuries-old microbial wizardry. Chefs are creating custom fermentation chambers yielding intensely complex, savory culinary masterpieces.',
      originalUrl: 'https://www.seriouseats.com/fermentation-trends-2026',
      imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1200&q=80',
      source: sources['seriouseats']!,
      category: 'food',
      subcategory: 'Culinary Culture',
      tags: ['Food', 'Fine Dining', 'Fermentation', 'Recipes'],
      publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
      readTimeMinutes: 3,
      viewCount: 7800,
      likeCount: 1950,
    ),

    // Lifestyle & Wellness
    Article(
      id: 'art-life-1',
      title: 'Architectural Biophilia: Why Living Spaces Designed Around Circadian Light Transform Health',
      slug: 'architectural-biophilia-circadian-light',
      summary: 'New clinical studies demonstrate a 40% reduction in chronic stress markers for residents living in homes with dynamic spectral sunlighting.',
      content: 'Modern urban design is experiencing an overdue transformation toward biophilic living. By integrating living green walls, natural cross-ventilation corridors, and full-spectrum circadian glass, homes are evolving into restorative sanctuaries.',
      originalUrl: 'https://www.vogue.com/lifestyle/biophilic-home-design-2026',
      imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
      source: sources['vogue']!,
      category: 'lifestyle',
      subcategory: 'Wellness & Design',
      tags: ['Design', 'Wellness', 'Architecture', 'Health'],
      publishedAt: DateTime.now().subtract(const Duration(hours: 7)),
      readTimeMinutes: 3,
      viewCount: 11200,
      likeCount: 2900,
    ),

    // Gists & Viral
    Article(
      id: 'art-gist-1',
      title: 'Viral Wholesome Moment: City Chorus Unites Commuters in Spontaneous Subway Harmony',
      slug: 'city-chorus-unites-commuters-subway-harmony',
      summary: 'A 20-second acoustic performance during evening rush hour has captured over 85 million views across social platforms.',
      content: 'A spontaneous acapella arrangement echoing through a bustling train concourse brought thousands of hurried commuters to an enchanted standstill, reminding the internet of the shared magic in unexpected communal art.',
      originalUrl: 'https://readmore.news/gists/viral-subway-harmony',
      imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=1200&q=80',
      source: sources['bbc']!,
      category: 'gists',
      subcategory: 'Viral Culture',
      tags: ['Viral', 'Music', 'Trending', 'Community'],
      publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      readTimeMinutes: 2,
      viewCount: 45600,
      likeCount: 14200,
    ),

    // Local News: New York
    Article(
      id: 'art-local-ny',
      title: 'Metro High-Speed Transit Expansion Completes Phase 1 Six Months Ahead of Schedule',
      slug: 'metro-transit-expansion-phase-1-complete',
      summary: 'Zero-emission electric express lines now seamlessly connect the downtown cultural district with western suburban medical corridors.',
      content: 'City planners and local transit authorities celebrated the ribbon-cutting of the transformative express loop today. Featuring silent magnetic levitation tracks and universal contactless smart tap access, the line will reduce regional roadway congestion by 22%.',
      originalUrl: 'https://readmore.news/local/ny-transit-expansion',
      imageUrl: 'https://images.unsplash.com/photo-1517649763962-0c623266ddc0?auto=format&fit=crop&w=1200&q=80',
      source: sources['reuters']!,
      category: 'local',
      subcategory: 'City Infrastructure',
      city: 'New York',
      country: 'US',
      tags: ['New York', 'Transit', 'Urban Planning', 'Community'],
      publishedAt: DateTime.now().subtract(const Duration(hours: 9)),
      readTimeMinutes: 3,
      viewCount: 8900,
      likeCount: 2300,
    ),

    // Local News: London
    Article(
      id: 'art-local-london',
      title: 'Thames Clean Energy Corridor Initiates First Hydro-Turbine Array Beneath Tower Bridge',
      slug: 'thames-clean-energy-hydro-turbine-tower-bridge',
      summary: 'Sub-surface tidal power generators begin feeding clean electrical power directly into the historic London Underground network.',
      content: 'In a fusion of centuries-old maritime heritage and modern zero-emission technology, underwater turbines anchored deep in the tidal Thames now generate steady baseload electricity for hundreds of thousands of daily commuters.',
      originalUrl: 'https://readmore.news/local/london-thames-hydro',
      imageUrl: 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?auto=format&fit=crop&w=1200&q=80',
      source: sources['bbc']!,
      category: 'local',
      subcategory: 'Clean Energy',
      city: 'London',
      country: 'UK',
      tags: ['London', 'Clean Energy', 'Thames', 'Local Tech'],
      publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
      readTimeMinutes: 3,
      viewCount: 11400,
      likeCount: 3100,
    ),

    // Local News: Tokyo
    Article(
      id: 'art-local-tokyo',
      title: 'Tokyo Unveils Massive Multi-Level Vertical Forest District in Shibuya',
      slug: 'tokyo-vertical-forest-district-shibuya',
      summary: 'Towering biophilic towers incorporate over 250,000 indigenous trees, dropping local neighborhood summer temperatures by 4 degrees.',
      content: 'Shibuya’s newest skyline district blends hyper-dense urban living with lush mountainous biodiversity. Automated misting arrays and bird sanctuary sky-bridges provide an awe-inspiring template for future climate-resilient megacities.',
      originalUrl: 'https://readmore.news/local/tokyo-shibuya-forest',
      imageUrl: 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=1200&q=80',
      source: sources['reuters']!,
      category: 'local',
      subcategory: 'Urban Ecology',
      city: 'Tokyo',
      country: 'Japan',
      tags: ['Tokyo', 'Architecture', 'Urban Green', 'Japan'],
      publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
      readTimeMinutes: 4,
      viewCount: 14800,
      likeCount: 4200,
    ),

    // Local News: Lagos
    Article(
      id: 'art-local-lagos',
      title: 'Lagos Tech Ecosystem Celebrates Launch of Africa’s Largest Undersea Fiber Landing Hub',
      slug: 'lagos-undersea-fiber-landing-hub-launched',
      summary: 'New high-capacity subsea terminal in Lekki multiplies West African cloud bandwidth by 10x, accelerating regional fintech innovation.',
      content: 'Founders, cloud architects, and state officials gathered at the Lekki Free Trade Zone for the official commission of the next-generation trans-Atlantic fiber terminus, establishing Lagos as the premier digital infrastructure crossroads of the continent.',
      originalUrl: 'https://readmore.news/local/lagos-fiber-hub',
      imageUrl: 'https://images.unsplash.com/photo-1542296332-2e4473faf563?auto=format&fit=crop&w=1200&q=80',
      source: sources['techcrunch']!,
      category: 'local',
      subcategory: 'Tech Hub',
      city: 'Lagos',
      country: 'Nigeria',
      tags: ['Lagos', 'Nigeria', 'Fintech', 'Infrastructure'],
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      readTimeMinutes: 3,
      viewCount: 19500,
      likeCount: 5700,
    ),

    // Local News: Paris
    Article(
      id: 'art-local-paris',
      title: 'Seine Swimming Program Expands to Permanent Public Waterways Along Latin Quarter',
      slug: 'paris-seine-swimming-latin-quarter',
      summary: 'Following Olympic ecological restoration, the City of Light opens four historic riverside swimming basins for public recreation.',
      content: 'Generations of Parisians celebrated today as the clear waters of the Seine officially reopened for swimming, flanked by floating sun decks, botanical filtration gardens, and open-air riverside cafes.',
      originalUrl: 'https://readmore.news/local/paris-seine-basins',
      imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=1200&q=80',
      source: sources['vogue']!,
      category: 'local',
      subcategory: 'Culture & Environment',
      city: 'Paris',
      country: 'France',
      tags: ['Paris', 'Seine', 'Lifestyle', 'Ecology'],
      publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
      readTimeMinutes: 2,
      viewCount: 13200,
      likeCount: 3800,
    ),

    // Local News: San Francisco
    Article(
      id: 'art-local-sf',
      title: 'San Francisco Waterfront Greenway Connects Presidio with Mission Bay in 10-Mile Park',
      slug: 'sf-waterfront-greenway-presidio-mission-bay',
      summary: 'Continuous waterfront promenade features dedicated protected bicycle corridors, public art installations, and restored wetland habitats.',
      content: 'The completion of the Embarcadero green corridor unites the northern and southern edges of San Francisco into one unbroken recreation sanctuary, providing panoramic views of the Golden Gate and bay tides.',
      originalUrl: 'https://readmore.news/local/sf-waterfront-greenway',
      imageUrl: 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?auto=format&fit=crop&w=1200&q=80',
      source: sources['reuters']!,
      category: 'local',
      subcategory: 'Civic Parks',
      city: 'San Francisco',
      country: 'US',
      tags: ['San Francisco', 'Parks', 'Bicycle', 'Bay Area'],
      publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
      readTimeMinutes: 3,
      viewCount: 9600,
      likeCount: 2700,
    ),
  ];

  static final StoryCluster fullCoverageCluster = StoryCluster(
    id: 'cluster-climate-summit',
    topicHeadline: 'Global Climate Summit 2026: Historic Renewable Energy Treaty',
    category: 'top',
    primaryArticle: sampleArticles.first,
    alternativePerspectives: [
      Article(
        id: 'persp-bbc-1',
        title: 'European Leaders Commit \$120B in Sovereign Guarantees for HVDC Supergrid',
        slug: 'european-leaders-commit-120b-supergrid',
        summary: 'Brussels leads the diplomatic charge to establish interconnected offshore wind corridors linking the North Sea and Mediterranean.',
        originalUrl: 'https://www.bbc.com/news/europe-climate-commitments',
        imageUrl: 'https://images.unsplash.com/photo-1466611653911-95081537e5b7?auto=format&fit=crop&w=800&q=80',
        source: sources['bbc']!,
        category: 'top',
        publishedAt: DateTime.now().subtract(const Duration(minutes: 40)),
        readTimeMinutes: 3,
      ),
      Article(
        id: 'persp-bloomberg-1',
        title: 'Energy Commodities React: Clean Tech Equities Rally 8% in Pre-Market Trading',
        slug: 'energy-commodities-clean-tech-rally',
        summary: 'Institutional investors shift billions into grid equipment manufacturers and lithium-iron-phosphate battery producers.',
        originalUrl: 'https://www.bloomberg.com/news/articles/clean-energy-equities-rally',
        imageUrl: 'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?auto=format&fit=crop&w=800&q=80',
        source: sources['bloomberg']!,
        category: 'business',
        publishedAt: DateTime.now().subtract(const Duration(minutes: 55)),
        readTimeMinutes: 4,
      ),
      Article(
        id: 'persp-techcrunch-1',
        title: 'How AI Grid Orchestration Systems are Optimizing Cross-Border Load Balancing',
        slug: 'ai-grid-orchestration-cross-border-load',
        summary: 'Next-gen distributed smart grid software models predict regional demand spikes and dynamically reroute gigawatts in milliseconds.',
        originalUrl: 'https://techcrunch.com/2026/11/ai-smart-grid-orchestration/',
        imageUrl: 'https://images.unsplash.com/photo-1509391365360-2e959784a276?auto=format&fit=crop&w=800&q=80',
        source: sources['techcrunch']!,
        category: 'tech',
        publishedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
        readTimeMinutes: 3,
      ),
    ],
    updatedAt: DateTime.now(),
  );

  static const List<TimelineEvent> clusterTimeline = [
    TimelineEvent(
      time: '08:30 AM',
      title: 'Plenary Session Opens with Draft Supergrid Protocol',
      summary: 'Chief negotiators present the consolidated text reconciling disputes on cross-border transmission tariff structures.',
      sourceName: 'Reuters',
    ),
    TimelineEvent(
      time: '11:15 AM',
      title: 'European Union and Alliance Nations Pledge \$120B Initial Tranche',
      summary: 'Ministerial announcement secures matching guarantees from sovereign wealth funds in Norway, UK, and Germany.',
      sourceName: 'BBC News',
    ),
    TimelineEvent(
      time: '02:45 PM',
      title: 'Tech & Grid Consortium Unveils Real-Time Interconnect Standards',
      summary: 'Global energy software coalition publishes universal protocols for automated DC grid frequency balancing.',
      sourceName: 'TechCrunch',
    ),
    TimelineEvent(
      time: '05:00 PM',
      title: 'Unanimous 195-Nation Ratification Achieved',
      summary: 'Final treaty text accepted by standing ovation at the international convention center.',
      sourceName: 'Bloomberg',
    ),
  ];

  static WeatherSnapshot get currentWeather => cityWeatherMap['New York']!;

  static final Map<String, WeatherSnapshot> cityWeatherMap = {
    'New York': const WeatherSnapshot(
      city: 'New York',
      country: 'US',
      temperatureC: 22.0,
      condition: 'Partly Cloudy',
      iconCode: 'partly-cloudy-day',
      humidity: 56,
      windSpeedKmh: 14.5,
    ),
    'London': const WeatherSnapshot(
      city: 'London',
      country: 'UK',
      temperatureC: 17.5,
      condition: 'Light Showers',
      iconCode: 'rainy',
      humidity: 78,
      windSpeedKmh: 18.2,
    ),
    'Tokyo': const WeatherSnapshot(
      city: 'Tokyo',
      country: 'Japan',
      temperatureC: 21.0,
      condition: 'Clear & Sunny',
      iconCode: 'sunny',
      humidity: 48,
      windSpeedKmh: 10.0,
    ),
    'Lagos': const WeatherSnapshot(
      city: 'Lagos',
      country: 'Nigeria',
      temperatureC: 31.0,
      condition: 'Tropical Warmth',
      iconCode: 'sunny',
      humidity: 82,
      windSpeedKmh: 12.0,
    ),
    'Paris': const WeatherSnapshot(
      city: 'Paris',
      country: 'France',
      temperatureC: 19.0,
      condition: 'Mild Breeze',
      iconCode: 'partly-cloudy-day',
      humidity: 62,
      windSpeedKmh: 11.5,
    ),
    'San Francisco': const WeatherSnapshot(
      city: 'San Francisco',
      country: 'US',
      temperatureC: 18.0,
      condition: 'Coastal Fog / Mild',
      iconCode: 'cloudy',
      humidity: 72,
      windSpeedKmh: 20.0,
    ),
  };

  static const List<MarketTickerItem> marketTicker = [
    MarketTickerItem(symbol: 'S&P 500', name: 'S&P 500', price: 5984.10, changePercent: 0.72, isPositive: true),
    MarketTickerItem(symbol: 'NASDAQ', name: 'Nasdaq Composite', price: 19245.80, changePercent: 1.18, isPositive: true),
    MarketTickerItem(symbol: 'DOW', name: 'Dow Jones Industrial', price: 43810.20, changePercent: 0.45, isPositive: true),
    MarketTickerItem(symbol: 'BTC/USD', name: 'Bitcoin', price: 98650.00, changePercent: 3.65, isPositive: true),
    MarketTickerItem(symbol: 'ETH/USD', name: 'Ethereum', price: 3640.20, changePercent: -0.35, isPositive: false),
    MarketTickerItem(symbol: 'SOL/USD', name: 'Solana', price: 212.80, changePercent: 5.12, isPositive: true),
    MarketTickerItem(symbol: 'NVDA', name: 'Nvidia Corp', price: 148.90, changePercent: 2.45, isPositive: true),
    MarketTickerItem(symbol: 'AAPL', name: 'Apple Inc', price: 232.50, changePercent: 0.85, isPositive: true),
    MarketTickerItem(symbol: 'MSFT', name: 'Microsoft Corp', price: 445.60, changePercent: 1.25, isPositive: true),
    MarketTickerItem(symbol: 'BRENT', name: 'Crude Oil', price: 74.20, changePercent: -1.15, isPositive: false),
    MarketTickerItem(symbol: 'GOLD', name: 'Gold Troy Ounce', price: 2714.50, changePercent: 0.38, isPositive: true),
  ];

  static const List<String> trendingTags = [
    '#ClimateAccord2026',
    '#AIAgents',
    '#ChampionsLeague',
    '#QuantumComputing',
    '#Bitcoin100k',
    '#BiophilicLiving',
    '#DeepSpaceWater',
    '#CleanEnergySupergrid',
    '#LagosFiberHub',
    '#TokyoUrbanForest',
  ];

  static final List<ArticleComment> initialComments = [
    ArticleComment(
      id: 'c-1',
      author: 'Marcus Vance',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=128&q=80',
      text: 'The HVDC supergrid transmission guarantees are what will actually turn this diplomatic accord into concrete reality. Connecting surplus solar with distant wind belts is the true engineering solution.',
      timeAgo: '42m ago',
      likes: 24,
    ),
    ArticleComment(
      id: 'c-2',
      author: 'Dr. Elena Rostova',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=128&q=80',
      text: 'Crucially, the treaty includes open protocol standards for automated sub-second frequency regulation. Without AI grid orchestration, balancing continental DC loads would be immensely complex.',
      timeAgo: '1h ago',
      likes: 18,
    ),
    ArticleComment(
      id: 'c-3',
      author: 'Kofi Mensah',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=128&q=80',
      text: 'Great to see sovereign wealth funds backing the public guarantees. This gives private infrastructure funds the risk appetite they needed.',
      timeAgo: '2h ago',
      likes: 11,
    ),
  ];

  static const List<AppNotification> notifications = [
    AppNotification(
      id: 'notif-1',
      title: 'BREAKING: Global Climate Summit concludes with historic clean energy treaty.',
      timeAgo: '25m ago',
      isBreaking: true,
      articleId: 'art-hero-1',
    ),
    AppNotification(
      id: 'notif-2',
      title: 'MARKET ALERT: Bitcoin surges past \$98,600 as tech stocks lead broad rally.',
      timeAgo: '1h ago',
      articleId: 'art-bus-1',
    ),
    AppNotification(
      id: 'notif-3',
      title: 'DISCOVERY: Space telescope array confirms atmospheric water vapor on exoplanet.',
      timeAgo: '5h ago',
      articleId: 'art-sci-1',
    ),
  ];

  static const List<String> allAvailableInterests = [
    'Artificial Intelligence',
    'Clean Energy',
    'Autonomous Agents',
    'Wall Street',
    'Cryptocurrency',
    'European Football',
    'Space Exploration',
    'Quantum Computing',
    'Biophilic Design',
    'Fine Dining & Culinary',
    'Cybersecurity',
    'Electric Vehicles',
    'Global Diplomacy',
    'Biomedical Breakthroughs',
    'Cinema & Box Office',
  ];

  static final User mockUser = User(
    id: 'user-001',
    email: 'alex.rivera@readmore.org',
    displayName: 'Alex Rivera',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
    role: 'user',
    createdAt: DateTime(2025, 4, 12),
    subscriptionTier: 'free',
    adFreeEnabled: false,
    readingStreakDays: 5,
    articlesReadCount: 42,
    preferences: const UserPreferences(
      followedTopics: ['tech', 'business', 'science', 'top'],
      locationCity: 'New York',
      locationCountry: 'United States',
      audioAutoplay: true,
      enableBreakingAlerts: true,
      enableDailyBriefing: true,
    ),
  );

  static final List<SponsoredAd> initialAds = [
    SponsoredAd(
      id: 'ad-google-tpu',
      title: 'Google Cloud TPU v5p & Vertex AI Foundation Platform',
      description: 'Scale complex generative models with hyper-optimized pricing, low-latency inferencing, and unified enterprise control.',
      sponsorName: 'Google Cloud',
      sponsorLogoUrl: 'https://www.google.com/s2/favicons?domain=cloud.google.com&sz=128',
      targetUrl: 'https://cloud.google.com',
      callToAction: 'Start Free Trial',
      placement: AdPlacement.leaderboardBanner,
      format: AdFormat.googleAdSense,
      targetCategory: 'all',
      dailyBudget: 150.0,
      impressions: 4890,
      clicks: 342,
      createdAt: DateTime(2026, 11, 20),
    ),
    SponsoredAd(
      id: 'ad-google-nord',
      title: 'NordVPN Ultimate: Enterprise Threat Protection & 10Gbps Global Servers',
      description: 'Safeguard remote connections and confidential intelligence with zero-logging, quantum-resistant encryption.',
      sponsorName: 'Nord Security',
      sponsorLogoUrl: 'https://www.google.com/s2/favicons?domain=nordvpn.com&sz=128',
      targetUrl: 'https://nordvpn.com',
      callToAction: 'Get 72% Off',
      placement: AdPlacement.leaderboardBanner,
      format: AdFormat.googleAdSense,
      targetCategory: 'tech',
      dailyBudget: 120.0,
      impressions: 3210,
      clicks: 198,
      createdAt: DateTime(2026, 11, 21),
    ),
    SponsoredAd(
      id: 'ad-native-datadog',
      title: 'Autonomous Observability: How Top 100 Engineering Teams Scale AI Microservices in 2026',
      description: 'Discover proactive anomaly detection, synthetic user journeys, and end-to-end tracing across distributed hybrid clouds.',
      sponsorName: 'Datadog Enterprise',
      sponsorLogoUrl: 'https://www.google.com/s2/favicons?domain=datadoghq.com&sz=128',
      imageUrl: 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800&auto=format&fit=crop&q=80',
      targetUrl: 'https://datadoghq.com',
      callToAction: 'Read Benchmark Report',
      placement: AdPlacement.inFeedNative,
      format: AdFormat.sponsoredStory,
      targetCategory: 'tech',
      dailyBudget: 200.0,
      impressions: 6540,
      clicks: 412,
      createdAt: DateTime(2026, 11, 22),
    ),
    SponsoredAd(
      id: 'ad-native-greenfund',
      title: 'Next-Gen Clean Energy Infrastructure Yields Record Returns in 2026 Global Rebalance',
      description: 'Institutional analysis reveals clean transmission grids outperforming conventional utilities by 3.8x this quarter.',
      sponsorName: 'Apex Green Capital',
      sponsorLogoUrl: 'https://www.google.com/s2/favicons?domain=greenbond.org&sz=128',
      imageUrl: 'https://images.unsplash.com/photo-1509391365360-2e959784a276?w=800&auto=format&fit=crop&q=80',
      targetUrl: 'https://apexcapital.example',
      callToAction: 'Explore Fund Holdings',
      placement: AdPlacement.inFeedNative,
      format: AdFormat.sponsoredStory,
      targetCategory: 'business',
      dailyBudget: 175.0,
      impressions: 5120,
      clicks: 304,
      createdAt: DateTime(2026, 11, 23),
    ),
    SponsoredAd(
      id: 'ad-sidebar-aws',
      title: 'Deploy Claude 3.5 Sonnet on AWS Bedrock',
      description: 'Enterprise grade security, custom fine-tuning, and zero data leakage for your mission-critical workflows.',
      sponsorName: 'Amazon Web Services',
      sponsorLogoUrl: 'https://www.google.com/s2/favicons?domain=aws.amazon.com&sz=128',
      imageUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600&auto=format&fit=crop&q=80',
      targetUrl: 'https://aws.amazon.com/bedrock',
      callToAction: 'Explore Bedrock',
      placement: AdPlacement.sidebarRectangle,
      format: AdFormat.googleAdSense,
      targetCategory: 'tech',
      dailyBudget: 95.0,
      impressions: 8900,
      clicks: 521,
      createdAt: DateTime(2026, 11, 19),
    ),
    SponsoredAd(
      id: 'ad-sidebar-quant',
      title: 'QuantConnect: Algorithmic Alpha Modeling in Python',
      description: 'Backtest high-frequency strategies with tick-level US equities, crypto, and futures market data.',
      sponsorName: 'QuantConnect Cloud',
      sponsorLogoUrl: 'https://www.google.com/s2/favicons?domain=quantconnect.com&sz=128',
      imageUrl: 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=600&auto=format&fit=crop&q=80',
      targetUrl: 'https://quantconnect.com',
      callToAction: 'Code Strategies Free',
      placement: AdPlacement.sidebarRectangle,
      format: AdFormat.sponsoredStory,
      targetCategory: 'business',
      dailyBudget: 110.0,
      impressions: 7340,
      clicks: 440,
      createdAt: DateTime(2026, 11, 20),
    ),
  ];
}

import 'dart:convert';
import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:news_models/news_models.dart';

Future<Response> onRequest(RequestContext context) async {
  final container = context.read<AppContainer>();

  // GET: Fetch ads with filters
  if (context.request.method == HttpMethod.get) {
    final params = context.request.uri.queryParameters;
    final placementStr = params['placement'];
    final category = params['category'];
    final formatStr = params['format'];

    AdPlacement? placement;
    if (placementStr != null) {
      try {
        placement = AdPlacement.values.byName(placementStr);
      } catch (_) {}
    }

    AdFormat? format;
    if (formatStr != null) {
      try {
        format = AdFormat.values.byName(formatStr);
      } catch (_) {}
    }

    final ads = container.newsRepository.getSponsoredAds(
      placement: placement,
      category: category,
      format: format,
    );

    return Response.json(
      body: {
        'count': ads.length,
        'ads': ads.map((a) => a.toJson()).toList(),
      },
    );
  }

  // POST: Create / publish ad campaign
  if (context.request.method == HttpMethod.post) {
    final bodyStr = await context.request.body();
    final json = jsonDecode(bodyStr) as Map<String, dynamic>;

    try {
      final ad = SponsoredAd.fromJson(json);
      container.newsRepository.createSponsoredAd(ad);

      return Response.json(
        statusCode: 201,
        body: {
          'message': 'Ad campaign registered successfully',
          'ad': ad.toJson(),
        },
      );
    } catch (e) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Invalid ad payload: $e'},
      );
    }
  }

  return Response(statusCode: 405, body: 'Method Not Allowed.');
}

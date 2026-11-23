import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use GET.');
  }

  final container = context.read<AppContainer>();
  final markets = container.widgetService.getMarketTicker();

  return Response.json(
    body: {
      'markets': markets.map((m) => m.toJson()).toList(),
    },
  );
}

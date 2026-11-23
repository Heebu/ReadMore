import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use GET.');
  }

  final params = context.request.uri.queryParameters;
  final city = params['city'];
  final lat = double.tryParse(params['lat'] ?? '');
  final lng = double.tryParse(params['lng'] ?? '');

  final container = context.read<AppContainer>();
  final weather = container.widgetService.getWeather(city: city, lat: lat, lng: lng);

  return Response.json(body: {'weather': weather.toJson()});
}

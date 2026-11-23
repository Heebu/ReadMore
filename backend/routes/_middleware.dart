import 'package:backend/src/auth/auth_middleware.dart';
import 'package:backend/src/container.dart';
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler
      .use(authMiddleware())
      .use(provider<AppContainer>((_) => AppContainer.instance))
      .use(_corsMiddleware());
}

Middleware _corsMiddleware() {
  return (handler) {
    return (context) async {
      // Handle preflight OPTIONS request
      if (context.request.method == HttpMethod.options) {
        return Response(
          statusCode: 204,
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization, Accept',
          },
        );
      }

      final response = await handler(context);
      return response.copyWith(
        headers: {
          ...response.headers,
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization, Accept',
        },
      );
    };
  };
}

import 'dart:convert';
import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use POST.');
  }

  try {
    final bodyStr = await context.request.body();
    final json = jsonDecode(bodyStr) as Map<String, dynamic>;

    final email = json['email'] as String?;
    final password = json['password'] as String?;

    if (email == null || password == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing email or password'},
      );
    }

    final container = context.read<AppContainer>();
    final result = container.authService.login(
      email: email,
      password: password,
    );

    return Response.json(
      body: {
        'token': result.token,
        'user': result.user.toJson(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 401,
      body: {'error': e.toString().replaceAll('Exception: ', '')},
    );
  }
}

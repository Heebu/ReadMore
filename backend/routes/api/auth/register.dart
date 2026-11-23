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
    final displayName = json['displayName'] as String?;
    final avatarUrl = json['avatarUrl'] as String?;

    if (email == null || email.trim().isEmpty || password == null || displayName == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing required fields: email, password, displayName'},
      );
    }

    final container = context.read<AppContainer>();
    final user = container.authService.register(
      email: email,
      password: password,
      displayName: displayName,
      avatarUrl: avatarUrl,
    );

    final token = container.authService.generateToken(user);

    return Response.json(
      statusCode: 201,
      body: {
        'message': 'User registered successfully',
        'token': token,
        'user': user.toJson(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': e.toString().replaceAll('Exception: ', '')},
    );
  }
}

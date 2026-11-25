import 'dart:convert';
import 'dart:io';
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

    if (email == null || email.trim().isEmpty) {
      return Response.json(statusCode: 400, body: {'error': 'Email address is required.'});
    }

    final container = context.read<AppContainer>();
    final code = container.authService.requestPasswordReset(email);
    final isProd = Platform.environment['READMORE_ENV'] == 'production';

    return Response.json(
      body: {
        'message': 'A 6-digit password reset code has been issued (valid for 15 minutes).',
        if (!isProd) 'devResetCode': code,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 404,
      body: {'error': e.toString().replaceAll('Exception: ', '')},
    );
  }
}

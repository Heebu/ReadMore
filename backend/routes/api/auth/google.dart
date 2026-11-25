import 'dart:convert';
import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use POST.');
  }

  try {
    final bodyStr = await context.request.body();
    final json = bodyStr.trim().isNotEmpty
        ? jsonDecode(bodyStr) as Map<String, dynamic>
        : <String, dynamic>{};

    final email = (json['email'] as String?)?.trim().isNotEmpty == true
        ? (json['email'] as String).trim()
        : 'alex.rivera@readmore.org';
    final displayName = (json['displayName'] as String?)?.trim().isNotEmpty == true
        ? (json['displayName'] as String).trim()
        : 'Alex Rivera';
    final avatarUrl = json['avatarUrl'] as String?;

    final container = context.read<AppContainer>();
    final result = container.authService.loginOrRegisterOAuth(
      email: email,
      displayName: displayName,
      avatarUrl: avatarUrl,
    );

    return Response.json(
      body: {
        'token': result.token,
        'user': result.user.toJson(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': e.toString().replaceAll('Exception: ', '')},
    );
  }
}

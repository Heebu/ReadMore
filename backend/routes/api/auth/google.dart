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

    final idToken = json['idToken'] as String?;
    final email = json['email'] as String?;
    final displayName = json['displayName'] as String?;
    final avatarUrl = json['avatarUrl'] as String?;

    final container = context.read<AppContainer>();
    final result = await container.authService.verifyAndLoginWithGoogle(
      idToken: idToken,
      email: email,
      displayName: displayName,
      avatarUrl: avatarUrl,
    );

    return Response.json(
      body: {
        'token': result.token,
        'user': result.user.toJson(),
        'verifiedByGoogle': result.verifiedByGoogle,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 401,
      body: {'error': e.toString().replaceAll('Exception: ', '')},
    );
  }
}

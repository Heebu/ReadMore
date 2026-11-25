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
    final token = (json['token'] ?? json['code']) as String?;
    final newPassword = json['newPassword'] as String?;

    if (token == null || token.trim().isEmpty || newPassword == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Reset code and new password are required.'},
      );
    }

    final container = context.read<AppContainer>();
    container.authService.resetPassword(token: token, newPassword: newPassword);

    return Response.json(
      body: {'message': 'Password reset successfully. You can now sign in.'},
    );
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': e.toString().replaceAll('Exception: ', '')},
    );
  }
}

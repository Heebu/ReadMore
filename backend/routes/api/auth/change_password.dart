import 'dart:convert';
import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:news_models/news_models.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use POST.');
  }

  final user = context.read<User?>();
  if (user == null) {
    return Response.json(statusCode: 401, body: {'error': 'Authentication required.'});
  }

  try {
    final bodyStr = await context.request.body();
    final json = jsonDecode(bodyStr) as Map<String, dynamic>;
    final currentPassword = json['currentPassword'] as String? ?? '';
    final newPassword = json['newPassword'] as String?;

    if (newPassword == null || newPassword.isEmpty) {
      return Response.json(statusCode: 400, body: {'error': 'New password is required.'});
    }

    final container = context.read<AppContainer>();
    container.authService.changePassword(
      userId: user.id,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    return Response.json(body: {'message': 'Password updated successfully.'});
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': e.toString().replaceAll('Exception: ', '')},
    );
  }
}

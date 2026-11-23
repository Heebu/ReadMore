import 'package:dart_frog/dart_frog.dart';
import 'package:news_models/news_models.dart';
import '../container.dart';

/// Middleware that inspects the 'Authorization: Bearer <token>' header
/// and injects the authenticated User (or null) into the RequestContext.
Middleware authMiddleware() {
  return (handler) {
    return (context) async {
      final authHeader = context.request.headers['authorization'];
      User? authenticatedUser;

      if (authHeader != null && authHeader.toLowerCase().startsWith('bearer ')) {
        final token = authHeader.substring(7).trim();
        final claims = AppContainer.instance.authService.verifyToken(token);
        if (claims != null && claims['sub'] != null) {
          authenticatedUser = AppContainer.instance.authService.getUserById(claims['sub'] as String);
        }
      }

      final updatedContext = context.provide<User?>(() => authenticatedUser);
      return handler(updatedContext);
    };
  };
}

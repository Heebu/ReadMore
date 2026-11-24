import 'dart:convert';
import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:news_models/news_models.dart';

Future<Response> onRequest(RequestContext context) async {
  final user = context.read<User?>();
  if (user == null) {
    return Response.json(
      statusCode: 401,
      body: {'error': 'Authentication required.'},
    );
  }

  final container = context.read<AppContainer>();

  // GET: Current subscription status
  if (context.request.method == HttpMethod.get) {
    return Response.json(
      body: {
        'userId': user.id,
        'subscriptionTier': user.subscriptionTier,
        'isPro': user.isPro,
        'adFreeEnabled': user.adFreeEnabled,
      },
    );
  }

  // POST: Upgrade subscription
  if (context.request.method == HttpMethod.post) {
    final bodyStr = await context.request.body();
    final json = jsonDecode(bodyStr) as Map<String, dynamic>;

    final plan = json['plan'] as String? ?? 'annual';
    final paymentMethod = json['paymentMethod'] as String? ?? 'stripe';

    final updatedUser = container.authService.upgradeSubscription(
      user.id,
      plan: plan,
      paymentMethod: paymentMethod,
    );

    return Response.json(
      body: {
        'message': 'Subscription upgraded to Pro successfully',
        'user': updatedUser.toJson(),
      },
    );
  }

  return Response(statusCode: 405, body: 'Method Not Allowed.');
}

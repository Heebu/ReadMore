import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('GET /', () {
    test('responds with a 200 and API metadata', () async {
      final context = _MockRequestContext();
      final response = route.onRequest(context);
      expect(response.statusCode, equals(HttpStatus.ok));

      final bodyStr = await response.body();
      final json = jsonDecode(bodyStr) as Map<String, dynamic>;
      expect(json['name'], equals('ReadMore News Platform API'));
      expect(json['status'], equals('online'));
    });
  });
}

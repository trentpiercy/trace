import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

Future<Stream<User>> getUsers() async {
  final String url = 'http://test.confirmerator.com:8042/v1/api/user/test-uid';

  final client = new http.Client();
  final streamedRest = await client.send(
      http.Request('get', Uri.parse(url))
  );

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .expand((data) => (data))
      .map((data) => User.fromJSON(data));
}
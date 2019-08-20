import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/device.dart';

Future<Stream<Device>> getDevices() async {
  final String url = 'http://test.confirmerator.com:8042/v1/api/device/5cda02a02b130ac113dc1fac';

  final client = new http.Client();
  final streamedRest = await client.send(
      http.Request('get', Uri.parse(url))
  );

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .expand((data) => (data as List))
      .map((data) => Device.fromJSON(data));
}
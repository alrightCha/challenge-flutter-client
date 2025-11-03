import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_logger.dart';

class ApiClient {
  ApiClient({required this.baseUrl});
  final String baseUrl;

  Uri _u(String path, [Map<String, dynamic>? query]) => Uri.parse(
    '$baseUrl$path',
  ).replace(queryParameters: query?.map((k, v) => MapEntry(k, v?.toString())));

  Future<T> getJson<T>(
    String path,
    T Function(dynamic) decode, {
    Map<String, dynamic>? query,
  }) async {
    final uri = _u(path, query);
    AppLogger.httpRequest('GET', uri.toString());
    final res = await http.get(uri);
    AppLogger.httpResponse(res.statusCode, uri.toString(), body: res.body);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decode(json.decode(res.body));
    }
    throw Exception('GET $path failed: ${res.statusCode} ${res.body}');
  }

  Future<T> postJson<T>(String path, T Function(dynamic) decode, {Map<String, dynamic>? body}) async {
    final uri = _u(path);
    AppLogger.httpRequest('POST', uri.toString(), body: body);
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body != null ? json.encode(body) : null,
    );
    AppLogger.httpResponse(res.statusCode, uri.toString(), body: res.body);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decode(json.decode(res.body));
    }
    throw Exception('POST $path failed: ${res.statusCode} ${res.body}');
  }

  Future<T> deleteJson<T>(String path, T Function(dynamic) decode) async {
    final uri = _u(path);
    AppLogger.httpRequest('DELETE', uri.toString());
    final res = await http.delete(uri);
    AppLogger.httpResponse(res.statusCode, uri.toString(), body: res.body);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decode(json.decode(res.body));
    }
    throw Exception('DELETE $path failed: ${res.statusCode} ${res.body}');
  }

  Future<void> putEmpty(String path) async {
    final uri = _u(path);
    AppLogger.httpRequest('PUT', uri.toString());
    final res = await http.put(uri);
    AppLogger.httpResponse(res.statusCode, uri.toString(), body: res.body);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('PUT $path failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<T> putJson<T>(String path, T Function(dynamic) decode, {Map<String, dynamic>? body}) async {
    final uri = _u(path);
    AppLogger.httpRequest('PUT', uri.toString(), body: body);
    final res = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body != null ? json.encode(body) : null,
    );
    AppLogger.httpResponse(res.statusCode, uri.toString(), body: res.body);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decode(json.decode(res.body));
    }
    throw Exception('PUT $path failed: ${res.statusCode} ${res.body}');
  }
}

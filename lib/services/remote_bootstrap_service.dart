import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RemoteBootstrapException implements Exception {
  const RemoteBootstrapException(this.message);

  final String message;

  @override
  String toString() => 'RemoteBootstrapException: $message';
}

class RemoteBootstrapService {
  static const String _endpoint = 'https://rusogmblng.online/lander/jsonclo1';

  final http.Client _client;

  RemoteBootstrapService({http.Client? client})
      : _client = client ?? http.Client();

  Future<String> fetchStartupUrl() async {
    late http.Response response;
    try {
      response = await _client.get(
        Uri.parse(_endpoint),
        headers: const {
          'User-Agent': 'FanArena bububu',
        },
      );
      debugPrint(
        'FanArenaStartup: remote_request status=${response.statusCode}',
      );
    } catch (e) {
      debugPrint('FanArenaStartup: remote_request network_error=$e');
      throw RemoteBootstrapException('Network request failed: $e');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RemoteBootstrapException(
        'Unexpected HTTP status: ${response.statusCode}',
      );
    }

    Map<String, dynamic> jsonBody;
    try {
      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const RemoteBootstrapException('JSON root is not an object');
      }
      jsonBody = decoded;
    } catch (e) {
      if (e is RemoteBootstrapException) rethrow;
      throw RemoteBootstrapException('Invalid JSON payload: $e');
    }

    final rawUrl = jsonBody['url'];
    if (rawUrl is! String || rawUrl.trim().isEmpty) {
      debugPrint('FanArenaStartup: remote_request missing_url_field');
      throw const RemoteBootstrapException('Missing `url` field in JSON');
    }

    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      debugPrint('FanArenaStartup: remote_request invalid_url=$rawUrl');
      throw const RemoteBootstrapException('`url` field is not a valid URL');
    }

    debugPrint('FanArenaStartup: remote_request resolved_url=$uri');
    return uri.toString();
  }
}

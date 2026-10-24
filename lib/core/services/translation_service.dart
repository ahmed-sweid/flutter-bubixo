import 'dart:convert';

import 'package:http/http.dart' as http;

/// A translation failure that carries a message the vocabulary screen can show.
class TranslationException implements Exception {
  const TranslationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Talks to Bubixo's text-tools API on behalf of the translation flow.
///
/// The endpoint expects a short-lived request token before each translation,
/// so both calls and their timeouts stay in one place instead of the widget.
class TranslationService {
  const TranslationService({this._client});

  static final Uri _tokenUri = Uri.parse(
    'https://api.bubixo.com/text-tools/token',
  );
  static final Uri _translateUri = Uri.parse(
    'https://api.bubixo.com/text-tools/translate',
  );
  static const Map<String, String> _headers = <String, String>{
    'Content-Type': 'application/json',
    // Match the trusted web client origin used by Bubixo's text-tools API.
    'Origin': 'https://bubixo.com',
    'Referer': 'https://bubixo.com/',
  };

  /// Injectable for tests; when absent the shared `http` entry points are used
  /// so no client is left open per request.
  final http.Client? _client;

  /// Returns the translated text for `en`/`tr` directions.
  Future<String> translate({
    required String text,
    required String source,
    required String target,
  }) async {
    final token = await _requestToken();

    final response = await _post(
      _translateUri,
      headers: <String, String>{..._headers, 'X-Text-Tools-Token': token},
      body: jsonEncode({'text': text, 'source': source, 'target': target}),
      timeout: const Duration(seconds: 25),
    );

    if (response.statusCode == 429) {
      throw const TranslationException(
        'Çok sık istek gönderildi. Biraz sonra tekrar dene.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TranslationException(
        'Çeviri isteği başarısız oldu (HTTP ${response.statusCode}). '
        'Biraz sonra tekrar dene.',
      );
    }

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic> ||
        data['success'] != true ||
        data['translation'] is! String ||
        (data['translation'] as String).trim().isEmpty) {
      throw const TranslationException(
        'Çeviri servisinden geçerli bir sonuç alınamadı.',
      );
    }
    return (data['translation'] as String).trim();
  }

  Future<String> _requestToken() async {
    final tokenResponse = await _post(
      _tokenUri,
      headers: _headers,
      timeout: const Duration(seconds: 12),
    );

    if (tokenResponse.statusCode < 200 || tokenResponse.statusCode >= 300) {
      throw TranslationException(
        'Çeviri servisi token isteğini reddetti '
        '(HTTP ${tokenResponse.statusCode}).',
      );
    }

    final tokenData = jsonDecode(tokenResponse.body);
    if (tokenData is! Map<String, dynamic> || tokenData['token'] is! String) {
      throw const TranslationException('Çeviri servisi geçerli yanıt vermedi.');
    }
    return tokenData['token'] as String;
  }

  Future<http.Response> _post(
    Uri url, {
    required Map<String, String> headers,
    String? body,
    required Duration timeout,
  }) async {
    final client = _client;
    // Without an injected client the shared entry points are used, so no
    // connection is left open after a single request.
    final request = client != null
        ? client.post(url, headers: headers, body: body)
        : http.post(url, headers: headers, body: body);
    try {
      return await request.timeout(timeout);
    } on http.ClientException {
      throw const TranslationException(
        'Bağlantı kurulamadı. İnternetini kontrol et.',
      );
    }
  }
}

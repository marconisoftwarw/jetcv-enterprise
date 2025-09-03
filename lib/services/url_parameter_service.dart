import 'dart:convert';

class UrlParameterService {
  /// Parse URL parameters from a registration link
  /// Expected format: /register?token=xxx&data=base64encodedjson
  static Map<String, dynamic> parseRegistrationUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final parameters = <String, dynamic>{};

      // Extract invitation token
      final token = uri.queryParameters['token'];
      if (token != null) {
        parameters['invitationToken'] = token;
      }

      // Extract prefill data
      final dataParam = uri.queryParameters['data'];
      if (dataParam != null) {
        try {
          final decodedData = utf8.decode(base64Decode(dataParam));
          final prefillData = jsonDecode(decodedData) as Map<String, dynamic>;
          parameters['prefillData'] = prefillData;
        } catch (e) {
          print('Error decoding prefill data: $e');
        }
      }

      return parameters;
    } catch (e) {
      print('Error parsing URL parameters: $e');
      return {};
    }
  }

  /// Generate a registration link with prefill data
  static String generateRegistrationLink({
    String? invitationToken,
    Map<String, dynamic>? prefillData,
    String baseUrl = '/register',
  }) {
    final uri = Uri.parse(baseUrl);
    final queryParameters = <String, String>{};

    if (invitationToken != null) {
      queryParameters['token'] = invitationToken;
    }

    if (prefillData != null) {
      try {
        final jsonString = jsonEncode(prefillData);
        final encodedData = base64Encode(utf8.encode(jsonString));
        queryParameters['data'] = encodedData;
      } catch (e) {
        print('Error encoding prefill data: $e');
      }
    }

    return uri.replace(queryParameters: queryParameters).toString();
  }

  /// Extract invitation token from URL
  static String? extractInvitationToken(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters['token'];
    } catch (e) {
      print('Error extracting invitation token: $e');
      return null;
    }
  }

  /// Extract prefill data from URL
  static Map<String, dynamic>? extractPrefillData(String url) {
    try {
      final uri = Uri.parse(url);
      final dataParam = uri.queryParameters['data'];

      if (dataParam != null) {
        final decodedData = utf8.decode(base64Decode(dataParam));
        return jsonDecode(decodedData) as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      print('Error extracting prefill data: $e');
      return null;
    }
  }
}

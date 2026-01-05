import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DeepLService {
  Future<String> translate(String text, String targetLang) async {
    // API 키는 .env 파일에서 불러오며, 보안상 노출하지 않도록 합니다.
    String apiKey = dotenv.env['DEEPL_API_KEY']!;
    final response = await http.post(
      Uri.parse('https://api-free.deepl.com/v2/translate'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'DeepL-Auth-Key $apiKey',
      },
      body: {
        'text': text,
        'target_lang': targetLang, // 예: 'EN' 또는 'KO'
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      dev.log('DeepL response body: $decodedBody');
      final jsonResponse = json.decode(decodedBody);
      return jsonResponse['translations'][0]['text'];
    } else {
      throw Exception('Failed to translate: ${response.body}');
    }
  }
}

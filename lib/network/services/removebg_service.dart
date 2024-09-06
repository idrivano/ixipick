import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class RemoveBgService {
  Future<void> editImage(String imagePath, String resultPath) async {
    final uri = Uri.parse('https://image-api.photoroom.com/v2/edit');

    // const String apiKeyLive = '83f41bd671f6eb35172baa395c5c4133777b7b5f';
    // const String apiKeySandbox = 'sandbox_83f41bd671f6eb35172baa395c5c4133777b7b5f';

    const String apiKeyLive = 'bb6c12fcd5083458e52642402453111cc3e2caa2';
    const String apiKeySandbox = 'sandbox_bb6c12fcd5083458e52642402453111cc3e2caa2';

    var request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'image/png, application/json'
      ..headers['x-api-key'] = apiKeySandbox
      ..files.add(await http.MultipartFile.fromPath(
        'imageFile',
        imagePath,
        contentType: MediaType('image', 'jpeg'),
      ))
      ..fields['shadow.mode'] = 'ai.soft'
      ..fields['background.color'] = '00000000'
      ..fields['padding'] = '0.1';

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final file = File(resultPath);
      await file.writeAsBytes(response.bodyBytes);
      print('Image saved as result-ixipick.png');
    } else {
      print('Failed to process image: ${response.statusCode}');
    }
  }
}

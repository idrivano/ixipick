import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';


class PicsArtService {
  final String apiKey = 'eyJraWQiOiI5NzIxYmUzNi1iMjcwLTQ5ZDUtOTc1Ni05ZDU5N2M4NmIwNTEiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJhdXRoLXNlcnZpY2UtZWJhZTk0NjUtYmYzMi00Y2M3LTkyZDUtNzA1MjM4ODNkZGM3IiwiYXVkIjoiMzQ0NTYwMjQ1MDE2MTAxIiwibmJmIjoxNzI1NDExMzU2LCJzY29wZSI6WyJiMmItYXBpLmdlbl9haSIsImIyYi1hcGkuaW1hZ2VfYXBpIl0sImlzcyI6Imh0dHBzOi8vYXBpLnBpY3NhcnQuY29tL3Rva2VuLXNlcnZpY2UiLCJvd25lcklkIjoiMzQ0NTYwMjQ1MDE2MTAxIiwiaWF0IjoxNzI1NDExMzU2LCJqdGkiOiI5YTY2Y2FiMi1hNDlkLTRjM2UtOWJiNC1hZjJhMGM4NzhhYjIifQ.hKgi3SvmXo3ynS0NE4DD8twXoKyRTpx586LPPbFrc4oA1JQyrZ_WwyDmrHgetXtNRVucjzDbuARF61zP9GyDUyvI9iBjeXh_UVJnT_uWCgrWUHVcTErWYFAFnYm0XV7YmiDhutdvcaZO5LgTDawA4NZm-HmrJNwzxYcyqaThgZDgw3ESyX_JWt1O1gQA31s4vtG2ldw9zuU9KeI7Dychwaz1h_RRWJemUGqBASq48-PsrqDz_f4d14h-EDLiD7Fpmr-xMJsVznwhdEJ5uRc_dsuffnNJhZHIYmUvdUY55Z38Yc0L0awwIKBALLDyQ9nDqndDJ5Mti-a392ebO60iNA';

  Future<String> upscaleImage({File? imageFile, String? imageUrl, int upscaleFactor = 2, String format = 'JPG'}) async {
    final uri = Uri.parse('https://api.picsart.io/tools/1.0/upscale');

    var request = http.MultipartRequest('POST', uri)
      ..headers['X-Picsart-API-Key'] = apiKey;

    if (imageFile != null) {
      request.files.add(
        http.MultipartFile(
          'image',
          imageFile.readAsBytes().asStream(),
          imageFile.lengthSync(),
          filename: path.basename(imageFile.path),
          contentType: MediaType('image', 'jpg'),
        ),
      );
    } else if (imageUrl != null) {
      request.fields['image_url'] = imageUrl;
    } else {
      throw Exception('No image source provided');
    }

    request.fields['upscale_factor'] = upscaleFactor.toString();
    request.fields['format'] = format;

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);
      var resultUrl = data['data']['url'];
      return resultUrl;
    } else {
      throw Exception('Failed to upscale image: ${response.statusCode}');
    }
  }

  Future<void> downloadImage(String imageUrl, String filename) async {
    var response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      var file = File(filename);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Failed to download image: ${response.statusCode}');
    }
  }
}


import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;


class ConvertioService {
  final String apiKey = 'aba84255f616d29121aa65f8fcb51ef5';
  final String apiUrl = "https://api.convertio.co/convert";

  Future<String?> startConversion(File file, String outputFormat) async {
    List<int> fileBytes = await file.readAsBytes();
    String base64File = base64Encode(fileBytes);

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "apikey": apiKey,
        "input": "base64",
        "file": base64File,
        "filename": file.path.split('/').last,
        "outputformat": outputFormat,
      }),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'ok') {
        String conversionId = jsonResponse['data']['id'];
        print("Conversion réussie ! ID: $conversionId");
        return conversionId;
      } else {
        print("Erreur : ${jsonResponse['error']}");
      }
    } else {
      print("Échec de la requête: ${response.statusCode}");
    }
    return null;
  }

  Future<String?> fetchConvertedFile(String? conversionId) async {
    final response = await http.get(
      Uri.parse('$apiUrl/$conversionId/status'),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'ok' && jsonResponse['data']['step'] == 'finish') {
        String fileUrl = jsonResponse['data']['output']['url'];
        print("Fichier converti disponible à : $fileUrl");
        return fileUrl;
      } else {
        print("La conversion n'est pas encore terminée.");
      }
    } else {
      print("Échec de la récupération du fichier : ${response.statusCode}");
    }
    return null;
  }
}


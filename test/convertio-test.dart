import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ixipick/network/services/convertio_service.dart';
import 'package:ixipick/screens/convertio.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;


class MockConvertioService extends Mock implements ConvertioService {}
class MockImagePicker extends Mock implements ImagePicker {}
class MockHttpClient extends Mock implements http.Client {}
class MockDirectory extends Mock implements Directory {}

void main() {
  late MockConvertioService mockConvertioService;
  late MockImagePicker mockImagePicker;
  late MockHttpClient mockHttpClient;
  late MockDirectory mockDirectory;

  setUp(() {
    mockConvertioService = MockConvertioService();
    mockImagePicker = MockImagePicker();
    mockHttpClient = MockHttpClient();
    mockDirectory = MockDirectory();
  });

  testWidgets('Test image selection, conversion, and download flow', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ConvertioPage()));

    // Initialisation
    expect(find.text('Proceder'), findsOneWidget);
    expect(find.text('Télecharger'), findsNothing);

    // Simuler une selection d'image dans la gallerie
    final tempImage = File('path/to/temp_image.png');
    when(mockImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50))
        .thenAnswer((_) async => XFile(tempImage.path));

    // Simuler un click pour aller dans la gallerie
    await tester.tap(find.byIcon(Icons.photo));
    await tester.pump();

    // Verifier si l'image à ete recuperer
    expect(find.byType(FileImage), findsOneWidget);

    // Simuler le traitement de l'image
    const conversionId = 'conversion_id';
    when(mockConvertioService.startConversion(tempImage, 'svg'))
        .thenAnswer((_) async => conversionId);

    await tester.tap(find.text('Proceder'));
    await tester.pump();

    // Verifier si l'appel du service startConversion fonctionne
    verify(mockConvertioService.startConversion(tempImage, 'svg')).called(1);

    // Simuler le lien de telechargement et Verifier si le télechargement fonctionne
    const convertedFileUrl = 'http://example.com/converted-image.svg';
    when(mockConvertioService.fetchConvertedFile(conversionId))
        .thenAnswer((_) async => convertedFileUrl);

    const downloadPath = "/storage/emulated/0/Download/";
    final filePath = path.join(downloadPath, 'converted-image.svg');
    when(mockHttpClient.get(Uri.parse(convertedFileUrl)))
        .thenAnswer((_) async => http.Response('response body', 200));

    when(mockDirectory.exists()).thenAnswer((_) async => true);

    await tester.tap(find.text('Télecharger'));
    await tester.pump();

    // Verifier si le message de télechargement s'affiche
    expect(find.text('Image téléchargée: $filePath'), findsOneWidget);
  });
}

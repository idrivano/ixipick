import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ixipick/network/services/upscaly_service.dart';
import 'package:ixipick/screens/upscaly.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;


class MockPicsArtService extends Mock implements PicsArtService {}
class MockImagePicker extends Mock implements ImagePicker {}
class MockHttpClient extends Mock implements http.Client {}
class MockDirectory extends Mock implements Directory {}

void main() {
  late MockPicsArtService mockPicsArtService;
  late MockImagePicker mockImagePicker;
  late MockHttpClient mockHttpClient;
  late MockDirectory mockDirectory;

  setUp(() {
    mockPicsArtService = MockPicsArtService();
    mockImagePicker = MockImagePicker();
    mockHttpClient = MockHttpClient();
    mockDirectory = MockDirectory();
  });

  testWidgets('Test image selection, processing, and download flow', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: UpscalyPage()));

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
    const tempUrl = 'http://example.com/upscaled-image.jpg';
    when(mockPicsArtService.upscaleImage(
      imageFile: tempImage,
      upscaleFactor: 4,
      format: 'JPG',
    )).thenAnswer((_) async => tempUrl);

    await tester.tap(find.text('Proceder'));
    await tester.pump();

    // Verifier si l'appel du service upscaleImage fonctionne
    verify(mockPicsArtService.upscaleImage(
      imageFile: tempImage,
      upscaleFactor: 4,
      format: 'JPG',
    )).called(1);

    // Verifier si le télechargement fonctionne
    const downloadPath = "/storage/emulated/0/Download/";
    final filePath = path.join(downloadPath, 'upscaled-image.jpg');
    when(mockHttpClient.get(Uri.parse(tempUrl)))
        .thenAnswer((_) async => http.Response('response body', 200));

    when(mockDirectory.exists()).thenAnswer((_) async => true);

    await tester.tap(find.text('Télecharger'));
    await tester.pump();

    // Verifier si le message de télechargement s'affiche
    expect(find.text('Image télecharger: $filePath'), findsOneWidget);
  });
}

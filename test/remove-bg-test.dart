import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ixipick/network/services/removebg_service.dart';
import 'package:ixipick/screens/home.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;


class MockRemoveBgService extends Mock implements RemoveBgService {}
class MockImagePicker extends Mock implements ImagePicker {}
class MockDirectory extends Mock implements Directory {}

void main() {
  late MockRemoveBgService mockRemoveBgService;
  late MockImagePicker mockImagePicker;

  setUp(() {
    mockRemoveBgService = MockRemoveBgService();
    mockImagePicker = MockImagePicker();
  });

  testWidgets('Test image selection and processing flow', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

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
    final tempDir = await getTemporaryDirectory();
    final resultFilePath = path.join(tempDir.path, 'result-ixipick.png');

    when(mockRemoveBgService.editImage(tempImage.path, resultFilePath))
        .thenAnswer((_) async {});

    await tester.tap(find.text('Proceder'));
    await tester.pump();

    // Verifier si l'appel du service editImage fonctionne
    verify(mockRemoveBgService.editImage(tempImage.path, resultFilePath)).called(1);

    // Verifier si le button "Télecharger" fonctionne
    await tester.pump();
    expect(find.text('Télecharger'), findsOneWidget);
  });
}

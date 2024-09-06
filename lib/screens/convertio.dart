import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../network/services/convertio_service.dart';
import '../widgets/button.dart';
import '../widgets/styles/app_style.dart';


class ConvertioPage extends StatefulWidget {
  const ConvertioPage({super.key, this.title});
  final String? title;

  @override
  State<ConvertioPage> createState() => _ConvertioPageState();
}

class _ConvertioPageState extends State<ConvertioPage> {
  File? imageFile;
  final picker = ImagePicker();
  bool isLoading = false;
  bool isDownloadReady = false;
  String? conversionId;
  final ConvertioService _imageService = ConvertioService();

  // Methode pour selectionner l'image dans la gallerie
  Future<void> getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null){
      setState(() {
        imageFile = File(pickedFile.path);
        isDownloadReady = false;
      });
    }
  }

  Future<void> selectImageAndConvert() async {
    // verifier si l'image à bien éte sélectionner
    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une image.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      conversionId = await _imageService.startConversion(imageFile!, 'svg');

      if (conversionId != null) {
        setState(() {
          isDownloadReady = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Procédure effectuée avec succès!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la conversion.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error lors de la conversion')),
      );
      print('Error lors de la conversion: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Methode pour télécharger l'image traiter
  Future<void> downloadImage() async {
    if (imageFile == null || !isDownloadReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune conversion n\'a été effectuée.')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final convertedFileUrl = await _imageService.fetchConvertedFile(conversionId);

      if (convertedFileUrl != null) {
        final response = await http.get(Uri.parse(convertedFileUrl));

        if (response.statusCode == 200) {
          const downloadPath = "/storage/emulated/0/Download/";
          final newPath = path.join(downloadPath, 'converted-image.svg');

          final downloadDir = Directory(downloadPath);
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }

          final newFile = File(newPath);
          await newFile.writeAsBytes(response.bodyBytes);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image téléchargée: ${newFile.path}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors du téléchargement de l\'image: ${response.statusCode}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la récupération du fichier converti.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du téléchargement')),
      );
      print('Erreur lors du téléchargement : $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppStyle.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 250,
                decoration: BoxDecoration(
                  image: imageFile == null ? const DecorationImage(
                      image: AssetImage(AppStyle.font),
                      fit: BoxFit.cover
                  ) : DecorationImage(
                      image: FileImage(imageFile ?? File('')),
                      fit: BoxFit.cover
                  ),
                  borderRadius: BorderRadius.circular(AppStyle.defaultBorderRadious),
                  border: Border.all(width: 1, color: AppStyle.blackColor.withOpacity(.3)),
                ),
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.photo, size:35, color: AppStyle.errorColor),
                    onPressed: (){
                      getImage(ImageSource.gallery);
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppStyle.defaultPadding),
              DefaultButton(
                height: 50,
                isLoading: isLoading,
                text: isLoading ? "Chargement..." : "Proceder",
                onPressed: isLoading ? null : selectImageAndConvert,
              ),

              const SizedBox(height: AppStyle.defaultPadding),
              if (isDownloadReady) ...[
                const SizedBox(height: AppStyle.defaultPadding),
                DefaultButton(
                  height: 50,
                  text: isLoading ? "Chargement..." : "Télecharger",
                  onPressed: downloadImage,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

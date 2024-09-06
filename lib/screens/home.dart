import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../network/services/removebg_service.dart';
import '../widgets/button.dart';
import '../widgets/styles/app_style.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key, this.title});
  final String? title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? imageFile;
  final picker = ImagePicker();
  bool isLoading = false;
  bool isDownloadReady = false;
  final RemoveBgService _imageService = RemoveBgService();

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null){
      setState(() {
        imageFile = File(pickedFile.path);
        isDownloadReady = false;
      });
    }
  }

  Future<void> processImage() async {
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
      final tempDir = await getTemporaryDirectory();
      final resultFilePath = path.join(tempDir.path, 'result-ixipick.png');

      await _imageService.editImage(imageFile!.path, resultFilePath);

      setState(() {
        imageFile = File(resultFilePath);
        isDownloadReady = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Procedure éffectuer avec succès!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error lors de l\'éxecussion')),
      );
      print('Error lors de l\'éxecussion: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> downloadImage() async {
    if (imageFile != null) {
      try {
        const downloadPath = "/storage/emulated/0/Download/";
        final newPath = path.join(downloadPath, path.basename(imageFile!.path));

        final downloadDir = Directory(downloadPath);
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }

        final newFile = await imageFile!.copy(newPath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image télecharger: ${newFile.path}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du télechargement: $e')),
        );
      }
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.camera, size:35, color: AppStyle.errorColor),
                        onPressed: (){
                          getImage(ImageSource.camera);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo, size:35, color: AppStyle.errorColor),
                        onPressed: (){
                          getImage(ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppStyle.defaultPadding),
              DefaultButton(
                height: 50,
                isLoading: isLoading,
                text: isLoading ? "Chargement..." : "Proceder",
                onPressed: isLoading ? null : processImage,
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

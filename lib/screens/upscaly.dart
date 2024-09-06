import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../network/services/upscaly_service.dart';
import '../widgets/button.dart';
import '../widgets/styles/app_style.dart';


class UpscalyPage extends StatefulWidget {
  const UpscalyPage({super.key, this.title});
  final String? title;

  @override
  State<UpscalyPage> createState() => _UpscalyPageState();
}

class _UpscalyPageState extends State<UpscalyPage> {
  File? imageFile;
  final picker = ImagePicker();
  String? downloadUrl;
  bool isLoading = false;
  bool isDownloadReady = false;
  final PicsArtService _picsArtService = PicsArtService();

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        isDownloadReady = false;
      });
    }
  }

  Future<void> editImage() async {
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
      String tempUrl = await _picsArtService.upscaleImage(imageFile: imageFile!, upscaleFactor: 4, format: 'JPG');
      setState(() {
        downloadUrl = tempUrl;
        isDownloadReady = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image mise à jour avec success!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error lors de upscaling de l\'image: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> downloadImage() async {
    if (downloadUrl != null) {
      setState(() {
        isLoading = true;
      });

      try {
        const downloadPath = "/storage/emulated/0/Download/";
        final filePath = path.join(downloadPath, 'upscaled-image.jpg');

        final downloadDir = Directory(downloadPath);
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }

        final response = await http.get(Uri.parse(downloadUrl!));
        if (response.statusCode == 200) {
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image télecharger: $filePath')),
          );
        } else {
          throw Exception('Impossible de télecharger l\'image: ${response.statusCode}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du télechargement: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
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
                onPressed: isLoading ? null : editImage,
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:submission/controller/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Food Recognizer App'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const _HomeBody(),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();

    void _showImageSourceDialog(BuildContext context) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeri'),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.pickAndCropImage(context, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Kamera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.pickAndCropImage(context, ImageSource.camera);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _showImageSourceDialog(context),
                  child:
                      controller.imagePath == null
                          ? const Align(
                            alignment: Alignment.center,
                            child: Icon(Icons.image, size: 100),
                          )
                          : Image.file(
                            File(controller.imagePath!),
                            fit: BoxFit.cover,
                            height: 200,
                          ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () => _showImageSourceDialog(context),
                    icon: const Icon(Icons.add_a_photo, size: 16),
                    label: const Text("Pilih Gambar"),
                  ),
                ),
              ],
            ),
          ),
        ),

        FilledButton.tonal(
          onPressed:
              controller.isLoading || controller.imagePath == null
                  ? null
                  : () {
                    controller.goToResultPage(context);
                  },
          child:
              controller.isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Analyze"),
        ),
      ],
    );
  }
}

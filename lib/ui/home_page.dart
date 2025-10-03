import 'dart:io';
import 'package:flutter/material.dart';
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
        centerTitle: true,
      ),
      body: const SafeArea(
        child: Padding(padding: EdgeInsets.all(16.0), child: _HomeBody()),
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.blue),
                  title: const Text('Galeri'),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.pickFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.green),
                  title: const Text('Kamera (Custom Feed)'),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.openCameraPage(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _showImageSourceDialog(context),
                      child:
                          controller.imagePath == null
                              ? const Icon(
                                Icons.image_outlined,
                                size: 120,
                                color: Colors.grey,
                              )
                              : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  height: 200,
                                  width: double.infinity,
                                  child: Image.file(
                                    File(controller.imagePath!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () => _showImageSourceDialog(context),
                      icon: const Icon(Icons.add_a_photo, size: 18),
                      label: const Text("Pilih Gambar"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed:
                controller.isLoading || controller.imagePath == null
                    ? null
                    : () {
                      controller.goToResultPage(context);
                    },
            child:
                controller.isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text("Analyze", style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

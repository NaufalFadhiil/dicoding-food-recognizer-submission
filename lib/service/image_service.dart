import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart'; 
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImageFromGallery() async {
    try {
      if (Platform.isAndroid) {
        final photosStatus = await Permission.photos.status;
        final storageStatus = await Permission.storage.status;

        if (!photosStatus.isGranted && !storageStatus.isGranted) {
          final result =
              await [Permission.photos, Permission.storage].request();
          if (!(result[Permission.photos]?.isGranted == true ||
              result[Permission.storage]?.isGranted == true)) {
            return null;
          }
        }
      } else {
        final status = await Permission.photos.status;
        if (!status.isGranted) {
          final s = await Permission.photos.request();
          if (!s.isGranted) return null;
        }
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return null;

      return await cropImage(pickedFile.path);
    } catch (e, st) {
      debugPrint('ImageService.pickImageFromGallery error: $e\n$st');
      return null;
    }
  }

  Future<String?> cropImage(String imagePath) async {
    try {
      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: imagePath,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );

      return cropped?.path;
    } catch (e, st) {
      debugPrint('ImageService.cropImage error: $e\n$st');
      return null;
    }
  }
}

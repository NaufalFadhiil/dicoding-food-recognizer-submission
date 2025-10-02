import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';

class ImageHelper {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickAndCropImage(ImageSource source) async {
    // Step 1: Ambil gambar dari kamera/galeri
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile == null) return null;

    // Step 2: Crop image setelah dipilih
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: false,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );

    if (croppedFile == null) return null;

    return File(croppedFile.path);
  }
}

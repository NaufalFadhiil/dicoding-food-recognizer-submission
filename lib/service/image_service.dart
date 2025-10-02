import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImage(ImageSource source) async {
    // 1. Cek izin (permission)
    if (source == ImageSource.camera) {
      var status = await Permission.camera.request();
      if (!status.isGranted) return null;
    } else {
      // Untuk galeri (photos / storage)
      var photosStatus = await Permission.photos.request();
      var storageStatus = await Permission.storage.request();

      if (!photosStatus.isGranted && !storageStatus.isGranted) {
        return null;
      }
    }

    // 2. Ambil gambar
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return null;

    // 3. Crop image
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 80,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: const Color(0xFF2196F3),
          toolbarWidgetColor: const Color(0xFFFFFFFF),
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );

    return croppedFile?.path;
  }
}

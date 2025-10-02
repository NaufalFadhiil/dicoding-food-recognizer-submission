import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:submission/service/image_service.dart';
import 'package:submission/ui/result_page.dart';
import 'package:submission/ui/camera_page.dart';

class HomeController extends ChangeNotifier {
  final ImageService _imageService = ImageService();
  String? _imagePath;
  String? get imagePath => _imagePath;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> pickFromGallery() async {
    _setLoading(true);
    _imagePath = await _imageService.pickImageFromGallery();
    if (_imagePath != null) {
      notifyListeners();
    }
    _setLoading(false);
  }

  Future<void> openCameraPage(BuildContext context) async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Izin kamera ditolak")));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CameraPage(
              camera: firstCamera,
              onImageTaken: (path) {
                setImagePath(path);
              },
            ),
      ),
    );
  }

  void setImagePath(String path) async {
    final cropped = await _imageService.cropImage(path);

    _imagePath = cropped ?? path;
    notifyListeners();
  }

  void goToResultPage(BuildContext context) {
    if (_imagePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(imagePath: _imagePath!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar terlebih dahulu!')),
      );
    }
  }
}

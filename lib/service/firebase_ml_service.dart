import 'dart:io';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';

class FirebaseMLService {
  // ⚠️ Ganti dengan nama model yang Anda unggah ke Firebase ML
  static const String _modelName = "food_classifier_model"; 

  Future<File?> loadModel() async {
    try {
      final instance = FirebaseModelDownloader.instance;
      final model = await instance.getModel(
        _modelName, 
        // Mengunduh model terbaru yang tersedia secara lokal
        FirebaseModelDownloadType.latestModel, 
        // Menggunakan kondisi minimal agar mudah diuji
        FirebaseModelDownloadConditions(
          iosAllowsCellularAccess: true,
          iosAllowsBackgroundDownloading: false,
          androidChargingRequired: false,
          androidWifiRequired: false,
          androidDeviceIdleRequired: false,
        ),
      );
      // Mengembalikan File TFLite yang sudah diunduh/cache
      return model.file; 
    } catch (e) {
      print("Error downloading model from Firebase ML: $e");
      return null;
    }
  }
}
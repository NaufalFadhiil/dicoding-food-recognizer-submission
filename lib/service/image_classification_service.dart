// lib/service/image_classification_service.dart

import 'dart:isolate';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:submission/service/firebase_ml_service.dart';
import 'package:submission/service/isolate_inference.dart';

class ImageClassificationService {
  final FirebaseMLService _firebaseMLService = FirebaseMLService();
  final IsolateInference _isolateInference =
      IsolateInference(); // Inisialisasi Isolate Helper

  late final List<String> _foodLabels;
  late bool _isLabelsLoaded = false;
  late String _modelPath; // Simpan path model yang sudah diunduh

  // 1. Inisialisasi Label dan Isolate
  Future<void> initHelper() async {
    if (!_isLabelsLoaded) await _loadLabels();

    // Muat model dan simpan path-nya
    final modelFile = await _firebaseMLService.loadModel();
    if (modelFile != null) {
      _modelPath = modelFile.path;
    }

    await _isolateInference.start(); // Mulai Isolate
  }

  Future<void> _loadLabels() async {
    try {
      final labelsTxt = await rootBundle.loadString('assets/labels.txt');
      final allLabels =
          labelsTxt.split('\n').where((s) => s.isNotEmpty).toList();
      _foodLabels = allLabels.sublist(1); // Mengabaikan __background__
      _isLabelsLoaded = true;
    } catch (e) {
      print("Error loading labels: $e");
    }
  }

  // 2. Fungsi Inferensi untuk Gambar Statis
  Future<Map<String, dynamic>> inferenceImageFileIsolate(
    String imagePath,
  ) async {
    // ⚠️ Pastikan initHelper() sudah dipanggil sebelum ini

    final isolateModel = InferenceModel(
      modelPath: _modelPath,
      imagePath: imagePath,
      labels: _foodLabels,
      labelsLength: _foodLabels.length,
    );

    ReceivePort responsePort = ReceivePort();
    _isolateInference.sendPort.send(
      isolateModel..responsePort = responsePort.sendPort,
    );

    // Ambil hasil inferensi dari Isolate
    var results = await responsePort.first;
    return results as Map<String, dynamic>;
  }

  // 3. Close Isolate
  Future<void> close() async {
    await _isolateInference.close();
  }
}

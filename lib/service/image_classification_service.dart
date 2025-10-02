import 'dart:isolate';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:submission/service/firebase_ml_service.dart';
import 'package:submission/static/isolate_inference.dart';

class ImageClassificationService {
  final FirebaseMLService _firebaseMLService = FirebaseMLService();
  final IsolateInference _isolateInference = IsolateInference();

  late final List<String> _foodLabels;
  late bool _isLabelsLoaded = false;
  late String _modelPath;

  Future<void> initHelper() async {
    if (!_isLabelsLoaded) await _loadLabels();

    final modelFile = await _firebaseMLService.loadModel();
    if (modelFile != null) {
      _modelPath = modelFile.path;
    }

    await _isolateInference.start();
  }

  Future<void> _loadLabels() async {
    final labelsTxt = await rootBundle.loadString('assets/labels.txt');
    final allLabels = labelsTxt.split('\n').where((s) => s.isNotEmpty).toList();
    _foodLabels = allLabels.sublist(1); // Mengabaikan __background__
    _isLabelsLoaded = true;
  }

  Future<Map<String, dynamic>> inferenceImageFileIsolate(
    String imagePath,
  ) async {
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

    final results = await responsePort.first;
    return results as Map<String, dynamic>;
  }

  Future<void> close() async {
    await _isolateInference.close();
  }
}

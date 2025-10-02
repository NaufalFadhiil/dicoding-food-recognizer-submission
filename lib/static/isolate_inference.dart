import 'dart:isolate';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class InferenceModel {
  final String modelPath;
  final String imagePath;
  final List<String> labels;
  final int labelsLength;
  SendPort? responsePort;

  InferenceModel({
    required this.modelPath,
    required this.imagePath,
    required this.labels,
    required this.labelsLength,
    this.responsePort,
  });
}

class IsolateInference {
  late Isolate _isolate;
  late SendPort sendPort;
  final _port = ReceivePort();

  Future<void> start() async {
    _isolate = await Isolate.spawn(_entryPoint, _port.sendPort);
    sendPort = await _port.first as SendPort;
  }

  Future<void> close() async {
    _isolate.kill(priority: Isolate.immediate);
  }

  static Future<void> _entryPoint(SendPort mainSendPort) async {
    final port = ReceivePort();
    mainSendPort.send(port.sendPort);

    await for (var message in port) {
      if (message is InferenceModel) {
        final result = await _runInference(message);
        message.responsePort?.send(result);
      }
    }
  }

  static Future<Map<String, dynamic>> _runInference(
    InferenceModel model,
  ) async {
    final interpreter = await Interpreter.fromFile(File(model.modelPath));

    final rawImage = File(model.imagePath).readAsBytesSync();
    final image = img.decodeImage(rawImage);
    if (image == null) {
      interpreter.close();
      return {'foodName': "Tidak Terdeteksi", 'confidence': 0.0};
    }

    final resized = img.copyResize(image, width: 192, height: 192);
    final imageBytes = resized.getBytes(format: img.Format.rgb);

    final input = imageBytes.reshape([1, 192, 192, 3]);

    final output = List.filled(
      model.labelsLength + 1,
      0,
    ).reshape([1, model.labelsLength + 1]);

    try {
      interpreter.run(input, output);
    } catch (e) {
      interpreter.close();
      return {'foodName': "Error", 'confidence': 0.0, 'error': e.toString()};
    }
    interpreter.close();

    final scores = output[0];
    double maxConfidence = 0.0;
    int maxIndex = -1;

    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > maxConfidence) {
        maxConfidence = scores[i].toDouble();
        maxIndex = i - 1;
      }
    }

    final foodName =
        (maxIndex != -1) ? model.labels[maxIndex] : "Tidak Terdeteksi";

    final normalizedConfidence = maxConfidence / 255.0;

    return {'foodName': foodName, 'confidence': normalizedConfidence};
  }
}

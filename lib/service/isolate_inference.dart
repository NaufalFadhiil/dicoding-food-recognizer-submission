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

    // Baca gambar
    final rawImage = File(model.imagePath).readAsBytesSync();
    final image = img.decodeImage(rawImage);
    if (image == null) {
      return {'foodName': "Tidak Terdeteksi", 'confidence': 0.0};
    }
    final resized = img.copyResize(image, width: 224, height: 224);

    // Normalisasi input [1, 224, 224, 3]
    var input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) => List.generate(3, (c) {
            final pixel = resized.getPixel(x, y);
            if (c == 0) return pixel.r / 255.0;
            if (c == 1) return pixel.g / 255.0;
            return pixel.b / 255.0;
          }),
        ),
      ),
    );

    var output = List.filled(
      model.labelsLength,
      0.0,
    ).reshape([1, model.labelsLength]);

    interpreter.run(input, output);

    final confidences = output[0] as List<double>;

    int maxIndex = 0;
    double maxConfidence = confidences[0];
    for (int i = 1; i < confidences.length; i++) {
      if (confidences[i] > maxConfidence) {
        maxConfidence = confidences[i];
        maxIndex = i;
      }
    }

    final foodName =
        (maxIndex != -1) ? model.labels[maxIndex] : "Tidak Terdeteksi";

    return {'foodName': foodName, 'confidence': maxConfidence};
  }
}

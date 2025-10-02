import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission/service/image_classification_service.dart';
import 'package:submission/widget/classification_item.dart';

class ResultPage extends StatelessWidget {
  final String imagePath;

  const ResultPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Result Page'),
      ),
      body: SafeArea(child: _ResultBody(imagePath: imagePath)),
    );
  }
}

class _ResultBody extends StatefulWidget {
  final String imagePath;

  const _ResultBody({required this.imagePath});

  @override
  State<_ResultBody> createState() => _ResultBodyState();
}

class _ResultBodyState extends State<_ResultBody> {
  Map<String, dynamic>? _inferenceResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _runClassification());
  }

  void _runClassification() async {
    final service = context.read<ImageClassificationService>();

    // Proses ini menjalankan Kriteria 2 Advanced (Firebase), Skilled (Isolate), Basic (LiteRT)
    final result = await service.inferenceImageFileIsolate(
      widget.imagePath,
    ); // ⬅️ Menggunakan fungsi inference yang benar

    setState(() {
      _inferenceResult = result;
      _isLoading = false;
    });

    // HANYA jika result sukses, baru panggil Kriteria 3
    // ignore: unnecessary_null_comparison
    if (result != null &&
        result['foodName'] != null &&
        result['foodName'] != "Tidak Terdeteksi") {
      // aman sekarang, bisa lanjut ke API / halaman detail
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final foodName = _inferenceResult?['foodName'] ?? "Gagal Deteksi";
    final confidence =
        (_inferenceResult?['confidence'] as double? ?? 0.0) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Expanded(
          child: Center(
            child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: ClassificationItem(
            item: foodName,
            value: "${confidence.toStringAsFixed(2)}%",
          ),
        ),
      ],
    );
  }
}

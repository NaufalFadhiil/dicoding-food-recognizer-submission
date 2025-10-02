import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:submission/service/image_service.dart';
import 'package:submission/ui/result_page.dart';

class HomeController extends ChangeNotifier {
  final ImageService _imageService = ImageService();
  String? _imagePath;
  String? get imagePath => _imagePath;

  // Tambahkan state untuk loading, agar tombol Analyze bisa di-disable
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Fungsi untuk memilih gambar dari galeri/kamera
  Future<void> pickAndCropImage(
    BuildContext context,
    ImageSource source,
  ) async {
    _setLoading(true);
    _imagePath = await _imageService.pickImage(source);
    if (_imagePath != null) {
      // Gambar berhasil diambil dan di-crop, tampilkan di UI
      // (Kita akan update HomePage agar bisa menampilkan gambar ini)
      notifyListeners();
    }
    _setLoading(false);
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
      // Tampilkan pesan error jika belum ada gambar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar terlebih dahulu!')),
      );
    }
  }

  // TODO: Tambahkan logic untuk Camera Feed (Kriteria 1 Advanced)
}

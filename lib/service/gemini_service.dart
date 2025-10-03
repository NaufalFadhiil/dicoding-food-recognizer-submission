import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:submission/model/nutrition.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY tidak ditemukan di file .env. Pastikan dotenv.load() sudah dipanggil di main.dart.',
      );
    }

    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  }

  Future<Nutrition?> getNutritionInfo(String foodName) async {
    final prompt = """
Kamu adalah sistem yang hanya menjawab dalam JSON valid.
Jangan sertakan penjelasan, teks tambahan, atau tanda ```.

Respon harus berbentuk seperti contoh ini:
{
  "Kalori": "250",
  "Karbohidrat": "30g",
  "Lemak": "10g",
  "Serat": "2g",
  "Protein": "15g"
}

Nama makanan: $foodName
""";

    try {
      final response = await _model.generateContent(
        [Content.text(prompt)],
        generationConfig: GenerationConfig(
          responseMimeType: "application/json",
        ),
      );

      final rawText = response.text?.trim();

      if (rawText == null || rawText.isEmpty) return null;

      return nutritionFromJson(rawText);
    } catch (e) {
      return null;
    }
  }
}

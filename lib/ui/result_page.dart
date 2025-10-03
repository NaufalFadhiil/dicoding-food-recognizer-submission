import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission/model/meal.dart';
import 'package:submission/model/nutrition.dart';
import 'package:submission/service/gemini_service.dart';
import 'package:submission/service/image_classification_service.dart';
import 'package:submission/service/meal_db_service.dart';
import 'package:submission/widget/meal_card.dart';
import 'package:submission/widget/nutrition_card.dart';
import 'package:submission/widget/error_message.dart';

class ResultPage extends StatelessWidget {
  final String imagePath;

  const ResultPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Result Page'),
        centerTitle: true,
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
  Meal? _mealDetails;
  Nutrition? _nutritionDetails;

  late final MealDBService _mealDBService;
  late final GeminiService _geminiService;

  @override
  void initState() {
    super.initState();
    _mealDBService = MealDBService();
    _geminiService = GeminiService();
    Future.microtask(() => _runClassificationAndFetchRecipe());
  }

  void _runClassificationAndFetchRecipe() async {
    final service = context.read<ImageClassificationService>();
    final result = await service.inferenceImageFileIsolate(widget.imagePath);
    final foodName = result['foodName'];

    Meal? meal;
    Nutrition? nutrition;

    if (foodName != null &&
        foodName != "Tidak Terdeteksi" &&
        foodName.isNotEmpty) {
      meal = await _mealDBService.searchMealByName(foodName);
      nutrition = await _geminiService.getNutritionInfo(foodName);
    }

    setState(() {
      _mealDetails = meal;
      _nutritionDetails = nutrition;
      _inferenceResult = result;
      _isLoading = false;
    });
  }

  List<Widget> _buildIngredientsAndMeasures(Meal meal) {
    return meal.ingredients.isNotEmpty
        ? List.generate(meal.ingredients.length, (i) {
          final ingredient = meal.ingredients[i];
          final measure =
              (i < meal.measures.length && meal.measures[i].isNotEmpty)
                  ? meal.measures[i]
                  : 'jumlah tidak diketahui';
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text('• $ingredient (${measure.trim()})'),
          );
        })
        : [const Text('Informasi bahan tidak tersedia.')];
  }

  Widget _buildNutritionRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value ?? 'N/A'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final foodName = _inferenceResult?['foodName'] ?? "Gagal Deteksi";
    final confidence =
        (_inferenceResult?['confidence'] as double? ?? 0.0) * 100;

    final Meal? meal = _mealDetails;
    final Nutrition? nutrition = _nutritionDetails;

    final bool hasMealData = meal != null;
    final bool hasNutritionData = nutrition != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(widget.imagePath),
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                foodName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${confidence.toStringAsFixed(2)}%",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(thickness: 0.5, height: 32),

          MealCard(
            meal: _mealDetails,
            buildIngredients: _buildIngredientsAndMeasures,
          ),

          NutritionCard(
            nutrition: _nutritionDetails,
            buildRow: _buildNutritionRow,
          ),

          if (!hasMealData && !hasNutritionData)
            const ErrorMessage(
              message:
                  'Detail resep dan nutrisi tidak ditemukan untuk makanan ini.',
            ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

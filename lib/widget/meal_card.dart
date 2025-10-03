import 'package:flutter/material.dart';
import 'package:submission/model/meal.dart';
import 'package:submission/widget/error_message.dart';

class MealCard extends StatelessWidget {
  final Meal? meal;
  final List<Widget> Function(Meal meal) buildIngredients;

  const MealCard({
    super.key,
    required this.meal,
    required this.buildIngredients,
  });

  @override
  Widget build(BuildContext context) {
    if (meal == null) {
      return const ErrorMessage(
        message: 'Detail resep dan langkah-langkah tidak tersedia.',
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Resep: ${meal!.strMeal}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (meal!.strMealThumb.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  meal!.strMealThumb,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text('Bahan-bahan:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...buildIngredients(meal!),
            const SizedBox(height: 16),
            Text(
              'Langkah-langkah:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              meal!.strInstructions.isNotEmpty
                  ? meal!.strInstructions
                  : 'Langkah instruksi tidak tersedia.',
            ),
          ],
        ),
      ),
    );
  }
}

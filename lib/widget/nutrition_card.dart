import 'package:flutter/material.dart';
import 'package:submission/model/nutrition.dart';

class NutritionCard extends StatelessWidget {
  final Nutrition? nutrition;
  final Widget Function(String, String?) buildRow;

  const NutritionCard({
    super.key,
    required this.nutrition,
    required this.buildRow,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
            nutrition != null
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Nutrisi (Gemini API)',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    buildRow('Kalori', nutrition!.kalori),
                    buildRow('Karbohidrat', nutrition!.karbohidrat),
                    buildRow('Lemak', nutrition!.lemak),
                    buildRow('Serat', nutrition!.serat),
                    buildRow('Protein', nutrition!.protein),
                  ],
                )
                : const Text('Data nutrisi tidak tersedia.'),
      ),
    );
  }
}

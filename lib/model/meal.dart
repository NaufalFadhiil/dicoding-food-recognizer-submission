import 'dart:convert';

MealsResponse mealsResponseFromJson(String str) =>
    MealsResponse.fromJson(json.decode(str));

class MealsResponse {
  final List<Meal> meals;

  MealsResponse({required this.meals});

  factory MealsResponse.fromJson(Map<String, dynamic> json) {
    final rawMeals = json['meals'];
    return MealsResponse(
      meals:
          rawMeals == null
              ? []
              : (rawMeals as List)
                  .map((e) => Meal.fromJson(e as Map<String, dynamic>))
                  .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'meals': meals.map((e) => e.toJson()).toList(),
  };
}

class Meal {
  final String idMeal;
  final String strMeal;
  final String strCategory;
  final String strArea;
  final String strInstructions;
  final String strMealThumb;

  final String? strMealAlternate;
  final String? strTags;
  final String? strYoutube;

  final List<String> ingredients;
  final List<String> measures;

  Meal({
    required this.idMeal,
    required this.strMeal,
    this.strMealAlternate,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strMealThumb,
    this.strTags,
    this.strYoutube,
    required this.ingredients,
    required this.measures,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    final ingredients = <String>[];
    final measures = <String>[];

    for (int i = 1; i <= 20; i++) {
      final ing = json['strIngredient$i'] as String?;
      final meas = json['strMeasure$i'] as String?;

      if (ing != null && ing.trim().isNotEmpty) {
        ingredients.add(ing.trim());
      }

      if (meas != null && meas.trim().isNotEmpty) {
        measures.add(meas.trim());
      }
    }

    return Meal(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strMealAlternate: json['strMealAlternate'],
      strCategory: json['strCategory'] ?? '',
      strArea: json['strArea'] ?? '',
      strInstructions: json['strInstructions'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
      strTags: json['strTags'],
      strYoutube: json['strYoutube'],
      ingredients: ingredients,
      measures: measures,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'idMeal': idMeal,
      'strMeal': strMeal,
      'strCategory': strCategory,
      'strInstructions': strInstructions,
      'strMealThumb': strMealThumb,
    };
    return data;
  }
}

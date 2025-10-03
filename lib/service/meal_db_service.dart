import 'package:http/http.dart' as http;
import 'package:submission/model/meal.dart';

class MealDBService {
  static const String _baseUrl = 'themealdb.com';

  Future<Meal?> searchMealByName(String foodName) async {
    final cleanName = foodName.trim().replaceAll(' ', '_');

    final uri = Uri.https(_baseUrl, 'api/json/v1/1/search.php', {
      's': cleanName,
    });

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final mealsResponse = mealsResponseFromJson(response.body);

        if (mealsResponse.meals.isNotEmpty) {
          return mealsResponse.meals.first;
        } else {
          return null;
        }
      } else {
        throw Exception(
          'Failed to load meal data. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      return null;
    }
  }
}

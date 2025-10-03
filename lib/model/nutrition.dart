import 'dart:convert';

Nutrition nutritionFromJson(String str) => Nutrition.fromJson(json.decode(str));

class Nutrition {
  String? kalori;
  String? karbohidrat;
  String? lemak;
  String? serat;
  String? protein;

  Nutrition({
    this.kalori,
    this.karbohidrat,
    this.lemak,
    this.serat,
    this.protein,
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) => Nutrition(
    kalori: json["Kalori"],
    karbohidrat: json["Karbohidrat"],
    lemak: json["Lemak"],
    serat: json["Serat"],
    protein: json["Protein"],
  );

  Map<String, dynamic> toJson() => {
    "Kalori": kalori,
    "Karbohidrat": karbohidrat,
    "Lemak": lemak,
    "Serat": serat,
    "Protein": protein,
  };
}

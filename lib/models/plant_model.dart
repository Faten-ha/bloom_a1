class Plant {
  final String name;
  final String description;
  final String light;
  final String temperature;
  final String summer;
  final String winter;
  final String soil;
  final String fertilization;
  final String benefits;
  final String warning;

  Plant({
    required this.name,
    required this.description,
    required this.light,
    required this.temperature,
    required this.summer,
    required this.winter,
    required this.soil,
    required this.fertilization,
    required this.benefits,
    required this.warning,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      light: json['light'] ?? '',
      temperature: json['temperature'] ?? '',
      summer: json['summer'] ?? '',
      winter: json['winter'] ?? '',
      soil: json['soil'] ?? '',
      fertilization: json['fertilization'] ?? '',
      benefits: json['benefits'] ?? '',
      warning: json['warning'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'light': light,
      'temperature': temperature,
      'summer': summer,
      'winter': winter,
      'soil': soil,
      'fertilization': fertilization,
      'benefits': benefits,
      'warning': warning,
    };
  }

  static Map<int, Plant> fromJsonMap(Map<String, dynamic> jsonMap) {
    return jsonMap
        .map((key, value) => MapEntry(int.parse(key), Plant.fromJson(value)));
  }
}

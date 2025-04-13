class PlantTable {
  final int? id;
  final int userId;
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
  final String imageUrl;

  PlantTable({
    this.id,
    required this.userId,
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
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
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
      'imageUrl': imageUrl,
    };
  }

  factory PlantTable.fromMap(Map<String, dynamic> map) {
    return PlantTable(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      description: map['description'],
      light: map['light'],
      temperature: map['temperature'],
      summer: map['summer'],
      winter: map['winter'],
      soil: map['soil'],
      fertilization: map['fertilization'],
      benefits: map['benefits'],
      warning: map['warning'],
      imageUrl: map['imageUrl'],
    );
  }
}

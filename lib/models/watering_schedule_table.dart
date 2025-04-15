class WateringScheduleTable {
  int? id;
  int plantId; // Foreign key to the plant
  String frequency; // e.g., "Daily", "Every 2 days"
  String day; // e.g., "Monday, Wednesday, Friday"

  WateringScheduleTable({
    this.id,
    required this.plantId,
    required this.frequency,
    required this.day,
  });

  // Convert a WateringSchedule into a Map.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'plantId': plantId,
      'frequency': frequency,
      'day': day,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  // Extract a WateringSchedule from a Map.
  factory WateringScheduleTable.fromMap(Map<String, dynamic> map) {
    return WateringScheduleTable(
      id: map['id'],
      plantId: map['plantId'],
      frequency: map['frequency'],
      day: map['day'],
    );
  }
}

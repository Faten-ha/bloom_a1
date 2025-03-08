import 'package:flutter/material.dart';
import 'home_screen.dart';

class WateringScheduleScreen extends StatefulWidget {
  const WateringScheduleScreen({super.key});

  @override
  State<WateringScheduleScreen> createState() => _WateringScheduleScreenState();
}

class _WateringScheduleScreenState extends State<WateringScheduleScreen> {
  int _selectedPlantIndex = 0;
  final List<String> _plantNames = ["كالاتيا زيبريتا", "بوتوس الذهبي"];
  Map<String, DateTime> lastWatered = {};
  Map<String, List<DateTime>> wateringSchedule = {};

  void _setLastWatered(DateTime date) {
    String plant = _plantNames[_selectedPlantIndex];
    setState(() {
      lastWatered[plant] = date;
      _generateWateringSchedule(plant);
    });
  }

  void _generateWateringSchedule(String plant) {
    DateTime startDate = lastWatered[plant] ?? DateTime.now();
    List<DateTime> schedule = [];
    for (int i = 1; i <= 30; i += 3) {
      schedule.add(startDate.add(Duration(days: i)));
    }
    wateringSchedule[plant] = schedule;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFA9A9A9),
              Color(0xFF577363),
              Color(0xFF063D1D),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF204D32)),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                      );
                    },
                  ),
                  const Text(
                    "جدول الري",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF204D32),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_plantNames.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedPlantIndex == index
                              ? const Color(0xFF204D32) // استخدام اللون المطلوب
                              : const Color(0xFFDCE3C6),
                          foregroundColor: _selectedPlantIndex == index
                              ? Colors.white
                              : Colors.black,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedPlantIndex = index;
                          });
                        },
                        child: Text(
                          _plantNames[index],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF204D32), // استخدام اللون المطلوب
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2024, 1, 1),
                    lastDate: DateTime(2025, 12, 31),
                  );
                  if (pickedDate != null) {
                    _setLastWatered(pickedDate);
                  }
                },
                child: const Text("تحديد آخر يوم ري"),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: _buildCalendar(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    List<String> daysOfWeek = [
      "السبت",
      "الأحد",
      "الاثنين",
      "الثلاثاء",
      "الأربعاء",
      "الخميس",
      "الجمعة"
    ];
    List<int> daysInMonth = List.generate(31, (index) => index + 1);
    String plant = _plantNames[_selectedPlantIndex];
    List<DateTime>? schedule = wateringSchedule[plant];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: TextDirection.rtl,
          children: daysOfWeek.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: daysInMonth.length,
              itemBuilder: (context, index) {
                bool isWateringDay =
                    schedule?.any((date) => date.day == daysInMonth[index]) ??
                        false;
                return Container(
                  decoration: BoxDecoration(
                    color: isWateringDay
                        ? const Color(0xFF204D32) // استخدام اللون المطلوب
                        : const Color(0xFFDCE3C6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      daysInMonth[index].toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isWateringDay ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

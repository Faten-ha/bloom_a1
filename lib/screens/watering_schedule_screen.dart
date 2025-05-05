import 'package:bloom_a1/controller/plant_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../controller/auth_controller.dart';
import '../controller/watering_schedule_controller.dart';
import '../models/watering_schedule_table.dart';
import '../services/notification_service.dart';
import 'home_screen.dart';

class WateringScheduleScreen extends StatefulWidget {
  const WateringScheduleScreen({super.key});

  @override
  State<WateringScheduleScreen> createState() => _WateringScheduleScreenState();
}

class _WateringScheduleScreenState extends State<WateringScheduleScreen>
    with SingleTickerProviderStateMixin {
  final PlantController _plantController = Get.find();
  final WateringScheduleController _sController =
      Get.put(WateringScheduleController());

  int _selectedPlantIndex = 0;
  List<String> _plantNames = [];

  Map<String, DateTime> lastWatered = {};
  Map<String, List<DateTime>> wateringSchedule = {};

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  late AnimationController _animationController;

  final Map<String, List<String>> voiceCommands = {
    'select_plant': [
      'اختر نبات',
      'اختيار',
      'غير النبات',
      'نبات',
      'غير',
      'النبات رقم'
    ],
    'set_last_watered': [
      'تحديد آخر يوم',
      'آخر ري',
      'آخر سقي',
      'موعد الري',
      'تاريخ الري'
    ],
    'home': [
      'رئيسية',
      'العودة',
      'ارجع',
      'رجوع',
      'رجع',
      'الصفحة الرئيسية',
      'البداية'
    ],
    'help': ['مساعدة', 'المساعدة', 'الأوامر', 'ماذا يمكنني أن أقول', 'أوامر']
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
          _animationController.stop();
        }
      },
      onError: (errorNotification) {
        setState(() => _isListening = false);
        _animationController.stop();
        if (mounted) {
          _showSnackbar("حدث خطأ في التعرف على الصوت");
        }
      },
    );
  }

  void _startListening() async {
    if (!_isListening) {
      _recognizedText = '';
      setState(() => _isListening = true);
      _showSnackbar("جاري الاستماع... انطق أمرك");

      if (await _speech.initialize()) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          _speech.listen(
            localeId: "ar_SA",
            onResult: (result) {
              if (mounted) {
                setState(() {
                  _recognizedText = result.recognizedWords;
                });
                if (result.finalResult) {
                  _handleVoiceCommand(_recognizedText);
                }
              }
            },
            listenFor: const Duration(seconds: 10),
            pauseFor: const Duration(seconds: 3),
          );
          _animationController.repeat(reverse: true);
        }
      } else if (mounted) {
        setState(() => _isListening = false);
        _showSnackbar("التعرف على الكلام غير متاح!");
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      _animationController.stop();
      setState(() => _isListening = false);
    }
  }

  void _handleVoiceCommand(String command) {
    command = command.trim().toLowerCase();
    bool commandRecognized = false;
    RegExp numRegex = RegExp(r'(رقم|نبات|نباتة|اختر|اختيار|غير)\s*(\d+)|(\d+)');
    Match? match = numRegex.firstMatch(command);
    int? requestedIndex;

    if (match != null) {
      String? numStr = match.group(2) ?? match.group(3);
      if (numStr != null) {
        int? parsedIndex = int.tryParse(numStr);
        if (parsedIndex != null) {
          requestedIndex = parsedIndex - 1;
          if (requestedIndex >= 0 && requestedIndex < _plantNames.length) {
            setState(() {
              _selectedPlantIndex = requestedIndex!;
            });
            _showSnackbar("تم اختيار نبات ${_plantNames[requestedIndex]}");
            commandRecognized = true;
          } else {
            _showSnackbar("لا يوجد نبات بالرقم ${parsedIndex}");
          }
        }
      }
    }

    if (_hasKeyword(command, voiceCommands['select_plant']!) &&
        !commandRecognized) {
      _showPlantSelectionDialog();
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['set_last_watered']!)) {
      _showDatePicker();
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['home']!)) {
      Get.offAll(() => HomeScreen());
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['help']!)) {
      _showHelpScreen();
      commandRecognized = true;
    }

    if (!commandRecognized) {
      _showSnackbar(
          "لم يتم التعرف على الأمر. جرب: اختر نبات رقم 1 أو تحديد آخر يوم ري");
    }

    _stopListening();
  }

  void _showPlantSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("اختر نبات"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_plantNames.length, (index) {
              return ListTile(
                title: Text(_plantNames[index]),
                onTap: () {
                  setState(() {
                    _selectedPlantIndex = index;
                  });
                  Navigator.of(context).pop();
                  _showSnackbar("تم اختيار نبات ${_plantNames[index]}");
                },
              );
            }),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showDatePicker() async {
    final DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate != null) {
      // إذا كان التاريخ المحدد في الماضي، نستخدم التاريخ الحالي
      final effectiveDate = pickedDate.isBefore(now) ? now : pickedDate;
      _setLastWatered(effectiveDate);
      _showSnackbar(
        "تم تحديد آخر يوم ري: ${effectiveDate.day}/${effectiveDate.month}/${effectiveDate.year}",
      );
    }
  }

  void _showHelpScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF577363),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(128),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "الأوامر الصوتية المتاحة",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.white24),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildHelpSection(
                    "اختيار نبات",
                    "قل: \"اختر نبات رقم 2\" أو \"غير النبات إلى 1\"",
                    Icons.eco,
                  ),
                  _buildHelpSection(
                    "تحديد آخر يوم ري",
                    "قل: \"تحديد آخر يوم ري\" أو \"آخر سقي\"",
                    Icons.water_drop,
                  ),
                  _buildHelpSection(
                    "العودة للصفحة الرئيسية",
                    "قل: \"الرئيسية\" أو \"العودة\" أو \"رجوع\"",
                    Icons.home,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF204D32),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "حسنا",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF204D32),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasKeyword(String text, List<String> keywords) {
    text = text.trim().toLowerCase();
    for (var keyword in keywords) {
      if (text == keyword || text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF204D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _setLastWatered(DateTime date) {
    String plant = _plantNames[_selectedPlantIndex];
    setState(() {
      lastWatered[plant] = date;
      _generateWateringSchedule(plant);
    });
  }

  Future<void> _generateWateringSchedule(String plant) async {
    final plantSchedule = _plantController.plants[_selectedPlantIndex];
    DateTime startDate = lastWatered[plant] ?? DateTime.now();

    // تأكد من أن تاريخ البداية ليس في الماضي
    if (startDate.isBefore(DateTime.now())) {
      startDate = DateTime.now();
    }

    List<DateTime> schedule = [];
    int waterDay = 0;

    if (_plantController.currentSeason.value == "الشتاء") {
      waterDay = (30 / double.parse(plantSchedule.winter)).round();
    } else if (_plantController.currentSeason.value == "الصيف") {
      waterDay = (30 / double.parse(plantSchedule.summer)).round();
    }

    // تأكد من أن waterDay ليس صفرًا لتجنب القسمة على صفر
    waterDay = waterDay > 0 ? waterDay : 7; // قيمة افتراضية إذا كانت صفر

    for (int i = 1; i <= 30; i += waterDay) {
      DateTime nextDate = startDate.add(Duration(days: i));
      // تأكد من أن التاريخ في المستقبل
      if (nextDate.isAfter(DateTime.now())) {
        schedule.add(nextDate);
      }
    }

    wateringSchedule[plant] = schedule;

    try {
      if (_sController.wateringSchedules.isNotEmpty) {
        await _sController.deleteSchedule(plantSchedule.id!);
      }

      for (int i = 0; i < schedule.length; i++) {
        await _sController.addSchedule(
          WateringScheduleTable(
            plantId: plantSchedule.id!,
            frequency: waterDay.toString(),
            day: schedule[i].day.toString(),
          ),
        );

        await _scheduleWateringNotification(
          plantName: plant,
          scheduledDate: schedule[i],
          i: i*10

        );
      }
    } catch (e) {
      print("خطأ في إنشاء جدول الري: $e");
      _showSnackbar("حدث خطأ أثناء إنشاء جدول الري");
    }
  }

  Future<void> _scheduleWateringNotification({
    required String plantName,
    required DateTime scheduledDate,
    required int i
  }) async {
    final now = DateTime.now();

    // إذا كان التاريخ في الماضي، لا تقم بجدولة الإشعار
    if (scheduledDate.isBefore(now)) {
      print("لا يمكن جدولة إشعار بتاريخ قديم: $scheduledDate");
      return;
    }

    final notificationId = scheduledDate.hashCode;
    String message = "حان وقت ري نبات $plantName اليوم";
    String title = "موعد ري النبات";

    try {
      await NotificationService.scheduleNotification(
        id: notificationId,
        title: title,
        body: message,
        date: DateTime.now().add(Duration(seconds: i+1)),
      );
      print("تم جدولة إشعار لـ $plantName في $scheduledDate");
    } catch (e) {
      print("فشل جدولة الإشعار: $e");
      if (mounted) {
        _showSnackbar("فشل في جدولة إشعار الري");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_plantController.plants.isEmpty) {
      _plantController.loadPlants();
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFA9A9A9),
            Color(0xFF577363),
            Color(0xFF063D1D),
          ],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF063D1D),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF204D32)),
            onPressed: () {
              Get.offAll(() => HomeScreen());
            },
          ),
          title: Center(
            child: Text(
              "جدول الري",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF063D1D),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: Color(0xFF204D32)),
              onPressed: _showHelpScreen,
              tooltip: 'مساعدة الأوامر الصوتية',
            ),
          ],
        ),
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3C1E),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.account_circle, size: 80, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      "مرحبًا بك",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text("مشاركة رابط الحساب"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("تسجيل خروج"),
                onTap: () {
                  AuthController auth = Get.find();
                  auth.logout();
                },
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            if (_plantController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (_plantController.plants.isEmpty) {
              return const Center(
                child: Text("لا يوجد نباتات بعد"),
              );
            }

            _plantNames = _plantController.plants.map((plant) {
              return plant.name;
            }).toList();

            _sController.loadSchedules(
              _plantController.plants[_selectedPlantIndex].id!,
            );

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: List.generate(_plantNames.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedPlantIndex == index
                                  ? const Color(0xFF204D32)
                                  : const Color(0xFFDCE3C6),
                              foregroundColor: _selectedPlantIndex == index
                                  ? Colors.white
                                  : Colors.black,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedPlantIndex = index;
                              });
                            },
                            child: Row(
                              children: [
                                Text(
                                  _plantNames[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(76),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${index + 1}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedPlantIndex == index
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF204D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _showDatePicker,
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
            );
          }),
        ),
        floatingActionButton: Stack(
          children: [
            FloatingActionButton(
              onPressed: _startListening,
              backgroundColor: _isListening
                  ? const Color(0xFF204D32)
                  : const Color(0xFFDCE3C6),
              child: Icon(
                Icons.mic,
                color: _isListening ? Colors.white : Colors.black,
              ),
            ),
            if (_isListening)
              const Positioned.fill(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomSheet: _isListening
            ? Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                color: const Color(0xFF204D32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _recognizedText.isNotEmpty
                          ? "التعرف على: $_recognizedText"
                          : "جاري الاستماع...",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _stopListening,
                          child: const Text(
                            "إلغاء",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: _showHelpScreen,
                          child: const Text(
                            "مساعدة",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : null,
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
      "الجمعة",
    ];
    List<int> daysInMonth = List.generate(30, (index) => index + 1);

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
          child: Obx(() {
            if (_sController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final schedules = _sController.wateringSchedules;
            return Directionality(
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
                  final day = daysInMonth[index];
                  final isWateringDay =
                      schedules.any((s) => int.tryParse(s.day) == day);

                  return Container(
                    decoration: BoxDecoration(
                      color: isWateringDay
                          ? const Color(0xFF204D32)
                          : const Color(0xFFDCE3C6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        day.toString(),
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
            );
          }),
        ),
      ],
    );
  }
}

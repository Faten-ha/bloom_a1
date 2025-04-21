import 'dart:io';
import 'package:bloom_a1/screens/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../controller/plant_controller.dart';
import 'plant_details_screen.dart';
import 'watering_schedule_screen.dart';
import 'home_screen.dart';

class MyPlantsScreen extends StatefulWidget {
  const MyPlantsScreen({super.key});

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen>
    with SingleTickerProviderStateMixin {
  PlantController plantController = Get.find<PlantController>();
  String searchText = '';
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? selectedPlantIndex;

  // تعريف الأوامر الصوتية بطريقة مباشرة وأكثر وضوحًا
  final Map<String, List<String>> voiceCommands = {
    'water': [
      'ري',
      'سقي',
      'ماء',
      'مويه',
      'ماي',
      'اضف للري',
      'جدول',
      'اسقي',
      'اضف إلى جدول الري',
      'أضف الى جدول الري',
      'جدول الري',
      'إضافة للري',
      'إضافة إلى جدول الري'
    ],
    'details': ['تفاصيل', 'معلومات', 'شرح', 'عرض', 'وصف', 'افتح'],
    'delete': ['حذف', 'ازالة', 'شيل', 'مسح', 'امسح'],
    'add': [
      'اضف',
      'اضافة',
      'ضيف',
      'جديد',
      'زود',
      'انشاء',
      'انشئ',
      'إنشاء',
      'كاميرا'
    ],
    'plant': ['نبات', 'نبتة', 'شجرة', 'نباتات', 'زرع', 'زراعة', 'شتلة'],
    'home': [
      'رئيسية',
      'العودة',
      'ارجع',
      'رجوع',
      'رجع',
      'الصفحة الرئيسية',
      'البداية'
    ],
    'search': ['بحث', 'ابحث', 'دور'],
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
    plantController.loadPlants();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
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
        debugPrint("Speech status: $status");
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
          _animationController.stop();
        }
      },
      onError: (errorNotification) {
        debugPrint("Speech error: ${errorNotification.errorMsg}");
        setState(() => _isListening = false);
        _animationController.stop();
        if (mounted) _showSnackbar("حدث خطأ في التعرف على الصوت");
      },
    );
  }

  void _startListening() async {
    if (!_isListening) {
      _recognizedText = '';
      setState(() => _isListening = true);
      _showVoiceCommandDialog();

      if (await _speech.initialize()) {
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          debugPrint("بدء الاستماع للأوامر...");
          _speech.listen(
            localeId: "ar_SA",
            onResult: (result) {
              if (mounted) {
                setState(() => _recognizedText = result.recognizedWords);
                debugPrint("نتيجة الاستماع: ${result.recognizedWords}");
                if (result.finalResult) {
                  debugPrint("النتيجة النهائية: ${result.recognizedWords}");
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
        Navigator.pop(context);
      }
    }
  }

  void _showVoiceCommandDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF577363),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "جاري الاستماع...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) => Transform.scale(
                  scale: _animation.value,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: _isListening
                          ? const Color(0xFFCDD4BA)
                          : const Color(0xFF2A543C),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mic,
                      size: 40,
                      color:
                          _isListening ? const Color(0xFF063D1D) : Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _recognizedText.isEmpty ? "انطق أمرك..." : _recognizedText,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                ":الأوامر المتاحة",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 12,
                children: [
                  _buildCommandButton("أضف إلى جدول الري", () {
                    Navigator.pop(context);
                    _navigateToWateringSchedule();
                  }),
                  _buildCommandButton("أضف نبات جديد", () {
                    Navigator.pop(context);
                    _addNewPlant();
                  }),
                  _buildCommandButton("العودة للرئيسية", () {
                    Navigator.pop(context);
                    _navigateToHomeScreen();
                  }),
                  _buildCommandButton("تفاصيل النبات", () {
                    Navigator.pop(context);
                    if (plantController.filteredPlants.isNotEmpty) {
                      showPlantDetails(selectedPlantIndex ?? 0);
                    } else {
                      _showSnackbar("لا توجد نباتات لعرض تفاصيلها");
                    }
                  }),
                  _buildCommandButton("ابحث عن نبات", () {
                    Navigator.pop(context);
                    FocusScope.of(context).requestFocus(FocusNode());
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showSnackbar("يمكنك البحث الآن");
                    });
                  }),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _stopListening();
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white24,
                  minimumSize: const Size(100, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "إلغاء",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) => _stopListening());
  }

  Widget _buildCommandButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2A543C),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  // تم تحسين دالة البحث عن الكلمات المفتاحية
  bool _hasKeyword(String text, List<String> keywords) {
    text = text.trim().toLowerCase();
    for (var keyword in keywords) {
      keyword = keyword.toLowerCase();
      if (text == keyword || text.contains(keyword)) {
        debugPrint("وجدت كلمة مفتاحية: $keyword");
        return true;
      }
    }
    return false;
  }

  void _handleVoiceCommand(String command) {
    debugPrint("معالجة الأمر: $command");
    command = command.trim().toLowerCase();
    bool commandRecognized = false;

    // تحديث المؤشر إذا كان الأمر يحتوي على رقم
    RegExp numRegex = RegExp(r'\d+');
    Match? match = numRegex.firstMatch(command);
    if (match != null) {
      int num = int.parse(match.group(0)!) - 1;
      if (num >= 0 && num < plantController.filteredPlants.length) {
        selectedPlantIndex = num;
        debugPrint("تم تحديد النبات رقم: ${num + 1}");
      }
    }

    // التحقق من أمر جدول الري - تمت معالجته أولاً للأهمية
    if (_hasKeyword(command, voiceCommands['water']!)) {
      debugPrint("تنفيذ أمر الري: $command");
      if (Navigator.canPop(context)) Navigator.pop(context);
      _navigateToWateringSchedule();
      commandRecognized = true;
    }
    // أمر إضافة نبات
    else if (_hasKeyword(command, voiceCommands['add']!)) {
      debugPrint("تنفيذ أمر إضافة نبات: $command");
      if (Navigator.canPop(context)) Navigator.pop(context);
      _addNewPlant();
      commandRecognized = true;
    }
    // أمر العودة للرئيسية
    else if (_hasKeyword(command, voiceCommands['home']!)) {
      debugPrint("تنفيذ أمر العودة للرئيسية: $command");
      if (Navigator.canPop(context)) Navigator.pop(context);
      _navigateToHomeScreen();
      commandRecognized = true;
    }
    // أمر عرض التفاصيل
    else if (_hasKeyword(command, voiceCommands['details']!)) {
      debugPrint("تنفيذ أمر التفاصيل: $command");
      if (Navigator.canPop(context)) Navigator.pop(context);
      if (plantController.filteredPlants.isEmpty) {
        _showSnackbar("لا توجد نباتات لعرض تفاصيلها");
      } else {
        showPlantDetails(selectedPlantIndex ?? 0);
      }
      commandRecognized = true;
    }
    // أمر الحذف
    else if (_hasKeyword(command, voiceCommands['delete']!)) {
      debugPrint("تنفيذ أمر الحذف: $command");
      if (Navigator.canPop(context)) Navigator.pop(context);
      if (plantController.filteredPlants.isEmpty) {
        _showSnackbar("لا توجد نباتات للحذف");
      } else if (selectedPlantIndex != null) {
        _deletePlant(selectedPlantIndex!);
      } else {
        _showSnackbar("الرجاء تحديد نبات للحذف أولاً");
      }
      commandRecognized = true;
    }
    // أمر البحث
    else if (_hasKeyword(command, voiceCommands['search']!)) {
      debugPrint("تنفيذ أمر البحث: $command");
      if (Navigator.canPop(context)) Navigator.pop(context);
      FocusScope.of(context).requestFocus(FocusNode());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackbar("يمكنك البحث الآن");
      });
      commandRecognized = true;
    }

    if (!commandRecognized) {
      debugPrint("لم يتم التعرف على الأمر: $command");
      if (Navigator.canPop(context)) Navigator.pop(context);
      _showSnackbar("لم يتم التعرف على الأمر");
    }

    _stopListening();
  }

  void _navigateToWateringSchedule() {
    debugPrint("الانتقال إلى جدول الري");
    // استخدم كلا الأسلوبين للتأكد من أن إحداهما سيعمل
    try {
      Get.to(() => WateringScheduleScreen());
    } catch (e) {
      debugPrint("خطأ في الانتقال باستخدام Get: $e");
      // استخدم الطريقة التقليدية إذا فشلت الطريقة الأولى
      if (mounted) {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => WateringScheduleScreen()));
      }
    }
  }

  void _navigateToHomeScreen() {
    debugPrint("العودة إلى الشاشة الرئيسية");
    Get.offAll(() => HomeScreen());
  }

  void _addNewPlant() {
    debugPrint("فتح شاشة إضافة نبات جديد");
    Get.to(() => CameraScreen());
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      _animationController.stop();
      setState(() => _isListening = false);
    }
  }

  void showPlantDetails(int index) {
    plantController.plantDetailsIndex.value = index;
    Get.to(() => PlantDetailsScreen());
  }

  Future<void> _deletePlant(int index) async {
    try {
      bool confirmDelete = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("تأكيد الحذف"),
              content: const Text("هل أنت متأكد من حذف هذا النبات؟"),
              actions: <Widget>[
                TextButton(
                  child: const Text("إلغاء"),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text("حذف", style: TextStyle(color: Colors.red)),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ) ??
          false;

      if (confirmDelete) {
        final plantToDelete = plantController.filteredPlants[index];
        final plantImage = File(plantToDelete.imageUrl);
        if (await plantImage.exists()) await plantImage.delete();
        await plantController.deletePlant(index, plantToDelete.id!);
        await plantController.loadPlants();
        if (mounted) {
          setState(() {});
          _showSnackbar("تم حذف النبتة بنجاح!");
        }
      }
    } catch (e) {
      debugPrint("Error deleting plant: $e");
      if (mounted) _showSnackbar("حدث خطأ أثناء حذف النبتة!");
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2A543C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF063D1D),
                        size: 24,
                      ),
                      onPressed: _navigateToHomeScreen,
                    ),
                    const Text(
                      "نبتاتي",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  textDirection: TextDirection.rtl,
                  onChanged: (value) {
                    searchText = value.trim();
                    plantController.filterPlants(searchText);
                  },
                  decoration: InputDecoration(
                    hintText: '...ابحث عن نبات',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: Colors.white24,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 10),
              Obx(() {
                if (plantController.filteredPlants.isEmpty) {
                  return const Center(
                    child: Text(
                      "لا يوجد نباتات بعد",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                if (plantController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: plantController.filteredPlants.length,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          selectedPlantIndex = index;
                          showPlantDetails(index);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF577363),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFCDD4BA),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag:
                                    'plant-image-${plantController.filteredPlants[index].name}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(
                                    width: 160,
                                    height: 140,
                                    fit: BoxFit.cover,
                                    File(plantController
                                        .filteredPlants[index].imageUrl),
                                    errorBuilder: (context, error,
                                            stackTrace) =>
                                        const Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        PopupMenuButton<String>(
                                          icon: const Icon(
                                            Icons.more_horiz,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                          onSelected: (value) {
                                            selectedPlantIndex = index;
                                            if (value == 'water') {
                                              _navigateToWateringSchedule();
                                            } else if (value == 'info') {
                                              showPlantDetails(index);
                                            } else if (value == 'delete') {
                                              _deletePlant(index);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'water',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.water_drop),
                                                  SizedBox(width: 8),
                                                  Text('إضافة للري'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'info',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.info_outline),
                                                  SizedBox(width: 8),
                                                  Text('تفاصيل'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete,
                                                      color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text('حذف',
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF2A543C),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  plantController.currentSeason
                                                              .value ==
                                                          "الشتاء"
                                                      ? "كل ${(30 / double.parse(plantController.filteredPlants[index].winter)).round()} ايام"
                                                      : "كل ${(30 / double.parse(plantController.filteredPlants[index].summer)).round()} ايام",
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                plantController
                                                    .filteredPlants[index].name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      textDirection: TextDirection.rtl,
                                      plantController
                                          .filteredPlants[index].description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                    const SizedBox(height: 15),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF2A543C),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 14),
                                          elevation: 2,
                                        ),
                                        onPressed: _navigateToWateringSchedule,
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "أضف إلى جدول الري",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(width: 5),
                                            Icon(Icons.water_drop,
                                                size: 18, color: Colors.white),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 12),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCDD4BA),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    elevation: 3,
                  ),
                  onPressed: _addNewPlant,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "إضافة نبات جديد",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.add, size: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            onPressed: _startListening,
            backgroundColor: const Color(0xFFCDD4BA),
            child: const Icon(Icons.mic, color: Colors.black),
          ),
          if (_isListening)
            Positioned.fill(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF063D1D)),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

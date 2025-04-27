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
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

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
      'جدول الري'
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
    'search': ['بحث', 'ابحث', 'دور', 'فتش'],
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
    plantController.loadPlants();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
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
        if (mounted) _showSnackbar("حدث خطأ في التعرف على الصوت");
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
                  _showCommandFeedback(_recognizedText);
                });
                if (result.finalResult) _handleVoiceCommand(_recognizedText);
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

  void _showCommandFeedback(String command) {
    if (_hasKeyword(command, voiceCommands['details']!)) {
      _animationController.forward(from: 0.0);
    } else if (_hasKeyword(command, voiceCommands['delete']!)) {
      _animationController.repeat(reverse: true);
    }
  }

  String _getCommandFeedback(String command) {
    if (_hasKeyword(command, voiceCommands['details']!)) {
      return "سيتم عرض تفاصيل النبتة المحددة";
    } else if (_hasKeyword(command, voiceCommands['delete']!)) {
      return "سيتم حذف النبتة المحددة";
    } else if (_hasKeyword(command, voiceCommands['water']!)) {
      return "سيتم إضافة النبتة لجدول الري";
    } else if (_hasKeyword(command, voiceCommands['add']!)) {
      return "سيتم فتح شاشة إضافة نبتة جديدة";
    }
    return "جاري معالجة الأمر...";
  }

  void _handleVoiceCommand(String command) {
    command = command.trim().toLowerCase();
    bool commandRecognized = false;

    RegExp numRegex = RegExp(
        r'(رقم|نبتة|نبات|حذف|تفاصيل|مسح|امسح|ازالة|شيل|عرض|معلومات)?\s*(\d+)|(\d+)');
    Match? match = numRegex.firstMatch(command);
    int? requestedIndex;

    if (match != null) {
      String? numStr = match.group(2) ?? match.group(3);
      if (numStr != null) {
        requestedIndex = int.parse(numStr) - 1;
        debugPrint("النص المعترف به: $command"); // طباعة النص المعترف به
        debugPrint("الرقم المستخرج: $requestedIndex"); // طباعة الرقم المستخرج

        if (requestedIndex >= 0 &&
            requestedIndex < plantController.filteredPlants.length) {
          selectedPlantIndex = requestedIndex;
          debugPrint("تم تحديد النبات رقم: ${requestedIndex + 1}");
        } else {
          _showSnackbar("لا يوجد نبات بالرقم ${requestedIndex + 1}");
          requestedIndex = null;
        }
      }
    }

    if (_hasKeyword(command, voiceCommands['details']!)) {
      if (plantController.filteredPlants.isEmpty) {
        _showSnackbar("لا توجد نباتات لعرض تفاصيلها");
      } else if (requestedIndex != null) {
        showPlantDetails(requestedIndex);
        _showSnackbar("عرض تفاصيل النبات رقم ${requestedIndex + 1}");
      } else if (selectedPlantIndex != null) {
        showPlantDetails(selectedPlantIndex!);
      } else {
        _showSnackbar("الرجاء تحديد نبات لعرض التفاصيل");
      }
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['delete']!)) {
      if (plantController.filteredPlants.isEmpty) {
        _showSnackbar("لا توجد نباتات للحذف");
      } else if (requestedIndex != null) {
        _showDeleteConfirmation(requestedIndex);
      } else if (selectedPlantIndex != null) {
        _showDeleteConfirmation(selectedPlantIndex!);
      } else {
        _showSnackbar(
            "الرجاء تحديد نبات للحذف أو ذكر رقمه مثل: حذف نبتة رقم 1");
      }
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['water']!)) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      _navigateToWateringSchedule();
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['add']!)) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      _addNewPlant();
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['home']!)) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      _navigateToHomeScreen();
      commandRecognized = true;
    } else if (_hasKeyword(command, voiceCommands['search']!)) {
      FocusScope.of(context).requestFocus(searchFocusNode);
      String searchQuery = "";
      for (var keyword in voiceCommands['search']!) {
        if (command.contains(keyword)) {
          searchQuery = command.replaceFirst(keyword, "").trim();
          break;
        }
      }
      searchQuery =
          searchQuery.replaceAll("عن", "").replaceAll("نبات", "").trim();
      if (searchQuery.isNotEmpty) {
        searchController.text = searchQuery;
        searchText = searchQuery;
        plantController.filterPlants(searchText);
        _showSnackbar("جاري البحث عن: $searchQuery");
      } else {
        _showSnackbar("يمكنك البحث الآن");
      }
      commandRecognized = true;
    }

    if (!commandRecognized) {
      _showSnackbar("لم يتم التعرف على الأمر. جرب: تفاصيل رقم 1 أو حذف رقم 2");
    }
    _stopListening();
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: Text("هل أنت متأكد من حذف النبتة رقم ${index + 1}؟"),
        actions: <Widget>[
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop(true);
              _deletePlant(index);
            },
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        _showSnackbar("تم حذف النبتة رقم ${index + 1} بنجاح");
      }
    });
  }

  void _navigateToWateringSchedule() {
    try {
      Get.to(() => WateringScheduleScreen());
    } catch (e) {
      if (mounted)
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => WateringScheduleScreen()));
    }
  }

  void _navigateToHomeScreen() => Get.offAll(() => HomeScreen());
  void _addNewPlant() => Get.to(() => CameraScreen());

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
      final plantToDelete = plantController.filteredPlants[index];
      final plantImage = File(plantToDelete.imageUrl);
      if (await plantImage.exists()) await plantImage.delete();
      await plantController.deletePlant(index, plantToDelete.id!);
      await plantController.loadPlants();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool _hasKeyword(String text, List<String> keywords) {
    text = text.trim().toLowerCase();
    for (var keyword in keywords)
      if (text == keyword || text.contains(keyword)) return true;
    return false;
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
                color: const Color(0xFF2A543C),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.right),
                const SizedBox(height: 3),
                Text(description,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                    textAlign: TextAlign.right),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF577363),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("الأوامر الصوتية المتاحة",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            const Divider(color: Colors.white24),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildHelpSection(
                      "إضافة نبات جديد",
                      "قل: \"أضف نبات جديد\" أو \"إضافة\" أو \"كاميرا\"",
                      Icons.add_photo_alternate),
                  _buildHelpSection(
                      "عرض تفاصيل النبات",
                      "قل: \"تفاصيل النبات رقم 2\" أو \"معلومات رقم 3\" أو \"افتح رقم 1\"",
                      Icons.info_outline),
                  _buildHelpSection(
                      "إضافة إلى جدول الري",
                      "قل: \"أضف إلى جدول الري\" أو \"سقي\" أو \"ري\"",
                      Icons.water_drop),
                  _buildHelpSection("العودة للصفحة الرئيسية",
                      "قل: \"الرئيسية\" أو \"العودة\" أو \"رجوع\"", Icons.home),
                  _buildHelpSection(
                      "البحث عن نبات",
                      "قل: \"ابحث عن نبات الصبار\" أو \"بحث عن نعناع\"",
                      Icons.search),
                  _buildHelpSection(
                      "حذف نبات",
                      "قل: \"حذف النبات رقم 1\" أو \"امسح النبتة رقم 2\" أو \"ازالة رقم 3\"",
                      Icons.delete),
                ],
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A543C),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("حسنا",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
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
            colors: [Color(0xFFA9A9A9), Color(0xFF577363), Color(0xFF063D1D)],
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
                      icon: const Icon(Icons.arrow_back,
                          color: Color(0xFF063D1D), size: 24),
                      onPressed: _navigateToHomeScreen,
                    ),
                    const Text("نبتاتي",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Row(
                      children: [
                        IconButton(
                            icon: const Icon(Icons.help_outline,
                                color: Colors.white),
                            onPressed: _showHelpScreen,
                            tooltip: "مساعدة الأوامر الصوتية"),
                        IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () => searchFocusNode.requestFocus()),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  focusNode: searchFocusNode,
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
                        borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 10),
              Obx(() {
                if (plantController.filteredPlants.isEmpty) {
                  return const Center(
                      child: Text("لا يوجد نباتات بعد",
                          style: TextStyle(color: Colors.white)));
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
                                  offset: const Offset(0, 2))
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
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
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                    Icons.image_not_supported),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                          color: Color(0xFF2A543C),
                                          shape: BoxShape.circle),
                                      child: Center(
                                          child: Text("${index + 1}",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14))),
                                    ),
                                  ),
                                ],
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
                                          icon: const Icon(Icons.more_horiz,
                                              color: Colors.white, size: 22),
                                          onSelected: (value) {
                                            selectedPlantIndex = index;
                                            if (value == 'water')
                                              _navigateToWateringSchedule();
                                            else if (value == 'info')
                                              showPlantDetails(index);
                                            else if (value == 'delete')
                                              _showDeleteConfirmation(index);
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                                value: 'water',
                                                child: Row(children: [
                                                  Icon(Icons.water_drop),
                                                  SizedBox(width: 8),
                                                  Text('إضافة للري')
                                                ])),
                                            const PopupMenuItem(
                                                value: 'info',
                                                child: Row(children: [
                                                  Icon(Icons.info_outline),
                                                  SizedBox(width: 8),
                                                  Text('تفاصيل')
                                                ])),
                                            const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(children: [
                                                  Icon(Icons.delete,
                                                      color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text('حذف',
                                                      style: TextStyle(
                                                          color: Colors.red))
                                                ])),
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
                                                        BorderRadius.circular(
                                                            12)),
                                                child: Text(
                                                  plantController.currentSeason
                                                              .value ==
                                                          "الشتاء"
                                                      ? "كل ${(30 / double.parse(plantController.filteredPlants[index].winter)).round()} ايام"
                                                      : "كل ${(30 / double.parse(plantController.filteredPlants[index].summer)).round()} ايام",
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                  plantController
                                                      .filteredPlants[index]
                                                      .name,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      plantController
                                          .filteredPlants[index].description,
                                      textDirection: TextDirection.rtl,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.white70),
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
                                                  BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 14),
                                          elevation: 2,
                                        ),
                                        onPressed: _navigateToWateringSchedule,
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("أضف إلى جدول الري",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold)),
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
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    elevation: 3,
                  ),
                  onPressed: _addNewPlant,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("إضافة نبات جديد",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
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
            backgroundColor: _isListening
                ? const Color(0xFF2A543C)
                : const Color(0xFFCDD4BA),
            child: Icon(Icons.mic,
                color: _isListening ? Colors.white : Colors.black),
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
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              color: const Color(0xFF2A543C),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _recognizedText.isNotEmpty
                        ? "التعرف على: $_recognizedText"
                        : "جاري الاستماع...",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  if (_recognizedText.isNotEmpty)
                    Text(
                      _getCommandFeedback(_recognizedText),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _stopListening,
                        child: const Text("إلغاء",
                            style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: _showHelpScreen,
                        child: const Text("مساعدة",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'Information.dart'; // استيراد ملف المعلومات

class MyPlantsScreen extends StatelessWidget {
  MyPlantsScreen({super.key});

  final List<Map<String, String>> plants = [
    {
      "name": "كالاثيا زيبربنا",
      "description": "نبات داخلي بأوراق مخططة",
      "image": "assets/images/plant1.png",
    },
    {
      "name": "بوثوس الذهبي",
      "description": "نبات داخلي متسلق",
      "image": "assets/images/plant2.png",
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: plants.length,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            itemBuilder: (context, index) {
              return GestureDetector(
                // إضافة GestureDetector للتعامل مع النقر على النبتة
                onTap: () {
                  // التحقق من أن النبتة هي كالاثيا زيبربنا
                  if (plants[index]['name'] == "كالاثيا زيبربنا") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InformationScreen(),
                      ),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF577363), //  لون المربع
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      //  أيقونة الثلاث نقاط في الزاوية العلوية اليمنى تمامًا
                      Positioned(
                        top: 5, //  رفع الأيقونة للأعلى
                        right: 8, //  تقريبها أكثر للحافة اليمنى
                        child: const Icon(
                          Icons.more_horiz,
                          color: Colors.white, //  الإبقاء على اللون الأبيض
                          size: 22, //  تصغير الحجم قليلًا ليبدو أكثر تناسقًا
                        ),
                      ),
                      // ✅ محتوى البطاقة
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10), //  رفع المحتوى قليلاً
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //  الصورة على اليسار بحجم أكبر
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                plants[index]['image']!,
                                width: 160, // تكبير العرض
                                height: 140, //  تكبير الارتفاع
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            //  النص على اليمين مع زر جدول الري
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end, // النص محاذاة يمين
                                children: [
                                  const SizedBox(
                                      height: 10), //  تباعد عن الأيقونة العلوية
                                  Text(
                                    plants[index]['name']!,
                                    style: const TextStyle(
                                      fontSize: 22, //  تكبير الخط
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    plants[index]['description']!,
                                    style: const TextStyle(
                                      fontSize: 14, //  تكبير النص الوصفي
                                      color: Colors.white70,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  const SizedBox(height: 10),
                                  //  زر "أضف إلى جدول الري" بتنسيق مضبوط
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                            0xFF2A543C), //  لون الزر
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 14), // تحسين حجم الزر
                                      ),
                                      onPressed: () {},
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text(
                                            "أضف إلى جدول الري",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(width: 5),
                                          Icon(Icons.local_drink,
                                              size: 18,
                                              color: Colors
                                                  .white), //  تكبير الأيقونة قليلاً
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
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // ✅ زر "إضافة نبات"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCDD4BA), //  لون الزر الرئيسي
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 24), //  تكبير الزر
            ),
            onPressed: () {},
            child: const Text(
              "إضافة نبات +",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold), //  تكبير الخط
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

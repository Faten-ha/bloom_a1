import 'package:bloom_a1/services/notification_service.dart';
import 'package:bloom_a1/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'screens/splash_screen.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initialServices();

  // Initialize time zones
  tz.initializeTimeZones();
  final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));

    runApp(const MyApp());
}


Future<void> initialServices() async {

  // await Get.putAsync(() => TtsService().init());

   final notificationStatus = await Permission.notification.status;
   if (!notificationStatus.isGranted) {
     await Permission.notification.request();
   }

   final alarmStatus = await Permission.scheduleExactAlarm.status;
   if (!alarmStatus.isGranted) {
     await Permission.scheduleExactAlarm.request();
   }
   await NotificationService.init();
  }


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bloom Assist',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SplashScreen(),
    );
  }
}

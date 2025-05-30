import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationService {


  static const platform = MethodChannel('com.example.bloom_a1/alarm');


  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {

    await scheduleAndroidAlarm(date, body,title);
  }



  static Future<void> scheduleAndroidAlarm(
      DateTime datetime,
       String message,
      String title,
      ) async {
    if (Platform.isAndroid) {
      final int alarmTimeMillis = datetime.millisecondsSinceEpoch;
      try {
        await platform.invokeMethod('scheduleAlarm', {
          'time': alarmTimeMillis,
          'message': message, // ✅ send message with time
          'title':title,
        });
      } on PlatformException catch (e) {
        print("Failed to schedule alarm: '${e.message}'.");
      }
    }
  }
}

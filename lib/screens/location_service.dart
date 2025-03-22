import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // التحقق مما إذا كانت خدمة الموقع مفعلة
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
          'خدمة الموقع غير مفعلة. يرجى تفعيل GPS من الإعدادات.');
    }

    // التحقق من حالة الإذن
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('تم رفض إذن الموقع.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'تم رفض الإذن نهائيًا. يرجى تمكينه من إعدادات الهاتف.');
    }

    // فتح نافذة حوار تطلب من المستخدم السماح باستخدام موقعه
    bool shouldGetLocation = await _showLocationDialog(context);

    if (shouldGetLocation) {
      // الحصول على الموقع الحالي
      return await Geolocator.getCurrentPosition();
    } else {
      return Future.error('لم يتم تفعيل الموقع.');
    }
  }

  Future<bool> _showLocationDialog(BuildContext context) async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("مشاركة الموقع"),
          content: Text("هل ترغب في مشاركة موقعك الحالي؟"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("لا"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("نعم"),
            ),
          ],
        );
      },
    ).then((value) {
      result = value ?? false;
    });
    return result;
  }
}

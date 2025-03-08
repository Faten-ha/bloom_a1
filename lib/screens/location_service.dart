import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
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

    // الحصول على الموقع الحالي
    return await Geolocator.getCurrentPosition();
  }
}

import 'package:ntp/ntp.dart';

import '../repositories/local_storage.dart';

class TrueTime {
  factory TrueTime() => _instance;

  TrueTime._internal();

  static final TrueTime _instance = TrueTime._internal();
  static const _trueTime = "TrueTimePref";
  static final _localStorage = LocalStorageImpl();

  static int _offset = 0;

  static DateTime now() => DateTime.now().add(Duration(milliseconds: _offset));

  static Future<void> initialize() async {
    _offset = await _localStorage.getIntData(_trueTime) ?? 0;
    try {
      _offset = await NTP.getNtpOffset().timeout(Duration(seconds: 10));
      _localStorage.saveIntData(_trueTime, _offset);
    } catch (e) {}
  }
}

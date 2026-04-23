import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class StartupChecksResult {
  const StartupChecksResult({
    required this.batteryState,
    required this.batteryLevel,
    required this.isPluggedToPower,
    required this.usbDebugEnabled,
    this.hasError = false,
  });

  final BatteryState batteryState;
  final int batteryLevel;
  final bool isPluggedToPower;
  final bool usbDebugEnabled;
  final bool hasError;

  bool get isChargingAndFull => isPluggedToPower && batteryLevel >= 100;
  bool get hasInvalidBatteryData =>
      batteryState == BatteryState.unknown || batteryLevel < 0;
}

class StartupChecksService {
  static const _channel = MethodChannel('com.dimakrash.fanarena/debug_info');

  final Battery _battery;

  StartupChecksService({Battery? battery}) : _battery = battery ?? Battery();

  Future<BatteryState> getBatteryState() async {
    return _battery.batteryState;
  }

  Stream<BatteryState> batteryStateChanges() {
    return _battery.onBatteryStateChanged;
  }

  Future<bool> isUsbDebuggingEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isUsbDebuggingEnabled');
      debugPrint(
        'FanArenaStartup: usb_debug_check result=${result ?? false}',
      );
      return result ?? false;
    } on PlatformException {
      // iOS and other non-Android platforms do not expose this method.
      debugPrint(
        'FanArenaStartup: usb_debug_check platform_exception -> default=false',
      );
      return false;
    }
  }

  Future<({bool isPluggedToPower, int batteryLevel})> getChargingInfo() async {
    try {
      final payload = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getChargingInfo',
      );
      final isPlugged = payload?['isPlugged'] == true;
      final level = (payload?['batteryLevel'] as num?)?.toInt() ?? -1;
      debugPrint(
        'FanArenaStartup: charging_info is_plugged=$isPlugged battery_level=$level',
      );
      return (isPluggedToPower: isPlugged, batteryLevel: level);
    } on PlatformException {
      debugPrint(
        'FanArenaStartup: charging_info platform_exception -> '
        'is_plugged=false battery_level=-1',
      );
      return (isPluggedToPower: false, batteryLevel: -1);
    }
  }

  Future<StartupChecksResult> runStartupChecks() async {
    BatteryState batteryState = BatteryState.unknown;
    int batteryLevel = -1;
    bool isPluggedToPower = false;
    bool hasError = false;

    try {
      batteryState = await getBatteryState();
      final chargingInfo = await getChargingInfo();
      isPluggedToPower = chargingInfo.isPluggedToPower;
      batteryLevel = chargingInfo.batteryLevel;
    } catch (_) {
      hasError = true;
      debugPrint('FanArenaStartup: battery_check error');
    }

    final usbDebugEnabled = await isUsbDebuggingEnabled();
    debugPrint(
      'FanArenaStartup: startup_checks battery_state=$batteryState '
      'battery_level=$batteryLevel is_plugged=$isPluggedToPower '
      'usb_debug=$usbDebugEnabled '
      'has_error=$hasError',
    );

    return StartupChecksResult(
      batteryState: batteryState,
      batteryLevel: batteryLevel,
      isPluggedToPower: isPluggedToPower,
      usbDebugEnabled: usbDebugEnabled,
      hasError: hasError,
    );
  }
}

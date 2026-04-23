import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class StartupChecksResult {
  const StartupChecksResult({
    required this.batteryState,
    required this.batteryLevel,
    required this.usbDebugEnabled,
    this.hasError = false,
  });

  final BatteryState batteryState;
  final int batteryLevel;
  final bool usbDebugEnabled;
  final bool hasError;

  bool get isChargingAndFull {
    final isPlugged = batteryState == BatteryState.charging ||
        batteryState == BatteryState.full ||
        batteryState == BatteryState.connectedNotCharging;
    return isPlugged && batteryLevel >= 100;
  }
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

  Future<StartupChecksResult> runStartupChecks() async {
    BatteryState batteryState = BatteryState.unknown;
    int batteryLevel = -1;
    bool hasError = false;

    try {
      batteryState = await getBatteryState();
      batteryLevel = await _battery.batteryLevel;
    } catch (_) {
      hasError = true;
      debugPrint('FanArenaStartup: battery_check error');
    }

    final usbDebugEnabled = await isUsbDebuggingEnabled();
    debugPrint(
      'FanArenaStartup: startup_checks battery_state=$batteryState '
      'battery_level=$batteryLevel usb_debug=$usbDebugEnabled '
      'has_error=$hasError',
    );

    return StartupChecksResult(
      batteryState: batteryState,
      batteryLevel: batteryLevel,
      usbDebugEnabled: usbDebugEnabled,
      hasError: hasError,
    );
  }
}

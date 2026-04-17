import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DebugOverlay extends StatefulWidget {
  const DebugOverlay({super.key});

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  static const _channel = MethodChannel('com.dimakrash.fanarena/debug_info');

  final _battery = Battery();
  StreamSubscription<BatteryState>? _batterySub;

  BatteryState _batteryState = BatteryState.unknown;
  bool _usbDebug = false;

  @override
  void initState() {
    super.initState();
    _battery.batteryState.then((s) {
      if (mounted) setState(() => _batteryState = s);
    });
    _batterySub = _battery.onBatteryStateChanged.listen((s) {
      if (mounted) setState(() => _batteryState = s);
    });
    _checkUsbDebugging();
  }

  Future<void> _checkUsbDebugging() async {
    try {
      final result = await _channel.invokeMethod<bool>('isUsbDebuggingEnabled');
      if (mounted) setState(() => _usbDebug = result ?? false);
    } on PlatformException {
      // ignore on non-Android
    }
  }

  @override
  void dispose() {
    _batterySub?.cancel();
    super.dispose();
  }

  String get _batteryLabel {
    switch (_batteryState) {
      case BatteryState.charging:
        return 'Charging';
      case BatteryState.full:
        return 'Full';
      case BatteryState.connectedNotCharging:
        return 'Connected';
      case BatteryState.discharging:
        return 'Battery';
      default:
        return 'Unknown';
    }
  }

  IconData get _batteryIcon {
    switch (_batteryState) {
      case BatteryState.charging:
      case BatteryState.full:
        return Icons.battery_charging_full;
      case BatteryState.connectedNotCharging:
        return Icons.battery_full;
      default:
        return Icons.battery_alert;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topPadding,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Container(
          color: Colors.black.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_batteryIcon, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    _batteryLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.usb,
                    size: 14,
                    color: _usbDebug ? Colors.greenAccent : Colors.white54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'USB Debug: ${_usbDebug ? "ON" : "OFF"}',
                    style: TextStyle(
                      color: _usbDebug ? Colors.greenAccent : Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

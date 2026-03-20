import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:fan_arena/core/theme/app_colors.dart';
import 'package:fan_arena/core/theme/app_spacing.dart';
import 'package:fan_arena/providers/app_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _version = '${info.version} (${info.buildNumber})');
    }
  }

  void _showSnackBar(BuildContext context, String message,
      {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppDataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _sectionHeader('Profile', sectionStyle),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Nickname'),
            subtitle: Text(provider.profile.nickname),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editNickname(context, provider),
          ),
          ListTile(
            leading: const Icon(Icons.sports),
            title: const Text('Favorite Sports'),
            subtitle: provider.profile.favoriteSports.isEmpty
                ? const Text('None selected')
                : Wrap(
                    spacing: AppSpacing.xs,
                    children: provider.profile.favoriteSports
                        .map((s) => Chip(
                              label: Text(s,
                                  style: const TextStyle(fontSize: 12)),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ))
                        .toList(),
                  ),
          ),
          const Divider(),

          _sectionHeader('Appearance', sectionStyle),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                const Icon(Icons.palette_outlined),
                const SizedBox(width: AppSpacing.lg),
                const Expanded(child: Text('Theme Mode')),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'system', label: Text('System')),
                    ButtonSegment(value: 'light', label: Text('Light')),
                    ButtonSegment(value: 'dark', label: Text('Dark')),
                  ],
                  selected: {provider.profile.themeMode},
                  onSelectionChanged: (v) {
                    final mode = v.first;
                    provider.setThemeMode(mode);
                    _showSnackBar(
                        context, 'Theme changed to ${mode[0].toUpperCase()}${mode.substring(1)}');
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          _sectionHeader('Data Management', sectionStyle),
          ListTile(
            leading: Icon(Icons.auto_fix_high, color: AppColors.accent),
            title: const Text('Fill Demo Data'),
            subtitle: const Text('Populate app with sample data'),
            onTap: () => _fillDemoData(context, provider),
          ),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: const Text('Export Data'),
            subtitle: const Text('Copy all data as JSON'),
            onTap: () => _exportData(context, provider),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Import Data'),
            subtitle: const Text('Paste JSON to restore data'),
            onTap: () => _importData(context, provider),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: const Text('Stats Summary'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/stats'),
          ),
          ListTile(
            leading: Icon(Icons.restart_alt, color: AppColors.warning),
            title: const Text('Reset Onboarding'),
            onTap: () => _confirmResetOnboarding(context, provider),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.error),
            title: Text(
              'Clear All Data',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () => _confirmClearAll(context, provider),
          ),
          const Divider(),

          _sectionHeader('About', sectionStyle),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About FanArena'),
            subtitle: Text(
              'FanArena is a personal offline organizer for sports fans. '
              'It does not provide live scores, ticket sales, or official competition data.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.tag),
            title: const Text('Version'),
            subtitle: Text(_version),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(title.toUpperCase(), style: style),
    );
  }

  Future<void> _editNickname(
    BuildContext context,
    AppDataProvider provider,
  ) async {
    final ctrl = TextEditingController(text: provider.profile.nickname);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Nickname'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Your nickname'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result != null && result.trim().isNotEmpty) {
      final name = result.trim();
      await provider.updateNickname(name);
      if (!context.mounted) return;
      _showSnackBar(context, 'Nickname updated to "$name"');
    }
  }

  Future<void> _exportData(
    BuildContext context,
    AppDataProvider provider,
  ) async {
    final data = provider.exportData();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    await Clipboard.setData(ClipboardData(text: jsonStr));

    if (!context.mounted) return;
    _showSnackBar(context, 'Data copied to clipboard');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Data Exported'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonStr,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _importData(
    BuildContext context,
    AppDataProvider provider,
  ) async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Data'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: TextField(
            controller: ctrl,
            maxLines: null,
            expands: true,
            decoration: const InputDecoration(
              hintText: 'Paste exported JSON here...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      ctrl.dispose();
      return;
    }

    try {
      final data = jsonDecode(ctrl.text) as Map<String, dynamic>;
      ctrl.dispose();
      await provider.importData(data);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data imported successfully')),
      );
    } catch (e) {
      ctrl.dispose();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _confirmResetOnboarding(
    BuildContext context,
    AppDataProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Onboarding'),
        content: const Text(
          'This will show the onboarding flow again on next launch. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.resetOnboarding();
      if (!context.mounted) return;
      _showSnackBar(context, 'Onboarding reset');
      Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (_) => false);
    }
  }

  Future<void> _confirmClearAll(
    BuildContext context,
    AppDataProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your teams, matches, journal entries, '
          'tournaments, and predictions. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Clear Everything',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.clearAllData();
      if (!context.mounted) return;
      _showSnackBar(context, 'All data cleared');
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  Future<void> _fillDemoData(
    BuildContext context,
    AppDataProvider provider,
  ) async {
    final hasData = provider.teams.isNotEmpty || provider.matches.isNotEmpty;

    if (hasData) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Fill Demo Data'),
          content: const Text(
            'This will add demo teams, matches, predictions, journal entries, and tournaments. '
            'Your existing data will NOT be removed.\n\n'
            'Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Fill Demo Data'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    await provider.fillDemoData();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                  'Demo data added! Explore teams, matches, predictions, journal entries, and tournaments.'),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

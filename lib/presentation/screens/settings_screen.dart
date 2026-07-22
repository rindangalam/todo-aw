import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../providers/data_service_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: Text(S.settingsTitle)),
      body: ListView(
        children: [
          _SectionHeader(title: S.settingsTampilan),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: Text(S.settingsModeGelap),
            value: isDark,
            onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
          ),
          const Divider(height: 1),
          _SectionHeader(title: S.settingsData),
          ListTile(
            leading: const Icon(Icons.category),
            title: Text(S.settingsKategori),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/categories'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(S.settingsTempatSampah),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/trash'),
          ),
          _ExportTile(
            icon: Icons.backup,
            title: S.settingsBackup,
            subtitle: 'Todoaw Backup (.json)',
            onExport: () => ref.read(dataServiceProvider).exportJson(),
          ),
          _ExportTile(
            icon: Icons.file_download,
            title: S.settingsExportJson,
            onExport: () => ref.read(dataServiceProvider).exportJson(),
          ),
          _ExportTile(
            icon: Icons.file_download,
            title: S.settingsExportCsv,
            onExport: () => ref.read(dataServiceProvider).exportCsv(),
          ),
          _ExportTile(
            icon: Icons.storage,
            title: S.settingsExportSqlite,
            onExport: () => ref.read(dataServiceProvider).exportSqlite(),
          ),
          const Divider(height: 1),
          _SectionHeader(title: S.settingsTentang),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(S.settingsVersi),
            trailing: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}

class _ExportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Future<String> Function() onExport;

  const _ExportTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: () async {
        try {
          final path = await onExport();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tersimpan di: $path'),
              duration: const Duration(seconds: 4),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: $e')),
          );
        }
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

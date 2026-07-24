import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../providers/data_service_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/seed_data.dart';
import '../../services/tour_service.dart';
import '../widgets/color_picker_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final accent = ref.watch(accentColorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsTitle)),
      body: ListView(
        children: [
          const _SectionHeader(title: S.settingsTampilan),
          ListTile(
            leading: Icon(Icons.settings_suggest,
                color: themeMode == ThemeMode.system ? accent : null),
            title: const Text(S.settingsModeSystem),
            trailing: themeMode == ThemeMode.system
                ? Icon(Icons.check, color: accent)
                : null,
            onTap: () =>
                ref.read(themeModeProvider.notifier).setMode(ThemeMode.system),
          ),
          ListTile(
            leading: Icon(Icons.light_mode,
                color: themeMode == ThemeMode.light ? accent : null),
            title: const Text(S.settingsModeLight),
            trailing: themeMode == ThemeMode.light
                ? Icon(Icons.check, color: accent)
                : null,
            onTap: () =>
                ref.read(themeModeProvider.notifier).setMode(ThemeMode.light),
          ),
          ListTile(
            leading: Icon(Icons.dark_mode,
                color: themeMode == ThemeMode.dark ? accent : null),
            title: const Text(S.settingsModeDark),
            trailing: themeMode == ThemeMode.dark
                ? Icon(Icons.check, color: accent)
                : null,
            onTap: () =>
                ref.read(themeModeProvider.notifier).setMode(ThemeMode.dark),
          ),
          _AccentColorTile(),
          const Divider(height: 1),
          const _SectionHeader(title: S.settingsData),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text(S.settingsKategori),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/categories'),
          ),
          ListTile(
            leading: const Icon(Icons.label_outline),
            title: const Text('Label'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/tags'),
          ),
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: const Text('Arsip'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/archive'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text(S.settingsTempatSampah),
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
            icon: Icons.restore,
            title: S.settingsRestore,
            onExport: () => _restoreData(context, ref),
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
          ListTile(
            leading: const Icon(Icons.dataset_outlined),
            title: const Text(S.settingsMuatContohData),
            onTap: () async {
              await seedIfEmpty();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(S.settingsDataContohBerhasil)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.tour_outlined),
            title: const Text('Ulangi Tour'),
            onTap: () async {
              await TourService.resetAll();
              context.go('/intro');
            },
          ),
          const Divider(height: 1),
          const _SectionHeader(title: S.settingsTentang),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(S.settingsVersi),
            trailing: Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  Future<String> _restoreData(BuildContext context, WidgetRef ref) async {
    try {
      final filePath = await _pickJsonFile(context);
      if (filePath == null) return 'Dibatalkan';
      await ref.read(dataServiceProvider).importJson(filePath);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil dipulihkan')),
      );
      return 'Berhasil';
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memulihkan: $e')),
      );
      return 'Gagal: $e';
    }
  }

  Future<String?> _pickJsonFile(BuildContext context) async {
    // Simple file dialog using TextField for file path input
    final controller = TextEditingController();
    final path = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pilih file backup'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '/storage/emulated/0/Download/Todoaw/todoaw_backup.json',
            labelText: 'Path file .json',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Pulihkan'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (path == null || path.isEmpty) return null;
    return path;
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
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tersimpan di: $path'),
              duration: const Duration(seconds: 4),
            ),
          );
        } catch (e) {
          // ignore: use_build_context_synchronously
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

class _AccentColorTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentColorProvider);
    return ListTile(
      leading: Icon(Icons.palette_outlined, color: accent),
      title: const Text('Warna Aksen'),
      subtitle: Text(
        '#${accent.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
      ),
      trailing: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
          ),
        ),
      ),
      onTap: () async {
        final result = await showColorPickerSheet(
          context,
          initialColor: accent,
        );
        if (result != null) {
          ref.read(accentColorProvider.notifier).setColor(result);
        }
      },
    );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../data/database.dart';
import '../../providers/data_service_provider.dart';
import '../../providers/habit_provider.dart';
import '../../providers/note_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/task_list_provider.dart';
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
            icon: Icons.table_chart_outlined,
            title: S.settingsExportExcel,
            subtitle: 'Semua data (.xlsx)',
            onExport: () => ref.read(dataServiceProvider).exportExcel(),
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
            onTap: () => _confirmMuatContoh(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text(S.settingsHapusContohData),
            onTap: () => _confirmHapusContoh(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined),
            title: const Text(S.settingsHapusData),
            onTap: () => _confirmHapusData(context, ref),
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
      final filePath = await _pickJsonFile();
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

  Future<String?> _pickJsonFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.isEmpty) return null;
      return result.files.single.path;
    } catch (e) {
      return null;
    }
  }

  Future<void> _confirmHapusContoh(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.settingsHapusContohKonfirmasi),
        content: const Text(S.settingsHapusContohDeskripsi),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(S.batal),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await deleteSeedData();
    ref.invalidate(taskListProvider);
    ref.invalidate(noteListProvider);
    ref.invalidate(habitListProvider);
    ref.invalidate(statsProvider);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data contoh berhasil dihapus')),
    );
  }

  Future<void> _confirmHapusData(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.settingsHapusDataKonfirmasi),
        content: const Text(S.settingsHapusDataDeskripsi),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(S.batal),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(S.yaHapus),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await AppDatabase.deleteAllData();
    ref.invalidate(taskListProvider);
    ref.invalidate(noteListProvider);
    ref.invalidate(habitListProvider);
    ref.invalidate(statsProvider);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua data berhasil dihapus')),
    );
  }

  Future<void> _confirmMuatContoh(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.settingsMuatContohKonfirmasi),
        content: const Text(S.settingsMuatContohDeskripsi),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(S.batal),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(S.yaMuat),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await seedIfEmpty(force: true, append: true);
    ref.invalidate(taskListProvider);
    ref.invalidate(noteListProvider);
    ref.invalidate(habitListProvider);
    ref.invalidate(statsProvider);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(S.settingsDataContohBerhasil)),
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

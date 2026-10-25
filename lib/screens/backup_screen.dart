import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/l10n.dart';
import '../services/backup.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';
import 'home_screen.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _busy = false;

  Future<void> _export() async {
    final l = L10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final file = await BackupService.exportZip();
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        subject: l.s('Programmatic Assistant backup',
            'Programatik Asistan yedeği'),
        text: l.s('Your campaign data backup.',
            'Kampanya verilerinin yedeği.'),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
          content: Text(l.s('Export failed: $e', 'Dışa aktarma hatası: $e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final l = L10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.s('Restore from backup?', 'Yedekten geri yükle?')),
        content: Text(l.s(
            'This replaces ALL current campaigns and data with the backup. '
                'This cannot be undone.',
            'Bu, mevcut TÜM kampanya ve verileri yedektekiyle değiştirir. '
                'Geri alınamaz.')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.s('Cancel', 'İptal'))),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.s('Replace', 'Değiştir'))),
        ],
      ),
    );
    if (ok != true) return;

    final picked = await FilePicker.pickFiles(type: FileType.any);
    if (picked == null || picked.files.single.path == null) return;
    final path = picked.files.single.path!;
    if (!path.toLowerCase().endsWith('.zip')) {
      messenger.showSnackBar(SnackBar(
          content: Text(l.s('Please pick a .zip backup file.',
              'Lütfen .zip yedek dosyası seç.'))));
      return;
    }

    setState(() => _busy = true);
    try {
      final r = await BackupService.importZip(File(path));
      if (!mounted) return;
      setState(() => _busy = false);
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.s('Restore complete', 'Geri yükleme tamam')),
          content: Text(l.s(
              'Restored ${r.campaigns} campaigns, ${r.metrics} daily entries, '
                  '${r.tasks} tasks, ${r.activity} log entries and '
                  '${r.attachments} files.',
              '${r.campaigns} kampanya, ${r.metrics} günlük giriş, '
                  '${r.tasks} görev, ${r.activity} geçmiş kaydı ve '
                  '${r.attachments} dosya geri yüklendi.')),
          actions: [
            FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l.s('OK', 'Tamam'))),
          ],
        ),
      );
      if (!mounted) return;
      // Rebuild the whole app so every tab reloads from the restored data.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(
          content: Text(l.s('Import failed: $e', 'İçe aktarma hatası: $e'))));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(title: Text(l.s('Backup', 'Yedekleme'))),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              PanelCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud_upload_outlined,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 10),
                        const SectionHeading('Export'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.s(
                          'Save all campaigns, daily entries, tasks and '
                              'attached files into a single .zip you can store '
                              'on Drive, email or your phone.',
                          'Tüm kampanyaları, günlük girişleri, görevleri ve '
                              'ekli dosyaları tek bir .zip dosyasına kaydeder; '
                              'Drive\'a, e-postaya veya telefonuna saklarsın.'),
                      style: TextStyle(
                          fontFamily: 'Inter', color: p.muted, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _busy ? null : _export,
                      icon: const Icon(Icons.ios_share_rounded),
                      label: Text(l.s('Export & share', 'Dışa aktar & paylaş')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              PanelCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud_download_outlined, color: p.warn),
                        const SizedBox(width: 10),
                        const SectionHeading('Restore'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.s(
                          'Load a .zip backup. This replaces all current data '
                              'with the backup — use it on a new phone or after '
                              'reinstalling.',
                          'Bir .zip yedeği yükler. Mevcut tüm veriyi yedektekiyle '
                              'değiştirir — yeni telefonda veya yeniden kurulumdan '
                              'sonra kullan.'),
                      style: TextStyle(
                          fontFamily: 'Inter', color: p.muted, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _import,
                      icon: const Icon(Icons.folder_open_rounded),
                      label: Text(
                          l.s('Import from file', 'Dosyadan içe aktar')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l.s('Tip: export regularly. Data lives only on this phone.',
                    'İpucu: düzenli yedek al. Veri yalnızca bu telefonda durur.'),
                style: TextStyle(
                    fontFamily: 'Inter', fontSize: 12.5, color: p.muted),
              ),
            ],
          ),
          if (_busy)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

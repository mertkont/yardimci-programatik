import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../db/app_db.dart';

class BackupResult {
  final int campaigns;
  final int metrics;
  final int tasks;
  final int attachments;
  final int activity;
  const BackupResult(this.campaigns, this.metrics, this.tasks, this.attachments,
      this.activity);
}

/// Full export / import of all user data (campaigns, daily metrics, tasks and
/// attachment files) as a single .zip. KB content is not backed up — it is
/// re-seeded by the app.
class BackupService {
  static const int formatVersion = 1;

  // ---- Export -------------------------------------------------------------
  static Future<File> exportZip() async {
    final db = await AppDb.instance.db;
    final campaigns = await db.query('campaigns');
    final metrics = await db.query('daily_metrics');
    final tasks = await db.query('tasks');
    final attachments = await db.query('attachments');
    final activity = await db.query('activity_log');
    final checklist = await db.query('checklist');

    final archive = Archive();

    // Bundle attachment files and record their path inside the archive.
    final attachmentMaps = <Map<String, Object?>>[];
    for (final row in attachments) {
      final map = Map<String, Object?>.from(row);
      final path = row['file_path'] as String?;
      if (path != null) {
        final f = File(path);
        if (await f.exists()) {
          final arcName = 'attachments/${row['id']}_${row['file_name']}';
          archive.addFile(ArchiveFile.bytes(arcName, await f.readAsBytes()));
          map['archive_path'] = arcName;
        }
      }
      attachmentMaps.add(map);
    }

    final data = <String, Object?>{
      'format_version': formatVersion,
      'exported_at': DateTime.now().millisecondsSinceEpoch,
      'campaigns': campaigns.map((e) => Map<String, Object?>.from(e)).toList(),
      'daily_metrics': metrics.map((e) => Map<String, Object?>.from(e)).toList(),
      'tasks': tasks.map((e) => Map<String, Object?>.from(e)).toList(),
      'activity_log': activity.map((e) => Map<String, Object?>.from(e)).toList(),
      'checklist': checklist.map((e) => Map<String, Object?>.from(e)).toList(),
      'attachments': attachmentMaps,
    };
    archive.addFile(ArchiveFile.string('data.json', jsonEncode(data)));

    final bytes = ZipEncoder().encode(archive);
    final dir = await getTemporaryDirectory();
    final file =
        File(p.join(dir.path, 'programatik-yedek-${_stamp(DateTime.now())}.zip'));
    await file.writeAsBytes(bytes);
    return file;
  }

  // ---- Import -------------------------------------------------------------
  static Future<BackupResult> importZip(File zip) async {
    final archive = ZipDecoder().decodeBytes(await zip.readAsBytes());
    final dataFile = archive.findFile('data.json');
    if (dataFile == null) {
      throw const FormatException('Invalid backup: data.json not found');
    }
    final data =
        jsonDecode(utf8.decode(dataFile.content)) as Map<String, dynamic>;

    final db = await AppDb.instance.db;
    final docs = await getApplicationDocumentsDirectory();

    int cCount = 0, mCount = 0, tCount = 0, aCount = 0, actCount = 0;

    await db.transaction((txn) async {
      // Wipe existing user data (KB is left untouched).
      await txn.delete('attachments');
      await txn.delete('daily_metrics');
      await txn.delete('tasks');
      await txn.delete('activity_log');
      await txn.delete('checklist');
      await txn.delete('campaigns');

      final idMap = <int, int>{};
      for (final raw in (data['campaigns'] as List? ?? const [])) {
        final m = Map<String, Object?>.from(raw as Map);
        final oldId = m.remove('id') as int?;
        final newId = await txn.insert('campaigns', m);
        if (oldId != null) idMap[oldId] = newId;
        cCount++;
      }
      for (final raw in (data['daily_metrics'] as List? ?? const [])) {
        final m = Map<String, Object?>.from(raw as Map);
        m.remove('id');
        final newCid = idMap[m['campaign_id'] as int?];
        if (newCid == null) continue;
        m['campaign_id'] = newCid;
        await txn.insert('daily_metrics', m);
        mCount++;
      }
      for (final raw in (data['tasks'] as List? ?? const [])) {
        final m = Map<String, Object?>.from(raw as Map);
        m.remove('id');
        final oldCid = m['campaign_id'] as int?;
        if (oldCid != null) {
          final newCid = idMap[oldCid];
          if (newCid == null) continue;
          m['campaign_id'] = newCid;
        }
        await txn.insert('tasks', m);
        tCount++;
      }
      for (final raw in (data['activity_log'] as List? ?? const [])) {
        final m = Map<String, Object?>.from(raw as Map);
        m.remove('id');
        final newCid = idMap[m['campaign_id'] as int?];
        if (newCid == null) continue;
        m['campaign_id'] = newCid;
        await txn.insert('activity_log', m);
        actCount++;
      }
      for (final raw in (data['checklist'] as List? ?? const [])) {
        final m = Map<String, Object?>.from(raw as Map);
        m.remove('id');
        final newCid = idMap[m['campaign_id'] as int?];
        if (newCid == null) continue;
        m['campaign_id'] = newCid;
        await txn.insert('checklist', m);
      }
      for (final raw in (data['attachments'] as List? ?? const [])) {
        final m = Map<String, Object?>.from(raw as Map);
        m.remove('id');
        final newCid = idMap[m['campaign_id'] as int?];
        final arcPath = m.remove('archive_path') as String?;
        if (newCid == null || arcPath == null) continue;
        final af = archive.findFile(arcPath);
        if (af == null) continue;
        final destDir =
            Directory(p.join(docs.path, 'attachments', '$newCid'));
        await destDir.create(recursive: true);
        final dest = File(p.join(destDir.path, m['file_name'] as String));
        await dest.writeAsBytes(af.content);
        m['campaign_id'] = newCid;
        m['file_path'] = dest.path;
        await txn.insert('attachments', m);
        aCount++;
      }
    });

    return BackupResult(cCount, mCount, tCount, aCount, actCount);
  }

  static String _stamp(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}${two(d.month)}${two(d.day)}-${two(d.hour)}${two(d.minute)}';
  }
}

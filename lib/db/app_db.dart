import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';
import 'kb_seed.dart';

/// Single SQLite database for the whole app.
class AppDb {
  AppDb._();
  static final AppDb instance = AppDb._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'programatik.db');
    return openDatabase(
      path,
      version: 6,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 3) {
          // New video / ROAS metric columns.
          for (final col in const [
            'completed_views INTEGER NOT NULL DEFAULT 0',
            'viewable_impressions INTEGER NOT NULL DEFAULT 0',
            'revenue REAL NOT NULL DEFAULT 0',
          ]) {
            await db.execute('ALTER TABLE daily_metrics ADD COLUMN $col');
          }
        }
        if (oldV < 4) {
          // Client/sold budget for non-DV360 margin calculation.
          await db.execute(
              'ALTER TABLE campaigns ADD COLUMN real_budget REAL');
        }
        if (oldV < 5) {
          // Target delivery volume (impressions/views/clicks…).
          await db.execute(
              'ALTER TABLE campaigns ADD COLUMN goal_volume REAL');
        }
        if (oldV < 6) {
          // Dated activity journal + per-campaign setup checklist.
          await db.execute(_createActivityLog);
          await db.execute(_createChecklist);
        }
        // KB content is app-managed (not user data): wipe and re-seed so
        // existing installs always get the latest guides.
        await _reseedKb(db);
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE campaigns (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            platform TEXT NOT NULL,
            client TEXT NOT NULL,
            objective TEXT,
            pricing_type TEXT NOT NULL,
            total_budget REAL NOT NULL,
            start_date INTEGER NOT NULL,
            end_date INTEGER NOT NULL,
            status TEXT NOT NULL,
            kpi_target REAL,
            goal_volume REAL,
            margin_percent REAL,
            real_budget REAL,
            notes TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE daily_metrics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            campaign_id INTEGER NOT NULL,
            date INTEGER NOT NULL,
            spend REAL NOT NULL DEFAULT 0,
            impressions INTEGER NOT NULL DEFAULT 0,
            views INTEGER NOT NULL DEFAULT 0,
            completed_views INTEGER NOT NULL DEFAULT 0,
            viewable_impressions INTEGER NOT NULL DEFAULT 0,
            clicks INTEGER NOT NULL DEFAULT 0,
            conversions INTEGER NOT NULL DEFAULT 0,
            revenue REAL NOT NULL DEFAULT 0,
            margin_percent REAL,
            note TEXT,
            FOREIGN KEY (campaign_id) REFERENCES campaigns (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE attachments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            campaign_id INTEGER NOT NULL,
            type TEXT NOT NULL,
            file_name TEXT NOT NULL,
            file_path TEXT NOT NULL,
            added_at INTEGER NOT NULL,
            FOREIGN KEY (campaign_id) REFERENCES campaigns (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            campaign_id INTEGER,
            title TEXT NOT NULL,
            due_date INTEGER,
            priority TEXT NOT NULL DEFAULT 'normal',
            done INTEGER NOT NULL DEFAULT 0,
            note TEXT,
            FOREIGN KEY (campaign_id) REFERENCES campaigns (id) ON DELETE CASCADE
          )
        ''');
        await db.execute(_createActivityLog);
        await db.execute(_createChecklist);
        await db.execute('''
          CREATE TABLE kb_articles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            lang TEXT NOT NULL,
            category TEXT NOT NULL,
            title TEXT NOT NULL,
            body TEXT NOT NULL
          )
        ''');
        // Seed knowledge-base / how-to content (EN + TR).
        await _reseedKb(db);
      },
    );
  }

  static const _createActivityLog = '''
    CREATE TABLE activity_log (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      campaign_id INTEGER NOT NULL,
      date INTEGER NOT NULL,
      text TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      FOREIGN KEY (campaign_id) REFERENCES campaigns (id) ON DELETE CASCADE
    )
  ''';

  static const _createChecklist = '''
    CREATE TABLE checklist (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      campaign_id INTEGER NOT NULL,
      step_key TEXT NOT NULL,
      done INTEGER NOT NULL DEFAULT 0,
      done_at INTEGER,
      FOREIGN KEY (campaign_id) REFERENCES campaigns (id) ON DELETE CASCADE
    )
  ''';

  /// Replace all knowledge-base articles with the current seed content.
  Future<void> _reseedKb(Database db) async {
    await db.delete('kb_articles');
    final batch = db.batch();
    for (final a in kbSeed) {
      batch.insert('kb_articles', a);
    }
    await batch.commit(noResult: true);
  }

  // ---- Campaigns ----------------------------------------------------------
  Future<int> insertCampaign(Campaign c) async =>
      (await db).insert('campaigns', c.toMap()..remove('id'));

  Future<int> updateCampaign(Campaign c) async => (await db).update(
        'campaigns',
        c.toMap(),
        where: 'id = ?',
        whereArgs: [c.id],
      );

  Future<int> deleteCampaign(int id) async =>
      (await db).delete('campaigns', where: 'id = ?', whereArgs: [id]);

  Future<List<Campaign>> getCampaigns() async {
    final rows = await (await db).query('campaigns', orderBy: 'end_date ASC');
    return rows.map(Campaign.fromMap).toList();
  }

  Future<Campaign?> getCampaign(int id) async {
    final rows =
        await (await db).query('campaigns', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Campaign.fromMap(rows.first);
  }

  /// Move active/paused campaigns whose end date has passed into the
  /// completed (inactive) bucket. Returns the number archived.
  Future<int> archiveExpired() async {
    final today = DateTime.now();
    final cutoff =
        DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;
    return (await db).update(
      'campaigns',
      {'status': 'completed', 'updated_at': today.millisecondsSinceEpoch},
      where: "status IN ('active','paused') AND end_date < ?",
      whereArgs: [cutoff],
    );
  }

  /// Active campaign ids that have no metric entry for [day].
  Future<Set<int>> campaignsMissingEntryFor(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
    final end = DateTime(day.year, day.month, day.day)
        .add(const Duration(days: 1))
        .millisecondsSinceEpoch;
    final db0 = await db;
    final active = await db0.query('campaigns',
        columns: ['id'], where: "status = 'active'");
    final result = <int>{};
    for (final row in active) {
      final id = row['id'] as int;
      final entries = await db0.query(
        'daily_metrics',
        where: 'campaign_id = ? AND date >= ? AND date < ?',
        whereArgs: [id, start, end],
        limit: 1,
      );
      if (entries.isEmpty) result.add(id);
    }
    return result;
  }

  // ---- Daily metrics ------------------------------------------------------
  Future<int> insertMetric(DailyMetric m) async =>
      (await db).insert('daily_metrics', m.toMap()..remove('id'));

  Future<int> updateMetric(DailyMetric m) async => (await db).update(
        'daily_metrics',
        m.toMap(),
        where: 'id = ?',
        whereArgs: [m.id],
      );

  Future<int> deleteMetric(int id) async =>
      (await db).delete('daily_metrics', where: 'id = ?', whereArgs: [id]);

  Future<List<DailyMetric>> getMetrics(int campaignId) async {
    final rows = await (await db).query(
      'daily_metrics',
      where: 'campaign_id = ?',
      whereArgs: [campaignId],
      orderBy: 'date DESC',
    );
    return rows.map(DailyMetric.fromMap).toList();
  }

  // ---- Attachments --------------------------------------------------------
  Future<int> insertAttachment(Attachment a) async =>
      (await db).insert('attachments', a.toMap()..remove('id'));

  Future<int> deleteAttachment(int id) async =>
      (await db).delete('attachments', where: 'id = ?', whereArgs: [id]);

  Future<List<Attachment>> getAttachments(int campaignId) async {
    final rows = await (await db).query(
      'attachments',
      where: 'campaign_id = ?',
      whereArgs: [campaignId],
      orderBy: 'added_at DESC',
    );
    return rows.map(Attachment.fromMap).toList();
  }

  // ---- Tasks --------------------------------------------------------------
  Future<int> insertTask(TaskItem t) async =>
      (await db).insert('tasks', t.toMap()..remove('id'));

  Future<int> updateTask(TaskItem t) async => (await db).update(
        'tasks',
        t.toMap(),
        where: 'id = ?',
        whereArgs: [t.id],
      );

  Future<int> deleteTask(int id) async =>
      (await db).delete('tasks', where: 'id = ?', whereArgs: [id]);

  Future<List<TaskItem>> getTasks({bool openOnly = false}) async {
    final rows = await (await db).query(
      'tasks',
      where: openOnly ? 'done = 0' : null,
      orderBy: 'done ASC, due_date ASC',
    );
    return rows.map(TaskItem.fromMap).toList();
  }

  Future<List<TaskItem>> getTasksForCampaign(int campaignId) async {
    final rows = await (await db).query(
      'tasks',
      where: 'campaign_id = ?',
      whereArgs: [campaignId],
      orderBy: 'done ASC, due_date ASC',
    );
    return rows.map(TaskItem.fromMap).toList();
  }

  // ---- Activity log -------------------------------------------------------
  Future<int> insertActivity(ActivityLog a) async =>
      (await db).insert('activity_log', a.toMap()..remove('id'));

  Future<int> deleteActivity(int id) async =>
      (await db).delete('activity_log', where: 'id = ?', whereArgs: [id]);

  Future<List<ActivityLog>> getActivityLog(int campaignId) async {
    final rows = await (await db).query(
      'activity_log',
      where: 'campaign_id = ?',
      whereArgs: [campaignId],
      orderBy: 'date DESC, created_at DESC',
    );
    return rows.map(ActivityLog.fromMap).toList();
  }

  // ---- Checklist ----------------------------------------------------------
  Future<Map<String, ChecklistState>> getChecklist(int campaignId) async {
    final rows = await (await db).query(
      'checklist',
      where: 'campaign_id = ?',
      whereArgs: [campaignId],
    );
    final map = <String, ChecklistState>{};
    for (final r in rows) {
      final key = r['step_key'] as String;
      map[key] = ChecklistState(
        key,
        ((r['done'] as int?) ?? 0) == 1,
        r['done_at'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(r['done_at'] as int),
      );
    }
    return map;
  }

  /// Toggle a checklist step, recording the time it was completed.
  Future<void> setChecklistStep(
      int campaignId, String stepKey, bool done) async {
    final db0 = await db;
    final doneAt = done ? DateTime.now().millisecondsSinceEpoch : null;
    final existing = await db0.query(
      'checklist',
      where: 'campaign_id = ? AND step_key = ?',
      whereArgs: [campaignId, stepKey],
      limit: 1,
    );
    if (existing.isEmpty) {
      await db0.insert('checklist', {
        'campaign_id': campaignId,
        'step_key': stepKey,
        'done': done ? 1 : 0,
        'done_at': doneAt,
      });
    } else {
      await db0.update(
        'checklist',
        {'done': done ? 1 : 0, 'done_at': doneAt},
        where: 'campaign_id = ? AND step_key = ?',
        whereArgs: [campaignId, stepKey],
      );
    }
  }

  // ---- Knowledge base -----------------------------------------------------
  Future<List<KbArticle>> getKbArticles(String lang) async {
    final db0 = await db;
    var rows = await db0
        .query('kb_articles', where: 'lang = ?', whereArgs: [lang]);
    if (rows.isEmpty) {
      // Fall back to English if the requested language has no entries.
      rows = await db0
          .query('kb_articles', where: 'lang = ?', whereArgs: ['en']);
    }
    return rows.map(KbArticle.fromMap).toList();
  }
}

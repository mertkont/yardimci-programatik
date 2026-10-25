// Data models for the app. Plain Dart classes mapped to/from SQLite rows.

/// Supported ad platforms.
const kPlatforms = <String>[
  'DV360',
  'Amazon DSP',
  'Adform',
  'TikTok',
  'Meta',
  'Other',
];

/// Pricing / buying type. Determines which metric is shown for a campaign.
const kPricingTypes = <String>[
  'CPM',
  'vCPM',
  'CPV',
  'CPCV',
  'CPC',
  'CPA',
  'ROAS',
  'Flat',
];

/// Campaign status values.
const kStatuses = <String>[
  'active',
  'paused',
  'completed',
  'draft',
];

/// Attachment categories.
const kAttachmentTypes = <String>[
  'ordino',
  'creative',
  'other',
];

/// Predefined per-campaign setup steps, tracked as checkboxes once a campaign
/// is saved. Order here is the display order.
const kChecklistSteps = <String>[
  'screenshot',
  'ordino',
  'tracker',
  'order_sheet',
  'creatives',
  'live',
];

/// Localized label for a checklist step.
String checklistStepLabel(String key, bool tr) {
  switch (key) {
    case 'screenshot':
      return tr ? 'Kampanya SS\'i iletildi' : 'Campaign screenshot sent';
    case 'ordino':
      return tr ? 'Ordino geldi' : 'Ordino received';
    case 'tracker':
      return tr ? 'Tracker\'a eklendi' : 'Added to tracker';
    case 'order_sheet':
      return tr
          ? 'Client order sheet\'e eklendi'
          : 'Added to client order sheet';
    case 'creatives':
      return tr ? 'Kreatifler yüklendi' : 'Creatives uploaded';
    case 'live':
      return tr ? 'Kampanya yayında' : 'Campaign is live';
    default:
      return key;
  }
}

class Campaign {
  final int? id;
  final String name;
  final String platform;
  final String client;
  final String objective;
  final String pricingType;
  final double totalBudget;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double? kpiTarget; // target value for the pricing metric (e.g. target CPM)
  final double? goalVolume; // target delivery count (impressions/views/clicks…)
  final double? marginPercent; // DV360: markup %. Others: target margin %.
  final double? realBudget; // client/sold budget (revenue) for non-DV360 margin
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Campaign({
    this.id,
    required this.name,
    required this.platform,
    required this.client,
    this.objective = '',
    required this.pricingType,
    required this.totalBudget,
    required this.startDate,
    required this.endDate,
    this.status = 'active',
    this.kpiTarget,
    this.goalVolume,
    this.marginPercent,
    this.realBudget,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  /// True when margin is computed from a real (client) budget rather than a
  /// markup %. Used for non-DV360 campaigns.
  bool get usesRealBudget => realBudget != null && realBudget! > 0;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'platform': platform,
        'client': client,
        'objective': objective,
        'pricing_type': pricingType,
        'total_budget': totalBudget,
        'start_date': startDate.millisecondsSinceEpoch,
        'end_date': endDate.millisecondsSinceEpoch,
        'status': status,
        'kpi_target': kpiTarget,
        'goal_volume': goalVolume,
        'margin_percent': marginPercent,
        'real_budget': realBudget,
        'notes': notes,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  factory Campaign.fromMap(Map<String, Object?> m) => Campaign(
        id: m['id'] as int?,
        name: m['name'] as String,
        platform: m['platform'] as String,
        client: m['client'] as String,
        objective: (m['objective'] as String?) ?? '',
        pricingType: m['pricing_type'] as String,
        totalBudget: (m['total_budget'] as num).toDouble(),
        startDate: DateTime.fromMillisecondsSinceEpoch(m['start_date'] as int),
        endDate: DateTime.fromMillisecondsSinceEpoch(m['end_date'] as int),
        status: (m['status'] as String?) ?? 'active',
        kpiTarget: (m['kpi_target'] as num?)?.toDouble(),
        goalVolume: (m['goal_volume'] as num?)?.toDouble(),
        marginPercent: (m['margin_percent'] as num?)?.toDouble(),
        realBudget: (m['real_budget'] as num?)?.toDouble(),
        notes: (m['notes'] as String?) ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(m['updated_at'] as int),
      );

  Campaign copyWith({
    String? name,
    String? platform,
    String? client,
    String? objective,
    String? pricingType,
    double? totalBudget,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    double? kpiTarget,
    double? goalVolume,
    double? marginPercent,
    double? realBudget,
    String? notes,
    DateTime? updatedAt,
  }) =>
      Campaign(
        id: id,
        name: name ?? this.name,
        platform: platform ?? this.platform,
        client: client ?? this.client,
        objective: objective ?? this.objective,
        pricingType: pricingType ?? this.pricingType,
        totalBudget: totalBudget ?? this.totalBudget,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
        kpiTarget: kpiTarget ?? this.kpiTarget,
        goalVolume: goalVolume ?? this.goalVolume,
        marginPercent: marginPercent ?? this.marginPercent,
        realBudget: realBudget ?? this.realBudget,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

class DailyMetric {
  final int? id;
  final int campaignId;
  final DateTime date; // the day this entry belongs to (midnight)
  final double spend;
  final int impressions;
  final int views;
  final int completedViews; // video completions (for CPCV / VCR)
  final int viewableImpressions; // for viewability % and vCPM
  final int clicks;
  final int conversions;
  final double revenue; // for ROAS
  final double? marginPercent;
  final String note;

  DailyMetric({
    this.id,
    required this.campaignId,
    required this.date,
    this.spend = 0,
    this.impressions = 0,
    this.views = 0,
    this.completedViews = 0,
    this.viewableImpressions = 0,
    this.clicks = 0,
    this.conversions = 0,
    this.revenue = 0,
    this.marginPercent,
    this.note = '',
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'campaign_id': campaignId,
        'date': date.millisecondsSinceEpoch,
        'spend': spend,
        'impressions': impressions,
        'views': views,
        'completed_views': completedViews,
        'viewable_impressions': viewableImpressions,
        'clicks': clicks,
        'conversions': conversions,
        'revenue': revenue,
        'margin_percent': marginPercent,
        'note': note,
      };

  factory DailyMetric.fromMap(Map<String, Object?> m) => DailyMetric(
        id: m['id'] as int?,
        campaignId: m['campaign_id'] as int,
        date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
        spend: (m['spend'] as num?)?.toDouble() ?? 0,
        impressions: (m['impressions'] as num?)?.toInt() ?? 0,
        views: (m['views'] as num?)?.toInt() ?? 0,
        completedViews: (m['completed_views'] as num?)?.toInt() ?? 0,
        viewableImpressions: (m['viewable_impressions'] as num?)?.toInt() ?? 0,
        clicks: (m['clicks'] as num?)?.toInt() ?? 0,
        conversions: (m['conversions'] as num?)?.toInt() ?? 0,
        revenue: (m['revenue'] as num?)?.toDouble() ?? 0,
        marginPercent: (m['margin_percent'] as num?)?.toDouble(),
        note: (m['note'] as String?) ?? '',
      );
}

class Attachment {
  final int? id;
  final int campaignId;
  final String type; // ordino / creative / other
  final String fileName;
  final String filePath;
  final DateTime addedAt;

  Attachment({
    this.id,
    required this.campaignId,
    required this.type,
    required this.fileName,
    required this.filePath,
    required this.addedAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'campaign_id': campaignId,
        'type': type,
        'file_name': fileName,
        'file_path': filePath,
        'added_at': addedAt.millisecondsSinceEpoch,
      };

  factory Attachment.fromMap(Map<String, Object?> m) => Attachment(
        id: m['id'] as int?,
        campaignId: m['campaign_id'] as int,
        type: m['type'] as String,
        fileName: m['file_name'] as String,
        filePath: m['file_path'] as String,
        addedAt: DateTime.fromMillisecondsSinceEpoch(m['added_at'] as int),
      );
}

class TaskItem {
  final int? id;
  final int? campaignId;
  final String title;
  final DateTime? dueDate;
  final String priority; // low / normal / high
  final bool done;
  final String note;

  TaskItem({
    this.id,
    this.campaignId,
    required this.title,
    this.dueDate,
    this.priority = 'normal',
    this.done = false,
    this.note = '',
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'campaign_id': campaignId,
        'title': title,
        'due_date': dueDate?.millisecondsSinceEpoch,
        'priority': priority,
        'done': done ? 1 : 0,
        'note': note,
      };

  factory TaskItem.fromMap(Map<String, Object?> m) => TaskItem(
        id: m['id'] as int?,
        campaignId: m['campaign_id'] as int?,
        title: m['title'] as String,
        dueDate: m['due_date'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['due_date'] as int),
        priority: (m['priority'] as String?) ?? 'normal',
        done: ((m['done'] as int?) ?? 0) == 1,
        note: (m['note'] as String?) ?? '',
      );

  TaskItem copyWith({bool? done}) => TaskItem(
        id: id,
        campaignId: campaignId,
        title: title,
        dueDate: dueDate,
        priority: priority,
        done: done ?? this.done,
        note: note,
      );
}

/// A dated journal entry — "I did X to the campaign on day Y".
class ActivityLog {
  final int? id;
  final int campaignId;
  final DateTime date; // when the action happened (user-picked)
  final String text;
  final DateTime createdAt;

  ActivityLog({
    this.id,
    required this.campaignId,
    required this.date,
    required this.text,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'campaign_id': campaignId,
        'date': date.millisecondsSinceEpoch,
        'text': text,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory ActivityLog.fromMap(Map<String, Object?> m) => ActivityLog(
        id: m['id'] as int?,
        campaignId: m['campaign_id'] as int,
        date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
        text: m['text'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}

/// State of a single checklist step for a campaign.
class ChecklistState {
  final String stepKey;
  final bool done;
  final DateTime? doneAt;
  const ChecklistState(this.stepKey, this.done, this.doneAt);
}

class KbArticle {
  final int? id;
  final String lang; // 'en' or 'tr'
  final String category;
  final String title;
  final String body;

  KbArticle({
    this.id,
    required this.lang,
    required this.category,
    required this.title,
    required this.body,
  });

  factory KbArticle.fromMap(Map<String, Object?> m) => KbArticle(
        id: m['id'] as int?,
        lang: m['lang'] as String,
        category: m['category'] as String,
        title: m['title'] as String,
        body: m['body'] as String,
      );
}

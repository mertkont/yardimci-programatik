/// Context-sensitive help text for form fields. Returns a generic explanation
/// plus a platform-specific "where to find it" note when one exists.
class FieldHelp {
  static String text(String field, String platform, bool tr) {
    final h = _help[field];
    if (h == null) return '';
    final generic = tr ? h.tr : h.en;
    final note = h.byPlatform[platform];
    if (note == null) return generic;
    final where = tr
        ? '\n\n$platform: ${note.tr}'
        : '\n\nOn $platform: ${note.en}';
    return '$generic$where';
  }
}

class _N {
  final String en;
  final String tr;
  const _N(this.en, this.tr);
}

class _Help {
  final String en;
  final String tr;
  final Map<String, _N> byPlatform;
  const _Help(this.en, this.tr, [this.byPlatform = const {}]);
}

// Short per-platform "where to find it" notes reused across metric fields.
const _spend = {
  'DV360': _N("Report → the 'Revenue'/'Media cost' column (your cost).",
      "Raporda 'Revenue'/'Media cost' kolonu (senin maliyetin)."),
  'Amazon DSP': _N("DSP reporting → 'Total cost' for the line item.",
      "DSP raporu → line item 'Total cost'."),
  'TikTok': _N("Campaign dashboard → 'Cost' column.",
      "Kampanya dashboard → 'Cost' kolonu."),
  'Meta': _N("Ads Manager → 'Amount spent'.",
      "Ads Manager → 'Amount spent'."),
  'Adform': _N("Report Builder → 'Cost'/'Spend' metric.",
      "Report Builder → 'Cost'/'Spend' metriği."),
};

const _impr = {
  'DV360': _N("Report → 'Impressions' column.",
      "Raporda 'Impressions' kolonu."),
  'Amazon DSP': _N("Reporting → 'Impressions'.", "Raporda 'Impressions'."),
  'TikTok': _N("Dashboard → 'Impressions'.", "Dashboard → 'Impressions'."),
  'Meta': _N("Ads Manager → 'Impressions'.", "Ads Manager → 'Impressions'."),
  'Adform': _N("Report Builder → 'Impressions'.",
      "Report Builder → 'Impressions'."),
};

const _clicks = {
  'DV360': _N("Report → 'Clicks'.", "Raporda 'Clicks'."),
  'Amazon DSP': _N("Reporting → 'Clicks'.", "Raporda 'Clicks'."),
  'TikTok': _N("Dashboard → 'Clicks (destination)'.",
      "Dashboard → 'Clicks (destination)'."),
  'Meta': _N("Ads Manager → 'Link clicks' (or 'Clicks (all)').",
      "Ads Manager → 'Link clicks' (veya 'Clicks (all)')."),
  'Adform': _N("Report Builder → 'Clicks'.", "Report Builder → 'Clicks'."),
};

const _views = {
  'DV360': _N("YouTube/video report → 'Views' (TrueView views).",
      "YouTube/video raporu → 'Views' (TrueView)."),
  'TikTok': _N("Dashboard → 'Video views' (e.g. 2s/6s views).",
      "Dashboard → 'Video views' (2sn/6sn)."),
  'Meta': _N("Ads Manager → 'ThruPlays' or 'Video plays'.",
      "Ads Manager → 'ThruPlays' veya 'Video plays'."),
  'Adform': _N("Report Builder → video 'Views'.",
      "Report Builder → video 'Views'."),
};

const _completed = {
  'DV360': _N("Video report → 'Complete views' / 100% quartile.",
      "Video raporu → 'Complete views' / %100 quartile."),
  'TikTok': _N("Dashboard → 'Video views at 100%'.",
      "Dashboard → 'Video views at 100%'."),
  'Meta': _N("Ads Manager → 'Video plays at 100%'.",
      "Ads Manager → 'Video plays at 100%'."),
  'Adform': _N("Report Builder → 'Completed views' / Q100.",
      "Report Builder → 'Completed views' / Q100."),
};

const _viewable = {
  'DV360': _N("Report → 'Active View: viewable impressions'.",
      "Raporda 'Active View: viewable impressions'."),
  'TikTok': _N("Add the viewability metric in custom columns.",
      "Custom column'da viewability metriğini ekle."),
  'Meta': _N("Use a viewability/3rd-party (e.g. IAS/DV) column.",
      "Viewability / 3. taraf (IAS/DV) kolonunu kullan."),
  'Adform': _N("Report Builder → 'Viewable impressions'.",
      "Report Builder → 'Viewable impressions'."),
};

const _conv = {
  'DV360': _N("Report → your Floodlight 'Conversions' column.",
      "Raporda Floodlight 'Conversions' kolonu."),
  'Amazon DSP': _N("Reporting → 'Purchases' / 'Total conversions'.",
      "Raporda 'Purchases' / 'Total conversions'."),
  'TikTok': _N("Dashboard → 'Conversions' (pixel/event).",
      "Dashboard → 'Conversions' (pixel/event)."),
  'Meta': _N("Ads Manager → 'Results' / 'Conversions'.",
      "Ads Manager → 'Results' / 'Conversions'."),
  'Adform': _N("Report Builder → 'Conversions'.",
      "Report Builder → 'Conversions'."),
};

const _revenue = {
  'DV360': _N("Conversion 'Total revenue' column, if you pass values.",
      "Conversion 'Total revenue' kolonu (değer geçiyorsan)."),
  'Amazon DSP': _N("Reporting → 'Sales' / 'Total sales'.",
      "Raporda 'Sales' / 'Total sales'."),
  'TikTok': _N("Dashboard → 'Total complete payment value'.",
      "Dashboard → 'Total complete payment value'."),
  'Meta': _N("Ads Manager → 'Purchases conversion value'.",
      "Ads Manager → 'Purchases conversion value'."),
  'Adform': _N("Report Builder → conversion 'Revenue/Value'.",
      "Report Builder → conversion 'Revenue/Value'."),
};

final Map<String, _Help> _help = {
  // ---- Campaign form ----
  'name': const _Help(
    'A short name to recognise the campaign, e.g. "Nike_Summer_Video".',
    'Kampanyayı tanıyacağın kısa bir ad, örn. "Nike_Yaz_Video".',
  ),
  'client': const _Help(
    'The advertiser / client this campaign belongs to.',
    'Bu kampanyanın ait olduğu reklamveren / müşteri.',
  ),
  'platform': const _Help(
    'Where the campaign runs. This changes the per-field help so it matches '
        'the platform you pull data from.',
    'Kampanyanın yayınlandığı yer. Bu seçim, alan ipuçlarını veri çektiğin '
        'platforma göre değiştirir.',
  ),
  'pricingType': const _Help(
    'How you buy: CPM, CPV, CPCV, CPC, CPA, vCPM, ROAS or Flat. This decides '
        'the headline metric shown for the campaign.',
    'Nasıl satın aldığın: CPM, CPV, CPCV, CPC, CPA, vCPM, ROAS veya Sabit. '
        'Kampanyanın ana metriğini bu belirler.',
  ),
  'objective': const _Help(
    'Optional goal, e.g. awareness, traffic, conversions.',
    'Opsiyonel hedef, örn. bilinirlik, trafik, dönüşüm.',
  ),
  'totalBudget': _Help(
    'The media budget you can spend on this campaign (your cost cap).',
    'Bu kampanyaya harcayabileceğin medya bütçesi (maliyet limitin).',
    {
      'DV360': const _N("Set on the Insertion Order budget.",
          "Insertion Order bütçesinde ayarlanır."),
      'Amazon DSP': const _N("Set on the Order budget.",
          "Order bütçesinde ayarlanır."),
      'TikTok': const _N("Campaign/ad group budget (CBO or per ad group).",
          "Kampanya/ad group bütçesi (CBO veya ad group)."),
      'Meta': const _N("Campaign (Advantage) or ad set budget.",
          "Kampanya (Advantage) veya ad set bütçesi."),
      'Adform': const _N("Set on the line item / order budget.",
          "Line item / order bütçesinde ayarlanır."),
    },
  ),
  'kpiTarget': const _Help(
    'The efficiency you are aiming for on your pricing metric (e.g. target '
        'CPM/CPC) — the app flags when you run over it.',
    'Fiyatlama metriğinde hedeflediğin verim (örn. hedef CPM/CPC) — bunu '
        'aşarsan uygulama uyarır.',
  ),
  'goalVolume': const _Help(
    'The delivery you are contracted for (e.g. target impressions/views). The '
        'app projects end-of-flight delivery and flags going more than 10% '
        'over or under.',
    'Teslim etmen gereken hacim (örn. hedef gösterim/izlenme). Uygulama bitiş '
        'gününe kadarki tahmini teslimi hesaplar ve %10\'dan fazla aşma/altta '
        'kalmayı uyarır.',
  ),
  'marginDv360': const _Help(
    'Your markup on media cost. Profit = spend x margin%. In DV360 this is the '
        'margin you set on the partner/advertiser.',
    'Medya maliyeti üzerine markup. Kâr = harcama x margin%. DV360\'ta '
        'partner/advertiser üzerinde ayarladığın margin budur.',
  ),
  'realBudget': const _Help(
    'The real (client/sold) budget — what the client is billed. The app '
        'computes margin from this minus your spend.',
    'Gerçek (müşteri/satılan) bütçe — müşteriye faturalanan. Uygulama '
        'margin\'i bundan harcamayı çıkararak hesaplar.',
  ),
  'targetMargin': const _Help(
    'The margin % you want to keep. Used to suggest how much media to spend: '
        'spend = real budget x (1 - margin%).',
    'Korumak istediğin margin %. Önerilen medya harcamasını hesaplamak için '
        'kullanılır: harcama = gerçek bütçe x (1 - margin%).',
  ),
  'dates': const _Help(
    'Flight start and end. Pacing and the “ending soon” reminders use these.',
    'Yayın başlangıç ve bitişi. Pacing ve "bitişe yakın" hatırlatmaları '
        'bunları kullanır.',
  ),
  'status': const _Help(
    'Active, Paused, Ended or Draft. Campaigns past their end date move to '
        'Ended automatically.',
    'Aktif, Duraklatıldı, Bitti veya Taslak. Bitiş tarihi geçenler otomatik '
        'olarak Bitti olur.',
  ),

  // ---- Daily entry ----
  'spend': _Help(
    'Media cost for this day (your buying cost).',
    'Bu güne ait medya maliyeti (satın alma maliyetin).',
    _spend,
  ),
  'impressions': _Help(
    'Times the ad was shown this day.',
    'Reklamın bu gün kaç kez gösterildiği.',
    _impr,
  ),
  'clicks': _Help(
    'Clicks this day. Used for CTR and CPC.',
    'Bu günkü tıklamalar. CTR ve CPC için kullanılır.',
    _clicks,
  ),
  'conversions': _Help(
    'Actions/conversions this day. Used for CPA.',
    'Bu günkü aksiyon/dönüşümler. CPA için kullanılır.',
    _conv,
  ),
  'views': _Help(
    'Video views this day. Used for VTR and CPV.',
    'Bu günkü video izlenmeleri. VTR ve CPV için kullanılır.',
    _views,
  ),
  'completedViews': _Help(
    'Views watched to 100%. Used for CPCV and VCR.',
    '%100 izlenen görüntülemeler. CPCV ve VCR için kullanılır.',
    _completed,
  ),
  'viewableImpressions': _Help(
    'Impressions counted as viewable. Used for viewability % and vCPM.',
    'Görüntülenebilir sayılan gösterimler. Viewability % ve vCPM için.',
    _viewable,
  ),
  'revenue': _Help(
    'Revenue/value attributed this day. Used for ROAS.',
    'Bu güne atfedilen gelir/değer. ROAS için kullanılır.',
    _revenue,
  ),
  'dailyMargin': const _Help(
    'Override the margin % just for this day (optional). Leave empty to use '
        'the campaign default.',
    'Sadece bu gün için margin % değiştir (opsiyonel). Boş bırakırsan '
        'kampanya varsayılanı kullanılır.',
  ),
};

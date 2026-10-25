// Seed content for the knowledge base (how-to guides + metric definitions).
// Provided in English and Turkish. Bodies are plain text with line breaks.

const List<Map<String, Object?>> kbSeed = [
  // ---------------------------- ENGLISH ----------------------------------
  {
    'lang': 'en',
    'category': 'Getting started',
    'title': 'How to add a campaign',
    'body': '1. Go to the Campaigns tab and tap the + button.\n'
        '2. Enter the name, client and platform (DV360, Amazon DSP, Adform, '
        'TikTok, Meta...).\n'
        '3. Pick the pricing type (CPM, CPV, CPC, CPCV, CPA or Flat). This '
        'decides which metric the app shows for the campaign.\n'
        '4. Set the total budget, start/end dates and the default margin %.\n'
        '5. Save. The campaign now appears in the list with its key metric.',
  },
  {
    'lang': 'en',
    'category': 'Getting started',
    'title': 'How to log daily numbers',
    'body': 'Open a campaign and tap "Add daily entry".\n'
        'Enter what you have for that day: spend, impressions, views, clicks, '
        'conversions and (optionally) the margin %.\n'
        'The app calculates CPM / CPV / CPC / CTR automatically and stores the '
        'day in the history so you can track the trend over time.',
  },
  {
    'lang': 'en',
    'category': 'Metrics',
    'title': 'CPM, CPV, CPC, CPCV, CPA explained',
    'body': 'CPM = cost per 1000 impressions = spend / impressions x 1000.\n'
        'CPV = cost per view = spend / views.\n'
        'CPC = cost per click = spend / clicks.\n'
        'CPCV = cost per completed view = spend / completed views.\n'
        'CPA = cost per acquisition = spend / conversions.\n'
        'CTR = click-through rate = clicks / impressions x 100.\n\n'
        'Use the Tools tab to calculate any of these quickly.',
  },
  {
    'lang': 'en',
    'category': 'Metrics',
    'title': 'Understanding pacing',
    'body': 'Pacing compares how much you have spent against how much you '
        'should have spent by today.\n\n'
        'Expected spend = total budget x (days elapsed / total days).\n'
        '- Underpacing: actual is below 80% of expected. Action: raise '
        'budget/bid or widen targeting.\n'
        '- Overpacing: actual is above 110% of expected. Action: the budget '
        'will run out early; lower the daily cap.\n'
        '- On track: within range, no action needed.\n\n'
        'The app also projects the date your budget runs out at the current '
        'spend rate.',
  },
  {
    'lang': 'en',
    'category': 'Metrics',
    'title': 'Margin and profit',
    'body': 'Profit = spend x margin %.\n'
        'Set a default margin on the campaign, or override it per day when you '
        'log numbers. The campaign detail and the dashboards add this up so '
        'you can see profit per campaign and per client.',
  },
  {
    'lang': 'en',
    'category': 'Workflow',
    'title': 'The morning reminder',
    'body': 'Every day at 09:00 the app sends a notification summarising what '
        'needs attention: campaigns ending soon, pacing problems and tasks due '
        'today. Tap it to open the Today tab.\n\n'
        'For this to fire while the app is closed, allow notifications and '
        '(on some phones) disable battery optimisation for the app.',
  },
  {
    'lang': 'en',
    'category': 'Workflow',
    'title': 'Attaching ordino and creatives',
    'body': 'Open a campaign and use the Files section to attach the ordino '
        '(insertion order), creatives or any other document. Files are copied '
        'into the app storage and can be reopened any time.',
  },

  // ---------------------------- TURKISH ----------------------------------
  {
    'lang': 'tr',
    'category': 'Başlangıç',
    'title': 'Kampanya nasıl eklenir',
    'body': '1. Kampanyalar sekmesine gidin ve + butonuna dokunun.\n'
        '2. Ad, müşteri ve platformu girin (DV360, Amazon DSP, Adform, '
        'TikTok, Meta...).\n'
        '3. Yayın/fiyatlama tipini seçin (CPM, CPV, CPC, CPCV, CPA veya '
        'Sabit). Bu seçim, uygulamanın o kampanya için hangi metriği '
        'göstereceğini belirler.\n'
        '4. Toplam bütçe, başlangıç/bitiş tarihleri ve varsayılan margin % '
        'değerini girin.\n'
        '5. Kaydedin. Kampanya artık listede ana metriğiyle görünür.',
  },
  {
    'lang': 'tr',
    'category': 'Başlangıç',
    'title': 'Günlük veriler nasıl girilir',
    'body': 'Bir kampanyayı açıp "Günlük giriş ekle"ye dokunun.\n'
        'O güne ait elinizdeki verileri girin: harcama, impression, izlenme, '
        'tıklama, dönüşüm ve (isteğe bağlı) margin %.\n'
        'Uygulama CPM / CPV / CPC / CTR değerlerini otomatik hesaplar ve günü '
        'geçmişe kaydeder; böylece zaman içindeki trendi takip edebilirsiniz.',
  },
  {
    'lang': 'tr',
    'category': 'Metrikler',
    'title': 'CPM, CPV, CPC, CPCV, CPA nedir',
    'body': 'CPM = bin gösterim başına maliyet = harcama / impression x 1000.\n'
        'CPV = izlenme başına maliyet = harcama / izlenme.\n'
        'CPC = tıklama başına maliyet = harcama / tıklama.\n'
        'CPCV = tamamlanan izlenme başına maliyet = harcama / tamamlanan '
        'izlenme.\n'
        'CPA = edinim başına maliyet = harcama / dönüşüm.\n'
        'CTR = tıklama oranı = tıklama / impression x 100.\n\n'
        'Bunları hızlıca hesaplamak için Araçlar sekmesini kullanın.',
  },
  {
    'lang': 'tr',
    'category': 'Metrikler',
    'title': 'Pacing (harcama hızı) nedir',
    'body': 'Pacing, bugüne kadar ne harcamanız gerektiğiyle gerçekte ne '
        'harcadığınızı karşılaştırır.\n\n'
        'Beklenen harcama = toplam bütçe x (geçen gün / toplam gün).\n'
        '- Underpacing: gerçek harcama beklenenin %80\'inin altında. Aksiyon: '
        'bütçeyi/teklifi artır veya hedeflemeyi genişlet.\n'
        '- Overpacing: gerçek harcama beklenenin %110\'unun üstünde. Aksiyon: '
        'bütçe erken biter; günlük limiti düşür.\n'
        '- Yolunda: aralıkta, aksiyon gerekmez.\n\n'
        'Uygulama ayrıca mevcut harcama hızıyla bütçenin biteceği tarihi '
        'tahmin eder.',
  },
  {
    'lang': 'tr',
    'category': 'Metrikler',
    'title': 'Margin ve kâr',
    'body': 'Kâr = harcama x margin %.\n'
        'Kampanyaya varsayılan bir margin atayın veya günlük veri girerken o '
        'güne özel değiştirin. Kampanya detayı ve panolar bunu toplar; böylece '
        'kampanya ve müşteri bazında kârı görebilirsiniz.',
  },
  {
    'lang': 'tr',
    'category': 'İş akışı',
    'title': 'Sabah hatırlatması',
    'body': 'Uygulama her gün saat 09:00\'da bir bildirim göndererek dikkat '
        'gerektirenleri özetler: bitişe yakın kampanyalar, pacing sorunları ve '
        'bugün son tarihli görevler. Bildirime dokunarak Bugün sekmesini '
        'açabilirsiniz.\n\n'
        'Uygulama kapalıyken de çalışması için bildirimlere izin verin ve bazı '
        'telefonlarda uygulama için pil optimizasyonunu kapatın.',
  },
  {
    'lang': 'tr',
    'category': 'İş akışı',
    'title': 'Ordino ve kreatif ekleme',
    'body': 'Bir kampanyayı açıp Dosyalar bölümünden ordino, kreatifler veya '
        'başka bir belge ekleyin. Dosyalar uygulama deposuna kopyalanır ve '
        'istediğiniz zaman tekrar açılabilir.',
  },

  {
    'lang': 'en',
    'category': 'Workflow',
    'title': 'Your daily check-in',
    'body': 'Do this once a day, per active campaign, until it ends:\n\n'
        '1. Open the platform and read yesterday/today numbers (spend, '
        'impressions, the metric you buy on).\n'
        '2. In this app open the campaign and tap “Add data”.\n'
        '3. Enter the day\'s spend and delivery numbers. CPM/CPV/CPCV etc. '
        'are calculated for you and added to the history.\n'
        '4. Check the pacing gauge — the dark tick is where you should be '
        'today. Fill behind the tick = underpacing, ahead = overpacing.\n\n'
        'The Today tab reminds you each morning of any active campaign that '
        'still needs today\'s entry, so nothing slips.',
  },
  {
    'lang': 'en',
    'category': 'Workflow',
    'title': 'How to pull a report',
    'body': 'GENERAL FLOW (same idea on every platform)\n'
        '1. Open the platform\'s Reporting / Reports section.\n'
        '2. Pick the level (campaign, line item / ad set, creative).\n'
        '3. Set the date range (yesterday, last 7 days, flight-to-date).\n'
        '4. Choose dimensions (date, placement, device) and metrics '
        '(impressions, clicks, spend, CTR, conversions, viewability).\n'
        '5. Run it, then Export to CSV/Sheets or schedule a recurring email.\n\n'
        'WHERE ON EACH PLATFORM\n'
        '- DV360: Reports > Offline reporting (scheduled) or Instant '
        'Reporting (ad-hoc).\n'
        '- Amazon DSP: the reporting console / dashboard, by Line Item or '
        'Creative.\n'
        '- TikTok: Reporting > Custom Reports.\n'
        '- Meta: Ads Manager columns + Breakdowns, or Ads Reporting.\n'
        '- Adform: Report Builder (drag-and-drop) + dashboards.\n\n'
        'Tip: pull the same report at the same time each day so day-over-day '
        'numbers are comparable.',
  },
  {
    'lang': 'en',
    'category': 'Workflow',
    'title': 'Margin: how to calculate & pull it',
    'body': 'TWO COMMON MODELS\n'
        '- Markup on cost: client pays media cost + a markup. '
        'Profit = media cost x markup%. (This is what this app\'s “margin %” '
        'field does: profit = spend x margin%.)\n'
        '- Margin on revenue: margin% = (revenue - cost) / revenue. '
        'If you bill the client R and buy media at cost C, '
        'margin% = (R - C) / R x 100.\n\n'
        'HOW TO PULL IT\n'
        '1. Get media cost from the platform report (spend).\n'
        '2. Get what the client is billed (your rate card / IO sell price).\n'
        '3. Profit = revenue - cost. Margin% = profit / revenue x 100.\n\n'
        'IN THIS APP\n'
        'Set a default margin % on the campaign, or override it per day in '
        'the daily entry. Profit is summed on the campaign and shown in the '
        'metrics card. Gross margin ignores ad-serving/tech fees; track '
        'those separately if you need net.',
  },
  {
    'lang': 'en',
    'category': 'Metrics',
    'title': 'Video & YouTube metrics',
    'body': 'VTR (view rate) = views / impressions x 100.\n'
        'VCR (video completion rate) = completed views / views x 100.\n'
        'CPV = cost per view = spend / views.\n'
        'CPCV = cost per completed view = spend / completed views.\n'
        'Viewability = viewable impressions / impressions x 100.\n'
        'vCPM = cost per 1000 viewable impressions.\n'
        'ROAS = revenue / spend (e.g. 3.0x).\n\n'
        'YouTube/TrueView is usually bought on CPV (skippable in-stream) or '
        'CPM; pick that as the campaign\'s pricing type so the app shows the '
        'right headline metric. Enter completed views to get CPCV/VCR, and '
        'viewable impressions to get viewability/vCPM.',
  },

  // ====================== PLATFORM HOW-TOs (EN) ==========================
  {
    'lang': 'en',
    'category': 'Platforms',
    'title': 'DV360: create & track a campaign',
    'body': 'STRUCTURE\n'
        'Partner > Advertiser > Campaign > Insertion Order (IO) > Line Item '
        '> Creative. The campaign sets the goal; the IO sets budget, pacing '
        'and frequency caps; the line item holds targeting, bidding and '
        'creatives.\n\n'
        'CREATE & LAUNCH\n'
        '1. Sign in at displayvideo.google.com and select your Advertiser.\n'
        '2. Left menu > Campaign > New campaign. Set goal (awareness / online '
        'action / offline sales / app installs), KPI, dates and frequency cap.\n'
        '3. Inside it: New > Insertion order. Pick the IO objective, budget '
        'and pacing.\n'
        '4. New > Line item under that IO: set targeting (audience, geo, '
        'device, inventory), bid strategy/budget, and assign creatives.\n'
        '5. Set status Active on line item + IO + campaign (review applies).\n\n'
        'TRACK\n'
        'Use Instant Reporting for quick ad-hoc views and Reports (Offline '
        'reporting) for scheduled reports. Watch impressions, clicks, CTR, '
        'media cost, conversions, CPM/CPA.',
  },
  {
    'lang': 'en',
    'category': 'Platforms',
    'title': 'Amazon DSP: create & track a campaign',
    'body': 'STRUCTURE\n'
        'Entity > Advertiser > Order > Line Item > Creative. The Order is the '
        '“campaign” (objective, budget, flight). Line Items carry audiences, '
        'supply, bids, frequency caps and creatives.\n\n'
        'ACCESS\n'
        'Amazon DSP is self-service (via an Amazon-certified agency) or '
        'managed-service, usually with spend minimums. Log into the DSP '
        'console under your Advertiser.\n\n'
        'CREATE & LAUNCH\n'
        '1. Create an Order: objective, total budget, flight dates, KPIs.\n'
        '2. Add Line Items: choose type, set supply/inventory (Amazon.com, '
        'Fire TV, Twitch, IMDb, third-party exchanges), device, viewability, '
        'base/max bid and frequency cap.\n'
        '3. Audiences: Amazon first-party (in-market, lifestyle, '
        'remarketing, demographics) plus your own segments.\n'
        '4. Creatives: upload per line item; they pass Amazon policy review.\n'
        '5. Submit — line items go to review before serving.\n\n'
        'TRACK\n'
        'Use the DSP reporting console. View by Goal, Audience, Line Item, '
        'Creative, Product. Key metrics: impressions, reach, frequency, '
        'viewability, CTR, DPVR, ATC, purchases, ROAS, CPA, NTB, eCPM.',
  },
  {
    'lang': 'en',
    'category': 'Platforms',
    'title': 'TikTok Ads: create & track a campaign',
    'body': 'STRUCTURE\n'
        'Campaign (objective) > Ad Group (targeting, placements, budget, '
        'schedule, bidding) > Ad (creative). Objectives sit under Awareness, '
        'Consideration and Conversion (Reach, Video Views, Traffic, App '
        'Promotion, Lead Generation, Website/Product Sales, etc.).\n\n'
        'CREATE & LAUNCH\n'
        '1. Log in at ads.tiktok.com (Business account) and click Create.\n'
        '2. Campaign: pick the objective; optionally turn on Campaign Budget '
        'Optimization (CBO) to budget at campaign level.\n'
        '3. Ad Group: placements (or Automatic), audience (location, age, '
        'interests, behaviors, Custom/Lookalike), budget, schedule, '
        'optimization goal and bidding (start with lowest cost / automatic).\n'
        '4. Ad: format (single video, carousel, Spark Ad), upload creative, '
        'set identity, text and CTA.\n'
        '5. Submit — ads enter review before going live.\n\n'
        'TRACK\n'
        'The campaign Dashboard shows spend, impressions, clicks, CTR, CPC, '
        'conversions, CPA, ROAS. Use Customize Columns for CPM/CVR and '
        'Reporting > Custom Reports for deeper analysis and scheduled exports.',
  },
  {
    'lang': 'en',
    'category': 'Platforms',
    'title': 'Meta Ads: create & track a campaign',
    'body': 'STRUCTURE\n'
        'Campaign (objective) > Ad Set (audience, placements, budget, '
        'schedule) > Ad (creative). Under ODAX there are six objectives: '
        'Awareness, Traffic, Engagement, Leads, App promotion, Sales.\n\n'
        'CREATE & LAUNCH\n'
        '1. Log in to Ads Manager at business.facebook.com and click Create.\n'
        '2. Pick an objective; keep the Auction buying type.\n'
        '3. Campaign level: optionally toggle Advantage campaign budget '
        '(former CBO) to share one budget across ad sets, or budget per ad '
        'set (ABO).\n'
        '4. Ad Set: audience (or Advantage+ audience), placements '
        '(Advantage+ recommended), daily/lifetime budget and schedule.\n'
        '5. Ad: format (single image, video, carousel), creative, primary '
        'text, headline, destination URL/CTA.\n'
        '6. Publish — the ad goes to Review.\n\n'
        'TRACK\n'
        'Use the Ads Manager table. Columns dropdown (Performance, '
        'Engagement, custom sets) and Breakdowns (age, gender, placement, '
        'time, region). Ads Reporting for pivot reports. Key metrics: CPM, '
        'CPC, CTR, CPA, ROAS.',
  },
  {
    'lang': 'en',
    'category': 'Platforms',
    'title': 'Adform: create & track a campaign',
    'body': 'STRUCTURE\n'
        'Advertiser > Campaign > Order > Line Item > Ad. The campaign sets '
        'goal, schedule, budget and brand-safety; orders group line items; '
        'line items hold buying strategy, budget, targeting and channel.\n\n'
        'CREATE & LAUNCH\n'
        '1. Log in to Adform Flow and open the DSP. (Optionally use the '
        'Campaign Planner under Campaigns for goal-based setup and KPI '
        'forecasts.)\n'
        '2. Create a Campaign: goal, flight dates, budget, brand-safety.\n'
        '3. Add an Order to group your buying.\n'
        '4. Create Line Items: buying strategy, budget, flight, frequency '
        'cap, channels (display, video, CTV, audio, DOOH, in-app).\n'
        '5. Targeting: geo, device, contextual, Adform audiences/segments, '
        'deal IDs, Signal targeting.\n'
        '6. Attach creatives/banners to the line items, then activate.\n\n'
        'TRACK\n'
        'Use Report Builder for custom drag-and-drop reports and dashboards '
        'for live monitoring. Key metrics: impressions, clicks, CTR, '
        'viewability, conversions, eCPA, video completion rate.',
  },

  {
    'lang': 'tr',
    'category': 'İş akışı',
    'title': 'Günlük kontrol rutinin',
    'body': 'Her aktif kampanya için, kampanya bitene kadar günde bir kez:\n\n'
        '1. Platformu aç, dünün/bugünün rakamlarını oku (harcama, '
        'impression, hangi metrikten satın aldıysan onu).\n'
        '2. Bu uygulamada kampanyayı açıp “Veri gir”e dokun.\n'
        '3. O günün harcama ve yayın rakamlarını gir. CPM/CPV/CPCV vb. senin '
        'için hesaplanır ve geçmişe eklenir.\n'
        '4. Pacing göstergesine bak — koyu çizgi bugün olman gereken yer. '
        'Dolgu çizginin gerisindeyse underpacing, ilerisindeyse overpacing.\n\n'
        'Bugün sekmesi her sabah, hâlâ bugünün girişi yapılmamış aktif '
        'kampanyaları hatırlatır; böylece hiçbiri atlanmaz.',
  },
  {
    'lang': 'tr',
    'category': 'İş akışı',
    'title': 'Nasıl rapor çekilir',
    'body': 'GENEL AKIŞ (her platformda aynı mantık)\n'
        '1. Platformun Reporting / Raporlar bölümünü aç.\n'
        '2. Seviyeyi seç (kampanya, line item / ad set, kreatif).\n'
        '3. Tarih aralığını ayarla (dün, son 7 gün, başlangıçtan bugüne).\n'
        '4. Boyutları (tarih, placement, cihaz) ve metrikleri (impression, '
        'tıklama, harcama, CTR, dönüşüm, viewability) seç.\n'
        '5. Çalıştır, sonra CSV/Sheets olarak dışa aktar ya da tekrarlayan '
        'e-posta planla.\n\n'
        'HANGİ PLATFORMDA NEREDE\n'
        '- DV360: Reports > Offline reporting (planlı) veya Instant '
        'Reporting (anlık).\n'
        '- Amazon DSP: raporlama konsolu / dashboard, Line Item veya '
        'Creative bazında.\n'
        '- TikTok: Reporting > Custom Reports.\n'
        '- Meta: Ads Manager kolonları + Breakdowns ya da Ads Reporting.\n'
        '- Adform: Report Builder (sürükle-bırak) + dashboard\'lar.\n\n'
        'İpucu: aynı raporu her gün aynı saatte çek ki günler karşılaştırılabilir olsun.',
  },
  {
    'lang': 'tr',
    'category': 'İş akışı',
    'title': 'Margin: nasıl hesaplanır ve çekilir',
    'body': 'İKİ YAYGIN MODEL\n'
        '- Maliyet üzerine markup: müşteri medya maliyeti + markup öder. '
        'Kâr = medya maliyeti x markup%. (Bu uygulamadaki “margin %” alanı '
        'bunu yapar: kâr = harcama x margin%.)\n'
        '- Gelir üzerinden margin: margin% = (gelir - maliyet) / gelir. '
        'Müşteriye R faturalayıp medyayı C maliyetine aldıysan '
        'margin% = (R - C) / R x 100.\n\n'
        'NASIL ÇEKİLİR\n'
        '1. Medya maliyetini platform raporundan al (harcama).\n'
        '2. Müşteriye faturalananı al (rate card / IO satış fiyatı).\n'
        '3. Kâr = gelir - maliyet. Margin% = kâr / gelir x 100.\n\n'
        'BU UYGULAMADA\n'
        'Kampanyaya varsayılan margin % ata ya da günlük girişte o güne '
        'özel değiştir. Kâr kampanyada toplanır ve metrik kartında görünür. '
        'Brüt margin ad-serving/teknoloji ücretlerini saymaz; net lazımsa '
        'onları ayrı takip et.',
  },
  {
    'lang': 'tr',
    'category': 'Metrikler',
    'title': 'Video & YouTube metrikleri',
    'body': 'VTR (izlenme oranı) = izlenme / impression x 100.\n'
        'VCR (video tamamlanma oranı) = tamamlanan izlenme / izlenme x 100.\n'
        'CPV = izlenme başına maliyet = harcama / izlenme.\n'
        'CPCV = tamamlanan izlenme başına maliyet = harcama / tamamlanan '
        'izlenme.\n'
        'Viewability = görüntülenebilir gösterim / gösterim x 100.\n'
        'vCPM = bin görüntülenebilir gösterim başına maliyet.\n'
        'ROAS = gelir / harcama (örn. 3.0x).\n\n'
        'YouTube/TrueView genelde CPV (atlanabilir in-stream) veya CPM ile '
        'alınır; kampanyanın fiyatlama tipini ona göre seç ki uygulama doğru '
        'ana metriği göstersin. CPCV/VCR için tamamlanan izlenmeyi, '
        'viewability/vCPM için görüntülenebilir gösterimi gir.',
  },

  // ====================== PLATFORM HOW-TOs (TR) ==========================
  {
    'lang': 'tr',
    'category': 'Platformlar',
    'title': 'DV360: kampanya açma ve takip',
    'body': 'YAPI\n'
        'Partner > Advertiser > Campaign > Insertion Order (IO) > Line Item '
        '> Kreatif. Kampanya hedefi belirler; IO bütçe, pacing ve frequency '
        'cap ayarlar; line item hedefleme, teklif ve kreatifleri tutar.\n\n'
        'OLUŞTUR & YAYINLA\n'
        '1. displayvideo.google.com\'a girip Advertiser\'ı seçin.\n'
        '2. Sol menü > Campaign > New campaign. Hedefi (awareness / online '
        'action / offline sales / app installs), KPI, tarihler ve frequency '
        'cap girin.\n'
        '3. İçinde: New > Insertion order. IO hedefini, bütçe ve pacing\'i '
        'ayarlayın.\n'
        '4. O IO altında New > Line item: hedefleme (audience, coğrafya, '
        'cihaz, envanter), teklif stratejisi/bütçe ve kreatifleri atayın.\n'
        '5. Durumu line item + IO + kampanyada Active yapın (onay süreci '
        'vardır).\n\n'
        'TAKİP\n'
        'Hızlı bakış için Instant Reporting, planlı raporlar için Reports '
        '(Offline reporting). İzlenecekler: impression, tıklama, CTR, medya '
        'maliyeti, dönüşüm, CPM/CPA.',
  },
  {
    'lang': 'tr',
    'category': 'Platformlar',
    'title': 'Amazon DSP: kampanya açma ve takip',
    'body': 'YAPI\n'
        'Entity > Advertiser > Order > Line Item > Kreatif. Order = '
        '“kampanya” (hedef, bütçe, tarih aralığı). Line Item\'lar audience, '
        'envanter, teklif, frequency cap ve kreatifleri taşır.\n\n'
        'ERİŞİM\n'
        'Amazon DSP self-service (Amazon onaylı bir ajans üzerinden) ya da '
        'managed-service\'tir; genelde minimum harcama şartı vardır. '
        'Advertiser\'ınız altında DSP konsoluna girin.\n\n'
        'OLUŞTUR & YAYINLA\n'
        '1. Order oluştur: hedef, toplam bütçe, tarih aralığı, KPI.\n'
        '2. Line Item ekle: tip seç, supply/envanter (Amazon.com, Fire TV, '
        'Twitch, IMDb, 3. taraf borsalar), cihaz, viewability, base/max '
        'teklif ve frequency cap.\n'
        '3. Audience: Amazon first-party (in-market, lifestyle, remarketing, '
        'demografi) + kendi segmentlerin.\n'
        '4. Kreatif: line item başına yükle; Amazon politika onayından '
        'geçer.\n'
        '5. Gönder — line item\'lar yayından önce incelemeye gider.\n\n'
        'TAKİP\n'
        'DSP raporlama konsolu. Goal, Audience, Line Item, Creative, Product '
        'kırılımları. Metrikler: impression, reach, frequency, viewability, '
        'CTR, DPVR, ATC, satın alma, ROAS, CPA, NTB, eCPM.',
  },
  {
    'lang': 'tr',
    'category': 'Platformlar',
    'title': 'TikTok Ads: kampanya açma ve takip',
    'body': 'YAPI\n'
        'Campaign (hedef) > Ad Group (hedefleme, placement, bütçe, takvim, '
        'teklif) > Ad (kreatif). Hedefler Awareness, Consideration ve '
        'Conversion altında (Reach, Video Views, Traffic, App Promotion, '
        'Lead Generation, Website/Product Sales vb.).\n\n'
        'OLUŞTUR & YAYINLA\n'
        '1. ads.tiktok.com\'a (Business hesabı) girip Create\'e tıklayın.\n'
        '2. Campaign: hedefi seç; istersen Campaign Budget Optimization '
        '(CBO) ile bütçeyi kampanya seviyesinde ver.\n'
        '3. Ad Group: placement (veya Automatic), audience (konum, yaş, '
        'ilgi, davranış, Custom/Lookalike), bütçe, takvim, optimizasyon '
        'hedefi ve teklif (lowest cost / otomatik ile başla).\n'
        '4. Ad: format (tek video, carousel, Spark Ad), kreatif yükle, '
        'identity, metin ve CTA.\n'
        '5. Gönder — reklamlar yayından önce incelemeye girer.\n\n'
        'TAKİP\n'
        'Kampanya Dashboard\'u harcama, impression, tıklama, CTR, CPC, '
        'dönüşüm, CPA, ROAS gösterir. CPM/CVR için Customize Columns; daha '
        'derin analiz için Reporting > Custom Reports.',
  },
  {
    'lang': 'tr',
    'category': 'Platformlar',
    'title': 'Meta Ads: kampanya açma ve takip',
    'body': 'YAPI\n'
        'Campaign (hedef) > Ad Set (audience, placement, bütçe, takvim) > '
        'Ad (kreatif). ODAX altında altı hedef: Awareness, Traffic, '
        'Engagement, Leads, App promotion, Sales.\n\n'
        'OLUŞTUR & YAYINLA\n'
        '1. business.facebook.com\'da Ads Manager\'a girip Create\'e '
        'tıklayın.\n'
        '2. Hedefi seç; Auction satın alma tipini koru.\n'
        '3. Kampanya seviyesi: tek bütçeyi ad set\'lere dağıtmak için '
        'Advantage campaign budget (eski CBO) aç ya da ad set başına bütçe '
        '(ABO) ver.\n'
        '4. Ad Set: audience (veya Advantage+ audience), placement '
        '(Advantage+ önerilir), günlük/lifetime bütçe ve takvim.\n'
        '5. Ad: format (tek görsel, video, carousel), kreatif, ana metin, '
        'başlık, hedef URL/CTA.\n'
        '6. Publish — reklam Review\'a gider.\n\n'
        'TAKİP\n'
        'Ads Manager tablosu. Columns (Performance, Engagement, özel setler) '
        've Breakdowns (yaş, cinsiyet, placement, zaman, bölge). Pivot '
        'raporlar için Ads Reporting. Metrikler: CPM, CPC, CTR, CPA, ROAS.',
  },
  {
    'lang': 'tr',
    'category': 'Platformlar',
    'title': 'Adform: kampanya açma ve takip',
    'body': 'YAPI\n'
        'Advertiser > Campaign > Order > Line Item > Ad. Kampanya hedef, '
        'takvim, bütçe ve brand-safety belirler; order\'lar line item\'ları '
        'gruplar; line item\'lar satın alma stratejisi, bütçe, hedefleme ve '
        'kanalı tutar.\n\n'
        'OLUŞTUR & YAYINLA\n'
        '1. Adform Flow\'a girip DSP\'yi açın. (İsteğe bağlı: Campaigns '
        'altındaki Campaign Planner ile hedef bazlı kurulum ve KPI '
        'tahmini.)\n'
        '2. Campaign oluştur: hedef, tarih aralığı, bütçe, brand-safety.\n'
        '3. Satın almayı gruplamak için bir Order ekle.\n'
        '4. Line Item oluştur: satın alma stratejisi, bütçe, tarih, '
        'frequency cap, kanallar (display, video, CTV, audio, DOOH, '
        'in-app).\n'
        '5. Hedefleme: coğrafya, cihaz, contextual, Adform audience/segment, '
        'deal ID, Signal targeting.\n'
        '6. Kreatif/banner\'ları line item\'lara ekle, sonra aktive et.\n\n'
        'TAKİP\n'
        'Özel raporlar için Report Builder (sürükle-bırak), canlı izleme '
        'için dashboard\'lar. Metrikler: impression, tıklama, CTR, '
        'viewability, dönüşüm, eCPA, video tamamlanma oranı.',
  },

  // ================= EXTRA HOW-TOs (EN) =================
  {
    'lang': 'en',
    'category': 'Workflow',
    'title': 'A campaign is not spending — how to fix it',
    'body': 'When a line item under-delivers (spend is behind pacing), work '
        'through these levers, biggest first:\n\n'
        '1. PACING: switch pacing to ASAP (or raise the daily cap) so the '
        'system front-loads delivery instead of spreading it evenly.\n'
        '2. BID: raise the bid / max CPM. A low bid loses auctions, so you '
        'win too few impressions. Raise it step by step and watch win rate.\n'
        '3. TARGETING: broaden it — add audiences, geos, devices, more '
        'inventory/exchanges, and loosen or remove the frequency cap.\n'
        '4. BUDGET: confirm the budget/flight actually allows the needed '
        'daily spend (remaining budget / days left).\n'
        '5. CREATIVE/FORMATS: enable more sizes/placements so there is more '
        'inventory to buy.\n\n'
        'PLATFORM NOTES\n'
        '- DV360: raising the bid wins more auctions, but a higher media CPM '
        'eats your markup. To keep delivering AND protect price, you can '
        'lower the markup so more of the client budget funds a higher media '
        'bid (you trade some margin for delivery). Also try pacing ASAP, '
        'Optimized targeting, more exchanges and a higher/!no frequency cap.\n'
        '- Amazon DSP: raise base/max bid, add supply (more exchanges, O&O '
        'like Fire TV / Twitch / Amazon.com), broaden audiences and lift the '
        'frequency cap.\n'
        '- TikTok/Meta: if using lowest-cost and it still under-spends, the '
        'bid is effectively too low for the audience — widen the audience, '
        'add placements (Advantage+/Automatic), or switch to a bid cap set '
        'a bit higher.',
  },
  {
    'lang': 'en',
    'category': 'Platforms',
    'title': 'DV360: bid up / markup down to spend more',
    'body': 'THE IDEA\n'
        'Your client budget = media cost + your markup. If a line item is '
        'under-delivering you usually need to bid higher to win more '
        'auctions — but a higher media CPM eats into your markup.\n\n'
        'THE TACTIC\n'
        '- Raise the bid (or max CPM) so you win more impressions and spend '
        'picks up.\n'
        '- To fund that higher bid without blowing the price you sold, lower '
        'the markup %. More of the client budget now goes to media, so you '
        'can bid higher and still respect the client price. You trade a bit '
        'of margin for delivery.\n'
        '- Combine with pacing = ASAP, Optimized targeting, more exchanges '
        'and a looser frequency cap.\n\n'
        'WATCH\n'
        'Keep an eye on win rate and the resulting media CPM. Raise the bid '
        'in small steps; stop when delivery is on track so you give up the '
        'least margin needed. (DV360 has this markup logic built in, so you '
        'do NOT manually shrink the entered budget the way you do on Amazon.)',
  },
  {
    'lang': 'en',
    'category': 'Platforms',
    'title': 'Amazon DSP: set the budget to protect your margin',
    'body': 'Amazon DSP has no markup field like DV360 — whatever budget you '
        'enter is the media it will try to spend. So you must enter a '
        'budget that already leaves your margin out.\n\n'
        'DO THE MATH BEFORE LAUNCH\n'
        'Media budget to enter = client budget x (1 - target margin%).\n'
        'Example: client pays 100,000 and you want 25% margin →\n'
        'enter 100,000 x (1 - 0.25) = 75,000 as the Order/Line Item budget.\n'
        'The remaining 25,000 is your margin.\n\n'
        'IN THIS APP\n'
        'For non-DV360 campaigns, enter the client (real) budget and your '
        'target margin on the campaign form; the app shows a suggested spend '
        '(media budget) using exactly this formula — use that number as the '
        'Amazon budget. Then track actual spend against it daily.',
  },
  {
    'lang': 'en',
    'category': 'Platforms',
    'title': 'Smartly: combine & balance Meta + TikTok budgets',
    'body': 'WHAT IT IS\n'
        'Smartly is a cross-channel ad management tool. You connect your '
        'Meta and TikTok ad accounts and manage, automate and report on '
        'them from one place.\n\n'
        'COMBINING BUDGETS\n'
        'Instead of fixing a separate budget on Meta and another on TikTok '
        '(where one often overspends while the other lags), put the ad sets '
        'from both platforms into a Smartly budget/optimization group with '
        'ONE shared budget. Smartly then shifts spend toward whatever is '
        'performing and keeps the total on pace.\n\n'
        'BALANCING SO ONE DOES NOT STARVE THE OTHER\n'
        '- Set the shared budget and the optimization goal (e.g. lowest CPA '
        '/ best ROAS / cost per ThruPlay).\n'
        '- Use min/max spend caps per platform or per ad set so neither Meta '
        'nor TikTok can take everything or drop to zero.\n'
        '- Let it optimize on a stable window (avoid reacting to one bad '
        'hour); review daily and adjust the caps if the split drifts.\n\n'
        'RESULT: one budget, automatically balanced between Meta and TikTok '
        'toward your KPI, instead of two budgets you babysit by hand.',
  },
  {
    'lang': 'en',
    'category': 'Metrics',
    'title': 'ThruPlay & engaged video views',
    'body': 'META — THRUPLAY\n'
        'A ThruPlay counts when your video is played to completion, or for '
        'at least 15 seconds (whichever comes first). On Meta it is both an '
        'optimization goal and a billing event for video. '
        'CPV (ThruPlay) = spend / ThruPlays.\n\n'
        'TIKTOK — THE EQUIVALENT\n'
        'TikTok\'s engaged-view billing is Focused View (a view of 6 seconds '
        'or with an interaction). For a 15-second-style watch, TikTok '
        'reporting has "watched to the end" and time-based view metrics '
        '(e.g. 6s/15s video views). So Meta ThruPlay (15s/complete) and '
        'TikTok\'s 6s Focused View are the closest engaged-view counterparts '
        '— not identical, so compare them as "qualified views", not 1:1.\n\n'
        'TIP: use the CPV (ThruPlay) calculator in the Tools tab to get '
        'cost per ThruPlay / qualified view, and buy/optimize video on this '
        'rather than raw impressions when the goal is real watch time.',
  },
  {
    'lang': 'en',
    'category': 'Workflow',
    'title': 'End one day before the real deadline',
    'body': 'Set the campaign flight to finish ONE day before the true '
        'deadline the client gave you.\n\n'
        'WHY\n'
        '- It leaves a buffer day. If delivery is a little short, you still '
        'have a day to push (raise bid/budget, broaden targeting) and hit '
        'the goal.\n'
        '- You can confirm the final numbers and pull the end report calmly '
        'instead of racing the last hour.\n'
        '- It absorbs reporting lag and any late-night under-delivery.\n\n'
        'So if the client says "until the 30th", run it to end on the 29th '
        'and keep the 30th as your safety margin to top up and verify the '
        'target is reached.',
  },

  // ================= EXTRA HOW-TOs (TR) =================
  {
    'lang': 'tr',
    'category': 'İş akışı',
    'title': 'Yayın harcamıyor — nasıl düzeltilir',
    'body': 'Bir line item geride kalıyorsa (harcama pacing\'in altında), şu '
        'kaldıraçları en etkiliden başlayarak dene:\n\n'
        '1. PACING: pacing\'i ASAP yap (veya günlük limiti yükselt) ki sistem '
        'teslimi öne yüklesin, eşit yaymak yerine.\n'
        '2. TEKLİF (BID): teklifi / max CPM\'i yükselt. Düşük teklif '
        'açık artırmaları kaybeder, az impression alırsın. Kademeli yükselt '
        've win rate\'e bak.\n'
        '3. HEDEFLEME: genişlet — audience, coğrafya, cihaz, daha çok '
        'envanter/exchange ekle; frequency cap\'i gevşet veya kaldır.\n'
        '4. BÜTÇE: bütçe/uçuş gerçekten gereken günlük harcamaya izin veriyor '
        'mu kontrol et (kalan bütçe / kalan gün).\n'
        '5. KREATİF/FORMAT: daha çok boyut/placement aç ki alınacak envanter '
        'artsın.\n\n'
        'PLATFORM NOTLARI\n'
        '- DV360: teklifi yükseltmek daha çok auction kazandırır ama yüksek '
        'medya CPM\'i markup\'ını yer. Hem teslim etmeye devam edip hem fiyatı '
        'korumak için markup\'ı düşürebilirsin; böylece müşteri bütçesinin '
        'daha çoğu medyaya gider ve daha yüksek teklif verebilirsin (bir '
        'miktar margin\'i teslimle takas edersin). Ayrıca pacing ASAP, '
        'Optimized targeting, daha çok exchange ve yüksek/!cap\'siz frequency.\n'
        '- Amazon DSP: base/max teklifi yükselt, supply ekle (daha çok '
        'exchange, Fire TV / Twitch / Amazon.com gibi O&O), audience\'ı '
        'genişlet ve frequency cap\'i yükselt.\n'
        '- TikTok/Meta: lowest-cost\'tayken hâlâ az harcıyorsa teklif o '
        'audience için fiilen düşüktür — audience\'ı genişlet, placement ekle '
        '(Advantage+/Automatic) ya da biraz yüksek bir bid cap\'e geç.',
  },
  {
    'lang': 'tr',
    'category': 'Platformlar',
    'title': 'DV360: bid yükselt / markup düşür ile harcat',
    'body': 'MANTIK\n'
        'Müşteri bütçesi = medya maliyeti + senin markup\'ın. Line item '
        'geride kalıyorsa genelde daha çok auction kazanmak için teklifi '
        'yükseltmen gerekir — ama yüksek medya CPM\'i markup\'ını azaltır.\n\n'
        'TAKTİK\n'
        '- Teklifi (veya max CPM\'i) yükselt ki daha çok impression kazan ve '
        'harcama hızlansın.\n'
        '- Bu yüksek teklifi sattığın fiyatı bozmadan finanse etmek için '
        'markup %\'ini düşür. Müşteri bütçesinin daha çoğu artık medyaya '
        'gider; daha yüksek teklif verip yine de müşteri fiyatına sadık '
        'kalırsın. Bir miktar margin\'i teslimle takas edersin.\n'
        '- Pacing = ASAP, Optimized targeting, daha çok exchange ve gevşek '
        'frequency cap ile birlikte uygula.\n\n'
        'İZLE\n'
        'Win rate\'i ve oluşan medya CPM\'ini izle. Teklifi küçük adımlarla '
        'yükselt; teslim yoluna girince dur ki en az margin\'den feragat et. '
        '(DV360\'ta bu markup mantığı yerleşik olduğu için Amazon\'daki gibi '
        'girilen bütçeyi elle kısmana gerek YOK.)',
  },
  {
    'lang': 'tr',
    'category': 'Platformlar',
    'title': 'Amazon DSP: margin\'i korumak için bütçeyi ayarla',
    'body': 'Amazon DSP\'de DV360\'taki gibi bir markup alanı yoktur — '
        'girdiğin bütçe, harcamaya çalışacağı medyadır. Yani margin\'ini '
        'baştan dışarıda bırakan bir bütçe girmelisin.\n\n'
        'YAYINDAN ÖNCE HESAP YAP\n'
        'Girilecek medya bütçesi = müşteri bütçesi x (1 - hedef margin%).\n'
        'Örnek: müşteri 100.000 ödüyor ve %25 margin istiyorsun →\n'
        'Order/Line Item bütçesine 100.000 x (1 - 0,25) = 75.000 gir.\n'
        'Kalan 25.000 senin margin\'in.\n\n'
        'BU UYGULAMADA\n'
        'DV360 dışı kampanyalarda formda müşteri (gerçek) bütçesini ve hedef '
        'margin\'ini gir; uygulama tam bu formülle önerilen harcamayı (medya '
        'bütçesini) gösterir — o sayıyı Amazon bütçesi olarak kullan. Sonra '
        'gerçek harcamayı her gün buna karşı takip et.',
  },
  {
    'lang': 'tr',
    'category': 'Platformlar',
    'title': 'Smartly: Meta + TikTok bütçesini birleştir ve dengele',
    'body': 'NEDİR\n'
        'Smartly, kanal-ötesi bir reklam yönetim aracıdır. Meta ve TikTok '
        'reklam hesaplarını bağlayıp hepsini tek yerden yönetir, otomatikleştirir '
        've raporlarsın.\n\n'
        'BÜTÇELERİ BİRLEŞTİRME\n'
        'Meta\'ya ayrı, TikTok\'a ayrı bütçe sabitlemek yerine (ki genelde '
        'biri çok harcarken diğeri geride kalır), iki platformun ad set\'lerini '
        'TEK ortak bütçeli bir Smartly bütçe/optimizasyon grubuna koy. Smartly '
        'harcamayı performansa göre kaydırır ve toplamı pacing\'de tutar.\n\n'
        'BİRİ DİĞERİNİ AÇ BIRAKMASIN DİYE DENGELEME\n'
        '- Ortak bütçeyi ve optimizasyon hedefini belirle (örn. en düşük CPA '
        '/ en iyi ROAS / ThruPlay başına maliyet).\n'
        '- Platform veya ad set başına min/max harcama limitleri koy ki ne '
        'Meta ne TikTok her şeyi alsın ya da sıfıra düşsün.\n'
        '- Stabil bir pencerede optimize etmesine izin ver (tek kötü saate '
        'tepki verme); her gün gözden geçir, dağılım kayıyorsa limitleri '
        'ayarla.\n\n'
        'SONUÇ: elle uğraştığın iki bütçe yerine, KPI\'na göre Meta ve TikTok '
        'arasında otomatik dengelenen tek bütçe.',
  },
  {
    'lang': 'tr',
    'category': 'Metrikler',
    'title': 'ThruPlay & nitelikli video izlenmeleri',
    'body': 'META — THRUPLAY\n'
        'ThruPlay, videon tamamına kadar ya da en az 15 saniye oynatıldığında '
        '(hangisi önce olursa) sayılır. Meta\'da hem optimizasyon hedefi hem '
        'de video için faturalama olayıdır. '
        'CPV (ThruPlay) = harcama / ThruPlay.\n\n'
        'TIKTOK — KARŞILIĞI\n'
        'TikTok\'un nitelikli-izlenme faturalaması Focused View\'dur (6 saniye '
        'veya etkileşimli izlenme). 15 saniye tarzı izlenme için TikTok '
        'raporlamasında "sonuna kadar izlendi" ve süre bazlı metrikler '
        '(örn. 6sn/15sn video izlenmeleri) vardır. Yani Meta ThruPlay '
        '(15sn/tam) ile TikTok\'un 6sn Focused View\'i en yakın karşılıklardır '
        '— birebir aynı değil, o yüzden "nitelikli izlenme" olarak karşılaştır, '
        '1:1 değil.\n\n'
        'İPUCU: ThruPlay / nitelikli izlenme başına maliyeti almak için '
        'Araçlar sekmesindeki CPV (ThruPlay) hesaplayıcısını kullan; gerçek '
        'izlenme süresi hedefse videoyu ham impression yerine bunun üzerinden '
        'al/optimize et.',
  },
  {
    'lang': 'tr',
    'category': 'İş akışı',
    'title': 'Gerçek bitişten bir gün önce bitir',
    'body': 'Kampanya uçuşunu, müşterinin verdiği gerçek bitiş tarihinden BİR '
        'gün önce bitecek şekilde ayarla.\n\n'
        'NEDEN\n'
        '- Tampon bir gün bırakır. Teslim biraz geride kalırsa hedefe ulaşmak '
        'için hâlâ bir günün olur (teklif/bütçe yükselt, hedeflemeyi '
        'genişlet).\n'
        '- Son rakamları teyit edip bitiş raporunu son saatle yarışmadan '
        'sakince çekebilirsin.\n'
        '- Raporlama gecikmesini ve gece geç saatteki olası düşük teslimi '
        'soğurur.\n\n'
        'Yani müşteri "30\'una kadar" diyorsa yayını 29\'unda bitecek şekilde '
        'kur ve 30\'unu tamamlama + hedefi doğrulama için güvenlik payı olarak '
        'tut.',
  },
];

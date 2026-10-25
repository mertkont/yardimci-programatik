import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/notifications.dart';
import '../services/settings.dart';
import '../services/summary.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// Re-schedule the 09:00 reminder so its text matches the chosen language.
  Future<void> _reschedule() async {
    final isTr = appSettings
        .isTrFor(WidgetsBinding.instance.platformDispatcher.locale);
    final brief = await SummaryService.build(tr: isTr, now: DateTime.now());
    final (title, body) = SummaryService.notificationText(brief, isTr);
    await Notifications.instance.scheduleDailySummary(title, body);
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final p = context.palette;

    return Scaffold(
      appBar: AppBar(title: Text(l.s('Settings', 'Ayarlar'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Language ----
          PanelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cardHeader(Icons.translate_rounded,
                    l.s('Language', 'Dil'), p.accent),
                const SizedBox(height: 12),
                _choices<String>(
                  value: appSettings.lang,
                  options: [
                    (
                      'system',
                      l.s('System default', 'Sistem varsayılanı'),
                    ),
                    ('en', 'English'),
                    ('tr', 'Türkçe'),
                  ],
                  onChanged: (v) async {
                    await appSettings.setLang(v);
                    await _reschedule();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ---- Appearance ----
          PanelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cardHeader(Icons.dark_mode_outlined,
                    l.s('Appearance', 'Görünüm'),
                    Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                _choices<ThemeMode>(
                  value: appSettings.themeMode,
                  options: [
                    (
                      ThemeMode.system,
                      l.s('System default', 'Sistem varsayılanı'),
                    ),
                    (ThemeMode.light, l.s('Light', 'Açık')),
                    (ThemeMode.dark, l.s('Dark', 'Koyu')),
                  ],
                  onChanged: (v) => appSettings.setThemeMode(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ---- Notifications ----
          PanelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cardHeader(Icons.notifications_active_outlined,
                    l.s('Notifications', 'Bildirimler'), p.warn),
                const SizedBox(height: 8),
                Text(
                  l.s(
                      'A daily summary is sent every morning at 09:00. '
                          'Send a test to check it works on this phone.',
                      'Her sabah 09:00\'da günlük özet gönderilir. Bu '
                          'telefonda çalıştığını görmek için test gönder.'),
                  style: TextStyle(
                      fontFamily: 'Inter', color: p.muted, height: 1.4),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final isTr = appSettings.isTrFor(WidgetsBinding
                        .instance.platformDispatcher.locale);
                    final brief = await SummaryService.build(
                        tr: isTr, now: DateTime.now());
                    final (title, body) =
                        SummaryService.notificationText(brief, isTr);
                    await Notifications.instance.showNow(title, body);
                    messenger.showSnackBar(SnackBar(
                        content: Text(l.s('Test notification sent',
                            'Test bildirimi gönderildi'))));
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: Text(
                      l.s('Send test notification', 'Test bildirimi gönder')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        SectionHeading(title),
      ],
    );
  }

  /// A vertical list of selectable rows (radio-style) styled like the app.
  Widget _choices<T>({
    required T value,
    required List<(T, String)> options,
    required ValueChanged<T> onChanged,
  }) {
    final p = context.palette;
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        for (final opt in options)
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onChanged(opt.$1),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
              child: Row(
                children: [
                  Icon(
                    value == opt.$1
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: value == opt.$1 ? primary : p.muted,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    opt.$2,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: value == opt.$1
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: value == opt.$1 ? p.ink : p.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

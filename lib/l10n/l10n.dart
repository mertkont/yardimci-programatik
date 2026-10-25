import 'package:flutter/material.dart';

/// Lightweight bilingual localization (EN/TR) that follows the device locale.
///
/// Usage in widgets:  `final l = L10n.of(context); Text(l.s('Campaigns', 'Kampanyalar'))`
class L10n {
  final Locale locale;
  const L10n(this.locale);

  static L10n of(BuildContext context) =>
      Localizations.of<L10n>(context, L10n) ?? const L10n(Locale('en'));

  bool get isTr => locale.languageCode == 'tr';

  /// Pick the Turkish string when the device is Turkish, otherwise English.
  String s(String en, String tr) => isTr ? tr : en;
}

class L10nDelegate extends LocalizationsDelegate<L10n> {
  const L10nDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'tr'].contains(locale.languageCode);

  @override
  Future<L10n> load(Locale locale) async => L10n(locale);

  @override
  bool shouldReload(L10nDelegate old) => false;
}

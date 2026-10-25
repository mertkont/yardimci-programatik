import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'db/app_db.dart';
import 'l10n/l10n.dart';
import 'screens/home_screen.dart';
import 'services/notifications.dart';
import 'services/settings.dart';
import 'services/summary.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await appSettings.load();
  await Notifications.instance.init();
  // Move any campaigns past their end date into the completed (inactive) bucket.
  await AppDb.instance.archiveExpired();
  runApp(const ProgramatikApp());
}

class ProgramatikApp extends StatefulWidget {
  const ProgramatikApp({super.key});

  @override
  State<ProgramatikApp> createState() => _ProgramatikAppState();
}

class _ProgramatikAppState extends State<ProgramatikApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupReminder());
  }

  /// Ask for permission and (re)schedule the 09:00 reminder with a fresh
  /// summary computed from the current data.
  Future<void> _setupReminder() async {
    await Notifications.instance.requestPermission();
    final isTr = appSettings
        .isTrFor(WidgetsBinding.instance.platformDispatcher.locale);
    final brief = await SummaryService.build(tr: isTr, now: DateTime.now());
    final (title, body) = SummaryService.notificationText(brief, isTr);
    await Notifications.instance.scheduleDailySummary(title, body);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appSettings,
      builder: (context, _) => MaterialApp(
        title: 'Programatik Asistan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: appSettings.themeMode,
        locale: appSettings.locale,
        localizationsDelegates: const [
          L10nDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('tr')],
        home: const HomeScreen(),
      ),
    );
  }
}

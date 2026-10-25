import 'package:flutter/material.dart';

import '../db/app_db.dart';
import '../l10n/l10n.dart';
import '../models/models.dart';

class KbScreen extends StatefulWidget {
  const KbScreen({super.key});

  @override
  State<KbScreen> createState() => _KbScreenState();
}

class _KbScreenState extends State<KbScreen> {
  Future<List<KbArticle>>? _future;
  String _query = '';
  Locale? _loadedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload when the language changes (the tab stays alive in an
    // IndexedStack, so a one-time load would keep stale-language content).
    final locale = Localizations.localeOf(context);
    if (_loadedLocale != locale) {
      _loadedLocale = locale;
      _future =
          AppDb.instance.getKbArticles(L10n.of(context).isTr ? 'tr' : 'en');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.s('Guides', 'Rehber')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l.s('Search guides', 'Rehberlerde ara'),
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<KbArticle>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var articles = snap.data!;
          if (_query.isNotEmpty) {
            articles = articles
                .where((a) =>
                    a.title.toLowerCase().contains(_query) ||
                    a.body.toLowerCase().contains(_query) ||
                    a.category.toLowerCase().contains(_query))
                .toList();
          }
          // Group by category.
          final categories = <String, List<KbArticle>>{};
          for (final a in articles) {
            categories.putIfAbsent(a.category, () => []).add(a);
          }
          if (articles.isEmpty) {
            return Center(child: Text(l.s('Nothing found.', 'Sonuç yok.')));
          }
          // Hide the default ExpansionTile dividers so the nested accordion
          // reads cleanly.
          final tileTheme = Theme.of(context)
              .copyWith(dividerColor: Colors.transparent);
          return ListView(
            padding: const EdgeInsets.all(12),
            children: categories.entries.map((e) {
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                clipBehavior: Clip.antiAlias,
                child: Theme(
                  data: tileTheme,
                  child: ExpansionTile(
                    initiallyExpanded: _query.isNotEmpty,
                    title: Text(e.key,
                        style: Theme.of(context).textTheme.titleMedium),
                    children: e.value
                        .map((a) => _ArticleTile(
                            article: a, expand: _query.isNotEmpty))
                        .toList(),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

/// A single article that expands its body inline, without leaving the Guides
/// page.
class _ArticleTile extends StatelessWidget {
  final KbArticle article;
  final bool expand;
  const _ArticleTile({required this.article, required this.expand});

  @override
  Widget build(BuildContext context) {
    final hint = Theme.of(context).hintColor;
    return ExpansionTile(
      key: PageStorageKey('kb_${article.id}'),
      initiallyExpanded: expand,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(Icons.article_outlined, color: hint),
      title: Text(article.title,
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedAlignment: Alignment.topLeft,
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article.body,
          style: const TextStyle(fontSize: 14.5, height: 1.5),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../i18n/app_localizations.dart';
import '../models/vocabulary.dart';
import '../providers/locale_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../widgets/vocabulary/flip_card.dart';
import '../widgets/common/capsule_tag.dart';

class VocabAcademyScreen extends StatefulWidget {
  const VocabAcademyScreen({super.key});

  @override
  State<VocabAcademyScreen> createState() => _VocabAcademyScreenState();
}

class _VocabAcademyScreenState extends State<VocabAcademyScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isZh = context.watch<LocaleProvider>().isZh;
    final vocabProvider = context.watch<VocabularyProvider>();

    final filtered = _searchQuery.isEmpty
        ? vocabProvider.filteredVocab
        : vocabProvider.filteredVocab
            .where((v) =>
                v.wordEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                v.wordZh.contains(_searchQuery))
            .toList();

    return Scaffold(
      backgroundColor: AppColors.wisteriaLight,
      appBar: AppBar(
        backgroundColor: AppColors.yellowGreen,
        foregroundColor: AppColors.pakistanGreen,
        elevation: 2,
        shadowColor: AppColors.yellowGreen.withValues(alpha: 0.3),
        title: Text(
          l10n.vocab('title'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.pakistanGreen,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showFavorites(context, isZh, vocabProvider),
            icon: const Icon(Icons.star, color: Color(0xFFFFD700)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ultraViolet.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: l10n.vocab('search_hint'),
                  hintStyle: const TextStyle(
                    color: AppColors.ultraViolet,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.ultraViolet, size: 22),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              size: 18, color: AppColors.ultraViolet),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            // Category filter chips
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  CapsuleTag(
                    label: l10n.vocab('category_all'),
                    icon: Icons.grid_view_rounded,
                    selected: vocabProvider.selectedCategory == null,
                    onTap: () => vocabProvider.selectCategory(null),
                  ),
                  const SizedBox(width: 8),
                  ...VocabCategory.values.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CapsuleTag(
                        label: l10n.vocabCategory(cat.key),
                        selected: vocabProvider.selectedCategory == cat,
                        onTap: () => vocabProvider.selectCategory(cat),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Vocab count — high contrast
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    isZh
                        ? '共 ${filtered.length} 个词汇'
                        : '${filtered.length} terms',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ultraViolet,
                    ),
                  ),
                  const Spacer(),
                  if (vocabProvider.selectedCategory != null)
                    TextButton(
                      onPressed: () => vocabProvider.selectCategory(null),
                      child: const Text(
                        'Clear filter',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.coralRed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Cards list
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyState(isZh: isZh)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final vocab = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: VocabFlipCard(
                            vocab: vocab,
                            isZh: isZh,
                            isFavorited:
                                vocabProvider.isFavorite(vocab.id),
                            onFavoriteToggle: () =>
                                vocabProvider.toggleFavorite(vocab.id),
                            onPlayPronunciation: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isZh
                                        ? '播放 "${vocab.wordEn}" 发音'
                                        : 'Playing "${vocab.wordEn}" pronunciation',
                                  ),
                                  duration:
                                      const Duration(milliseconds: 1200),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFavorites(
      BuildContext context, bool isZh, VocabularyProvider vocabProvider) {
    final favorites = vocabProvider.favorites;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.wisteriaLight, AppColors.wisteria],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(TennisTheme.radiusXL),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.wisteria.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.star,
                      color: Color(0xFFFFD700), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    isZh ? '我的收藏' : 'My Favorites',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ultraViolet,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '⭐ ${favorites.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.yellowGreen,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: favorites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🌱',
                              style: TextStyle(fontSize: 56)),
                          const SizedBox(height: 12),
                          Text(
                            isZh
                                ? '还没有收藏词汇哦\n去词汇学堂逛逛吧'
                                : 'No favorites yet\nDiscover words in the Vocab Academy',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ultraViolet,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final vocab = favorites[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.ultraViolet
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                  TennisTheme.radiusMD),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vocab.wordEn,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.yellowGreen,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        vocab.wordZh,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.ultraViolet,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      vocabProvider.toggleFavorite(
                                          vocab.id),
                                  icon: const Icon(Icons.star,
                                      color: Color(0xFFFFD700)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isZh;

  const _EmptyState({required this.isZh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            isZh ? '没有找到匹配的词汇' : 'No matching terms found',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ultraViolet,
            ),
          ),
        ],
      ),
    );
  }
}

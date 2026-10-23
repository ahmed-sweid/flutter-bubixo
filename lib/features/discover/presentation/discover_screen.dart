import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../data/story.dart';
import '../data/story_repository.dart';
import 'story_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final StoryRepository _repository = const StoryRepository();
  late Future<List<Story>> _storiesFuture = _repository.loadStories();
  int? _selectedLevel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Story> _filteredStories(List<Story> stories) {
    final query = _searchController.text.trim().toLowerCase();
    return stories.where((story) {
      final levelMatches = _selectedLevel == null ||
          (_selectedLevel == 1 ? story.level == 1 : story.level >= 2);
      final queryMatches = query.isEmpty ||
          story.title.toLowerCase().contains(query) ||
          story.titleTr.toLowerCase().contains(query) ||
          story.intro.toLowerCase().contains(query);
      return levelMatches && queryMatches;
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Story>>(
      future: _storiesFuture,
      builder: (context, snapshot) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xxxl,
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Geri',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Iconsax.arrow_left_2),
              ),
            ),
            Text('Hikâyeler', style: AppTypography.displaySm),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Seviyene uygun hikâyeleri oku; kelimeleri ve cümleleri bağlam içinde öğren.',
              style: AppTypography.bodyMd,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('İngilizce hikâyeler', style: AppTypography.displayXs),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Kısa hikâyeler oku; İngilizce cümleleri ve Türkçe anlamlarını birlikte gör.',
              style: AppTypography.bodySm,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Hikâye ara',
                prefixIcon: const Icon(Iconsax.search_normal_1, size: 20),
                suffixIcon: _searchController.text.isEmpty ? null : IconButton(
                  tooltip: 'Aramayı temizle',
                  onPressed: () { _searchController.clear(); setState(() {}); },
                  icon: const Icon(Iconsax.close_circle, size: 19),
                ),
                filled: true,
                fillColor: const Color(0xFFF7F7F8),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (snapshot.hasError)
              _LoadError(
                onRetry: () {
                  setState(() {
                    _storiesFuture = _repository.loadStories();
                  });
                },
              )
            else if (snapshot.hasData) ...[
              _LevelFilters(
                selectedLevel: _selectedLevel,
                onSelected: (level) => setState(() => _selectedLevel = level),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hikâyeler',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.bodyMid,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_filteredStories(snapshot.data!).length} sonuç',
                    style: AppTypography.eyebrowSmall.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ..._filteredStories(snapshot.data!).map(
                (story) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _StoryCard(
                    story: story,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => StoryDetailScreen(story: story),
                      ),
                    ),
                  ),
                ),
              ),
              if (_filteredStories(snapshot.data!).isEmpty)
                _EmptyStoriesState(
                  isSearching: _searchController.text.trim().isNotEmpty,
                  onClear: () {
                    _searchController.clear();
                    setState(() => _selectedLevel = null);
                  },
                ),
            ],
          ],
        );
      },
    );
  }
}

class _LevelFilters extends StatelessWidget {
  const _LevelFilters({
    required this.selectedLevel,
    required this.onSelected,
  });

  final int? selectedLevel;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        _filter(context, label: 'Tümü', value: null),
        _filter(context, label: 'A1', value: 1),
        _filter(context, label: 'A2', value: 2),
      ],
    );
  }

  Widget _filter(
    BuildContext context, {
    required String label,
    required int? value,
  }) {
    final selected = selectedLevel == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(value),
      selectedColor: AppColors.ink,
      labelStyle: TextStyle(
        color: selected ? AppColors.onPrimary : AppColors.body,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide(
        color: selected ? AppColors.ink : AppColors.hairline,
      ),
      showCheckmark: false,
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story, required this.onTap});

  final Story story;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.canvas,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.hairline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.book_1,
                      color: AppColors.onPrimary,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.title,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(story.titleTr, style: AppTypography.bodySm),
                      ],
                    ),
                  ),
                  const Icon(Iconsax.arrow_right_3, size: 18),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(story.intro, style: AppTypography.bodySm),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _MetaLabel(label: story.level == 1 ? 'A1' : 'A2'),
                  const SizedBox(width: AppSpacing.sm),
                  _MetaLabel(label: '${story.lines.length} cümle'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaLabel extends StatelessWidget {
  const _MetaLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.hairline.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: AppTypography.eyebrowSmall),
    );
  }
}

class _EmptyStoriesState extends StatelessWidget {
  const _EmptyStoriesState({
    required this.isSearching,
    required this.onClear,
  });

  final bool isSearching;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Icon(Iconsax.search_status_1, size: 30, color: AppColors.bodyMid),
          const SizedBox(height: AppSpacing.md),
          Text(
            isSearching ? 'Hikâye bulunamadı' : 'Bu seviyede hikâye yok',
            style: AppTypography.displayXs,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isSearching
                ? 'Arama kelimesini değiştirebilir veya filtreleri temizleyebilirsin.'
                : 'Diğer seviyelerdeki hikâyelere de göz atabilirsin.',
            style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onClear,
            icon: const Icon(Iconsax.refresh, size: 18),
            label: const Text('Filtreleri temizle'),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Text(
            'Hikâyeler yüklenemedi. Yeniden deneyebilirsin.',
            style: AppTypography.bodyMd,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Yeniden dene'),
          ),
        ],
      ),
    );
  }
}

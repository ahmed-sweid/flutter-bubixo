import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? _lastStoryId;

  @override
  void initState() {
    super.initState();
    _loadLastStory();
  }

  Future<void> _loadLastStory() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _lastStoryId = preferences.getString('bubixo.last_story_id'));
  }

  Future<void> _openStory(Story story) async {
    // Persist before pushing so the shortcut is reliable even if the reader
    // is closed quickly or its own initialization has not completed yet.
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('bubixo.last_story_id', story.id);
    await preferences.setString('bubixo.last_story_title', story.title);
    if (!mounted) return;
    setState(() => _lastStoryId = story.id);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => StoryDetailScreen(story: story)),
    );
    await _loadLastStory();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Story>>(
      future: _storiesFuture,
      builder: (context, snapshot) {
        final allStories = snapshot.data ?? const <Story>[];
        final visibleStories = _selectedLevel == null
            ? allStories
            : allStories
                .where((story) => story.level == _selectedLevel)
                .toList(growable: false);
        return ListView(
          key: const PageStorageKey<String>('discover-screen-scroll'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xxxl,
          ),
          children: [
            Text('Hikâyeler', style: AppTypography.displaySm),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Kısa hikâyeler oku; İngilizce cümleleri ve Türkçe anlamlarını birlikte gör.',
              style: AppTypography.bodySm,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (snapshot.hasData && _lastStoryId != null) ...[
              for (final story in snapshot.data!)
                if (story.id == _lastStoryId) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openStory(story),
                      icon: const Icon(Iconsax.play_circle),
                      label: Text('Son okuduğun hikâyeye dön · ${story.title}'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
            ],
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
                    '${visibleStories.length} sonuç',
                    style: AppTypography.eyebrowSmall.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...visibleStories.map(
                (story) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _StoryCard(
                    story: story,
                    onTap: () => _openStory(story),
                  ),
                ),
              ),
              if (visibleStories.isEmpty)
                _EmptyStoriesState(
                  isSearching: false,
                  onClear: () => setState(() => _selectedLevel = null),
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
        _filter(context, label: 'Seviye 1', value: 1),
        _filter(context, label: 'Seviye 2', value: 2),
        _filter(context, label: 'Seviye 3', value: 3),
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
      borderRadius: BorderRadius.circular(12),
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
              Text(
                story.title,
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                story.titleTr,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.bodyMid,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(story.intro, style: AppTypography.bodySm),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  _MetaLabel(label: 'Seviye ${story.level}'),
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
          const Icon(Iconsax.book_1, size: 30, color: AppColors.bodyMid),
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

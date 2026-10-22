import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      children: [
        Text('Pratik', style: AppTypography.displaySm),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Kısa alıştırmalarla öğrendiklerini kullan.',
          style: AppTypography.bodyMd,
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hazır olduğunda başla',
                      style: AppTypography.displayXs.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Bir alıştırma seç ve kendi hızında ilerle.',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.mutedSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(
                Iconsax.flash_1,
                color: AppColors.accentPurple,
                size: 34,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Alıştırma türleri', style: AppTypography.displayXs),
        const SizedBox(height: AppSpacing.md),
        _PracticeCategoryCard(
          icon: Iconsax.text_block,
          tint: const Color(0xFFECE7FF),
          iconColor: AppColors.accentPurple,
          title: 'Cümle kurma',
          subtitle: 'Türkçe cümleyi İngilizce sıraya yerleştir.',
          meta: 'Cümle oluşturma',
          onTap: () => _openActivity(
            context,
            title: 'Cümle kurma',
            subtitle: 'Kelimeleri doğru sırada düşün.',
            question: 'Ben her sabah kahve içerim.',
            prompt: 'Doğru İngilizce cümleyi seç',
            options: const [
              'I drink coffee every morning.',
              'I coffee drink every morning.',
              'Every morning coffee I drink.',
            ],
            correctIndex: 0,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _PracticeCategoryCard(
          icon: Iconsax.book_1,
          tint: const Color(0xFFE3F2FF),
          iconColor: AppColors.accentBlueDeep,
          title: 'Dil bilgisi',
          subtitle: 'Zamanları ve cümle yapılarını pekiştir.',
          meta: 'Present Simple',
          onTap: () => _openActivity(
            context,
            title: 'Dil bilgisi',
            subtitle: 'Geniş zaman · Present Simple',
            question: 'She ___ coffee every morning.',
            prompt: 'Boşluğu doğru seçenekle tamamla',
            options: const ['drink', 'drinks', 'drinking'],
            correctIndex: 1,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _PracticeCategoryCard(
          icon: Iconsax.category_2,
          tint: const Color(0xFFFFEBD9),
          iconColor: AppColors.accentOrange,
          title: 'Kelime oyunları',
          subtitle: 'İngilizce kelimeleri Türkçe anlamlarıyla eşleştir.',
          meta: 'Kelime eşleştirme',
          onTap: () => _openActivity(
            context,
            title: 'Kelime eşleştirme',
            subtitle: 'Kelimeyi doğru anlamıyla eşleştir.',
            question: '“explore” ne demek?',
            prompt: 'Doğru anlamı seç',
            options: const ['unutmak', 'keşfetmek', 'beklemek'],
            correctIndex: 1,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Iconsax.info_circle, size: 19, color: AppColors.bodyMid),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Bu ekrandaki sorular arayüz ve geçişleri göstermek için örneklenmiştir. '
                  'Gerçek soru havuzları sonraki aşamada kaynak dosyalara bağlanacak.',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.bodyMid,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openActivity(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String question,
    required String prompt,
    required List<String> options,
    required int correctIndex,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PracticeActivityScreen(
          title: title,
          subtitle: subtitle,
          question: question,
          prompt: prompt,
          options: options,
          correctIndex: correctIndex,
        ),
      ),
    );
  }
}

class _PracticeCategoryCard extends StatelessWidget {
  const _PracticeCategoryCard({
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.canvas,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.hairline),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: iconColor, size: 23),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTypography.bodySm.copyWith(
                      color: AppColors.bodyMid,
                    )),
                    const SizedBox(height: 7),
                    Text(meta.toUpperCase(), style: AppTypography.eyebrowSmall.copyWith(
                      color: AppColors.muted,
                      fontSize: 10,
                    )),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Iconsax.arrow_right_3, size: 18, color: AppColors.bodyMid),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeActivityScreen extends StatefulWidget {
  const _PracticeActivityScreen({
    required this.title,
    required this.subtitle,
    required this.question,
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  final String title;
  final String subtitle;
  final String question;
  final String prompt;
  final List<String> options;
  final int correctIndex;

  @override
  State<_PracticeActivityScreen> createState() => _PracticeActivityScreenState();
}

class _PracticeActivityScreenState extends State<_PracticeActivityScreen> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final answered = _selectedIndex != null;
    final isCorrect = _selectedIndex == widget.correctIndex;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: AppColors.transparent,
        title: Text(widget.title, style: AppTypography.bodyMd.copyWith(
          fontWeight: FontWeight.w700,
        )),
        leading: IconButton(
          tooltip: 'Geri',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Iconsax.arrow_left_2),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(widget.subtitle, style: AppTypography.bodySm.copyWith(
              color: AppColors.bodyMid,
            )),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: const LinearProgressIndicator(
                      value: 0.33,
                      minHeight: 5,
                      backgroundColor: Color(0xFFEAEAEA),
                      valueColor: AlwaysStoppedAnimation(AppColors.accentPurple),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text('1 / 3', style: AppTypography.eyebrowSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(widget.prompt, style: AppTypography.bodySm.copyWith(
              color: AppColors.bodyMid,
            )),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.question,
                textAlign: TextAlign.center,
                style: AppTypography.displayXs,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ...List.generate(widget.options.length, (index) {
              final selected = _selectedIndex == index;
              final correctChoice = answered && index == widget.correctIndex;
              final wrongChoice = selected && answered && !isCorrect;
              final borderColor = correctChoice
                  ? AppColors.accentGreen
                  : wrongChoice
                      ? AppColors.accentRed
                      : selected
                          ? AppColors.accentPurple
                          : AppColors.hairline;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: answered ? null : () => setState(() => _selectedIndex = index),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: selected || correctChoice ? 1.5 : 1),
                      color: correctChoice
                          ? const Color(0xFFF0FFF3)
                          : wrongChoice
                              ? const Color(0xFFFFF1F2)
                              : AppColors.canvas,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(widget.options[index], style: AppTypography.bodyMd)),
                        if (correctChoice)
                          const Icon(Iconsax.tick_circle, color: AppColors.accentGreen, size: 20)
                        else if (wrongChoice)
                          const Icon(Iconsax.close_circle, color: AppColors.accentRed, size: 20)
                        else
                          Icon(
                            selected ? Iconsax.radio : Iconsax.record,
                            color: selected ? AppColors.accentPurple : AppColors.muted,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (answered) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isCorrect ? const Color(0xFFF0FFF3) : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCorrect ? Iconsax.tick_circle : Iconsax.info_circle,
                      color: isCorrect ? AppColors.accentGreen : AppColors.accentOrange,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        isCorrect ? 'Doğru cevap!' : 'Doğru cevabı yeşil işaretle gösterdik.',
                        style: AppTypography.bodySm,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => setState(() => _selectedIndex = null),
                icon: const Icon(Iconsax.refresh),
                label: const Text('Tekrar dene'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

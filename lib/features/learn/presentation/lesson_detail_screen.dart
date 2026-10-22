import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';

class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({super.key});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int? _selectedAnswer;
  bool _showAnswer = false;

  static const _examples = <({String english, String turkish})>[
    (english: 'A — apple', turkish: 'A harfi: “epıl” gibi başlar (elma).'),
    (english: 'E — egg', turkish: 'Kısa e sesi (yumurta).'),
    (english: 'I — ice', turkish: '“Ays” diye okunur (buz).'),
    (english: 'O — orange', turkish: '“Orınc” (portakal).'),
    (english: 'U — umbrella', turkish: '“Ambrela” (şemsiye).'),
    (english: 'W — water', turkish: '“Uotır” (su); w sesinde dudaklar yuvarlanır.'),
    (english: 'TH — thank you', turkish: 'TH sesinde dilin ucu dişlerin arasına hafifçe gelir.'),
    (english: 'SH — she', turkish: 'Türkçedeki ş sesine yakındır.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: AppColors.transparent,
        title: Text('Ders 1', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
        leading: IconButton(
          tooltip: 'Geri',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Iconsax.arrow_left_2),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxxl),
        children: [
          Text('Alfabe ve Telaffuzun Temelleri', style: AppTypography.displaySm),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Iconsax.clock, size: 16, color: AppColors.bodyMid),
              const SizedBox(width: AppSpacing.xs),
              Text('8 dakika', style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid)),
              const SizedBox(width: AppSpacing.md),
              const Icon(Iconsax.book_1, size: 16, color: AppColors.bodyMid),
              const SizedBox(width: AppSpacing.xs),
              Text('8 örnek', style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('İngilizce yazıldığı gibi okunmaz', style: AppTypography.displayXs),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'İngilizce alfabe 26 harften oluşur. Türkçedeki ç, ğ, ı, ö, ş, ü harfleri İngilizce alfabede yoktur; q, w ve x harfleri ise vardır. Yeni kelimeleri yazılışıyla birlikte sesine de dikkat ederek öğren.',
            style: AppTypography.bodyMd,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Örnekleri incele', style: AppTypography.displayXs),
          const SizedBox(height: AppSpacing.md),
          ..._examples.map((example) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                border: Border.all(color: AppColors.hairline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(example.english, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(example.turkish, style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid)),
                ],
              ),
            ),
          )),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: const Color(0xFFF1ECFF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Iconsax.lamp_on, color: AppColors.accentPurple, size: 19),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Öğrenme ipucu', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'TH sesi Türkçede bulunmaz. “Think”, “three” ve “thank you” kelimelerini söylerken dilinin ucunu üst ve alt dişlerin arasına hafifçe getir.',
                  style: AppTypography.bodySm,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Kendini dene', style: AppTypography.displayXs),
          const SizedBox(height: AppSpacing.sm),
          Text('İngilizcede olup Türkçe alfabede olmayan harf hangisi?', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.md),
          ...['ş', 'w', 'ö', 'ç'].asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isCorrect = index == 1;
            final selected = _selectedAnswer == index;
            final color = _showAnswer && isCorrect
                ? const Color(0xFFE1F5E8)
                : _showAnswer && selected
                    ? const Color(0xFFFCE8E6)
                    : selected
                        ? const Color(0xFFF1ECFF)
                        : AppColors.canvas;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _showAnswer ? null : () => setState(() => _selectedAnswer = index),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? AppColors.accentPurple : AppColors.hairline),
                  ),
                  child: Row(children: [
                    Expanded(child: Text(option, style: AppTypography.bodyMd)),
                    if (_showAnswer && isCorrect)
                      const Icon(Iconsax.tick_circle, color: Color(0xFF16834A), size: 19),
                  ]),
                ),
              ),
            );
          }),
          if (_showAnswer) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              _selectedAnswer == 1
                  ? 'Doğru! İngilizce alfabede q, w ve x harfleri bulunur.'
                  : 'Doğru cevap: w. İngilizcede q, w ve x harfleri de bulunur.',
              style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => setState(() {
                _selectedAnswer = null;
                _showAnswer = false;
              }),
              icon: const Icon(Iconsax.refresh, size: 18),
              label: const Text('Tekrar dene'),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedAnswer == null ? null : () => setState(() => _showAnswer = true),
                child: const Text('Cevabı kontrol et'),
              ),
            ),
        ],
      ),
    );
  }
}

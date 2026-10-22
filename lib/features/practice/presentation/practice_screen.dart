import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('Pratik', style: AppTypography.displaySm),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Dil bilgisini ve öğrendiklerini kısa, odaklı alıştırmalarla kullan.',
          style: AppTypography.bodyMd,
        ),
        const SizedBox(height: AppSpacing.xxl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Iconsax.activity, size: 24),
              const SizedBox(height: AppSpacing.md),
              Text('Alıştırmalar burada olacak', style: AppTypography.displayXs),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Cümle kurma, dil bilgisi, dinleme ve kelime oyunları bu sekmede toplanacak.',
                style: AppTypography.bodySm,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

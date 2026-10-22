import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('Keşfet', style: AppTypography.displaySm),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'İlgi alanına göre İngilizce içerikler bul ve kendi hızında keşfet.',
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
              const Icon(Iconsax.discover, size: 24),
              const SizedBox(height: AppSpacing.md),
              Text('Okuma ve hikâyeler', style: AppTypography.displayXs),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Hikâyeler ve serbest okunabilir içerikler bu alana bağlanacak.',
                style: AppTypography.bodySm,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

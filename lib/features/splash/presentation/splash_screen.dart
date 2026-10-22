import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../../shell/presentation/bubixo_shell.dart';

/// Lightweight branded entry screen. It hands off to the app shell after a
/// short transition and does not perform any network or content loading.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, animation, secondaryAnimation) =>
              const BubixoShell(),
          transitionDuration: const Duration(milliseconds: 280),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            children: [
              const Spacer(flex: 3),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 550),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.92 + (0.08 * value),
                    child: child,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _BubixoMark(),
                    const SizedBox(height: 22),
                    RichText(
                      text: TextSpan(
                        style: AppTypography.displayLg.copyWith(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.8,
                        ),
                        children: const [
                          TextSpan(text: 'bubixo'),
                          TextSpan(
                            text: '.',
                            style: TextStyle(color: AppColors.accentPurple),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'İngilizceyi, adım adım keşfet.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.bodyMid,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              const SizedBox(
                width: 36,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: AppColors.hairline,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.accentPurple,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'HER GÜN BİR ADIM',
                style: AppTypography.eyebrowSmall.copyWith(
                  color: AppColors.muted,
                  fontSize: 10,
                  letterSpacing: 1.4,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BubixoMark extends StatelessWidget {
  const _BubixoMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const SizedBox.expand(
              child: Icon(
                Iconsax.book_1,
                color: AppColors.onPrimary,
                size: 38,
              ),
            ),
          ),
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                color: AppColors.accentPurple,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.canvas,
                  width: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

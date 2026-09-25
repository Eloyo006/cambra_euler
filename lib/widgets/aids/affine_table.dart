import 'package:flutter/material.dart';

import '../../core/modular.dart';
import '../../core/theme.dart';

/// Taula d'ajuda del xifrat afí: cada lletra x i la seva imatge a·x + b.
class AffineTable extends StatelessWidget {
  const AffineTable({super.key, this.a = 2, this.b = 3});

  final int a;
  final int b;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'x → ${a}x + $b (mod 27)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final ch in alphabet27.split(''))
              Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$ch → ${affineEncrypt(ch, a, b)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

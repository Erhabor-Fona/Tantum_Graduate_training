import 'package:flutter/material.dart';

import '../domain/entities/telco.dart';

/// Circular telco badge (MTN / Airtel / Glo / 9mobile) used by the network
/// picker, the airtime history tiles and the purchase receipts.
class NetworkAvatar extends StatelessWidget {
  final TelcoNetwork network;
  final double size;
  final bool selected;
  final bool dimmed;

  const NetworkAvatar({
    super.key,
    required this.network,
    this.size = 56,
    this.selected = false,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final brand = Color(network.brandColor);
    final onBrand = Color(network.onBrandColor);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dimmed ? brand.withOpacity(0.35) : brand,
        shape: BoxShape.circle,
        border: selected ? Border.all(color: const Color(0xFF001F3F), width: 2.5) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        network.label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: size * 0.22,
          fontWeight: FontWeight.w800,
          color: dimmed ? onBrand.withOpacity(0.6) : onBrand,
        ),
      ),
    );
  }
}

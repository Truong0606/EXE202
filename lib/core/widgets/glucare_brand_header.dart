import 'package:flutter/material.dart';

class GluCareBrandHeader extends StatelessWidget {
  const GluCareBrandHeader({
    super.key,
    required this.logoWidth,
    required this.textWidth,
    this.gap = 8,
  });

  final double logoWidth;
  final double textWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/glucare_logo.png',
          width: logoWidth,
          fit: BoxFit.contain,
        ),
        SizedBox(height: gap),
        Image.asset(
          'assets/images/glucare_text.png',
          width: textWidth,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

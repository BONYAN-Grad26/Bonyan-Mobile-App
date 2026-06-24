import 'package:flutter/material.dart';

/// A reusable branded logo widget that automatically selects the correct
/// logo variant based on the current theme brightness.
///
/// Use [BonyaanLogo.header] for page headers (auth screens, ~160px).
/// Use [BonyaanLogo.appBar] for in-app brand presence (~100px).
/// Use [BonyaanLogo.small] for compact placements (~72px).
class BonyaanLogo extends StatelessWidget {
  final double width;
  final Alignment alignment;

  const BonyaanLogo({
    super.key,
    this.width = 160,
    this.alignment = Alignment.center,
  });

  /// Large logo for auth screen headers
  const BonyaanLogo.header({super.key})
      : width = 180,
        alignment = Alignment.center;

  /// Medium logo for app bar brand presence
  const BonyaanLogo.appBar({super.key})
      : width = 110,
        alignment = Alignment.centerLeft;

  /// Small logo for compact placements
  const BonyaanLogo.small({super.key})
      : width = 80,
        alignment = Alignment.center;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoAsset = isDark
        ? 'assets/images/logo_stacked_light.png'
        : 'assets/images/logo_stacked_dark.png';

    return Align(
      alignment: alignment,
      child: Image.asset(
        logoAsset,
        width: width,
        fit: BoxFit.contain,
      ),
    );
  }
}

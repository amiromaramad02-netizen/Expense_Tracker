// The widget intentionally reads and clamps the current text scale factor
// (a deprecated API in newer Flutter versions) to preserve layout when
// the OS text size is set extremely large. Silence the deprecation lint
// for this small, targeted file.
// ignore_for_file: deprecated_member_use
import 'package:flutter/widgets.dart';

/// A small utility that clamps the [MediaQuery.textScaleFactor] for its child.
///
/// Use this for large headings or numbers that would otherwise break layouts
/// when the system text scale is set very large (accessibility settings).
class TextScaleLimiter extends StatelessWidget {
  final double maxScale;
  final Widget child;

  const TextScaleLimiter({super.key, required this.child, this.maxScale = 1.25});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // textScaleFactor is deprecated in upcoming Flutter releases where
    // a nonlinear text scaler is used; keep using it for now but silence the
    // deprecation lint because we purposefully clamp it for layout safety.
    // ignore: deprecated_member_use
    final current = mq.textScaleFactor;
    if (current <= maxScale) return child;
    // ignore: deprecated_member_use
    return MediaQuery(
      data: mq.copyWith(textScaleFactor: maxScale),
      child: child,
    );
  }
}

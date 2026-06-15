import 'package:flutter/widgets.dart';

/// Lightweight responsive helpers so the app adapts across phone sizes,
/// large phones, foldables and tablets without overflow.
class Responsive {
  Responsive._();

  // Breakpoints (logical px on shortest side / width).
  static const double compact = 360; // small phones
  static const double medium = 600; // large phones / small tablets
  static const double expanded = 905; // tablets

  /// Maximum content width — keeps the mobile layout centered & readable
  /// on wide screens (tablet / landscape / desktop web preview).
  static const double maxContentWidth = 560;

  static double width(BuildContext c) => MediaQuery.sizeOf(c).width;
  static double height(BuildContext c) => MediaQuery.sizeOf(c).height;

  static bool isCompact(BuildContext c) => width(c) < compact + 20;
  static bool isTablet(BuildContext c) => width(c) >= medium;

  /// Pick a value based on width bucket.
  static T value<T>(
    BuildContext c, {
    required T mobile,
    T? large,
    T? tablet,
  }) {
    final w = width(c);
    if (w >= medium && tablet != null) return tablet;
    if (w >= compact + 60 && large != null) return large;
    return mobile;
  }

  /// Horizontal page padding that grows slightly on bigger screens.
  static double pagePadding(BuildContext c) =>
      value(c, mobile: 18.0, large: 20.0, tablet: 24.0);

  /// Scales a font/dimension down a touch on very small phones to avoid
  /// overflow, and never above 1.0 so tablets keep the mobile proportions.
  static double scale(BuildContext c) {
    final w = width(c);
    if (w <= 340) return 0.92;
    if (w <= 360) return 0.96;
    return 1.0;
  }
}

/// Centers page content and constrains it to a comfortable mobile width on
/// large screens — the core of "full responsive" for a mobile-first app.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = Responsive.maxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

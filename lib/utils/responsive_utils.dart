import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes
class ResponsiveUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 16.0;
    if (width < 900) return 24.0;
    return 32.0;
  }

  static double getResponsiveFontSize(BuildContext context, double mobileSize, [double? tabletSize, double? desktopSize]) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return mobileSize;
    if (width < 1200) return tabletSize ?? mobileSize + 2;
    return desktopSize ?? mobileSize + 4;
  }

  static double getResponsiveHeight(BuildContext context, double mobileHeight) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return mobileHeight;
    if (width < 1200) return mobileHeight * 1.1;
    return mobileHeight * 1.2;
  }

  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 1;
    if (width < 900) return 2;
    return 3;
  }

  static EdgeInsets getResponsiveInsets(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    if (width < 900) return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
  }
}

import 'package:flutter/material.dart';

/// Responsive design helper following HTML/CSS breakpoint patterns
class ResponsiveHelper {
  // Breakpoints from CSS
  static const double mobileBreakpoint = 664.0;
  static const double tabletBreakpoint = 1024.0;

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= mobileBreakpoint;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > mobileBreakpoint && width <= tabletBreakpoint;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width > tabletBreakpoint;
  }

  /// Get responsive margin based on screen size
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(8); // --section-container-margin mobile
    } else if (isTablet(context)) {
      return const EdgeInsets.all(10); // --section-container-margin tablet
    } else {
      return const EdgeInsets.all(20); // --section-container-margin desktop
    }
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(10); // --controls-padding mobile
    } else {
      return const EdgeInsets.all(14); // --controls-padding desktop
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    required double desktop,
    double? tablet,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return desktop;
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, {required double mobile, required double desktop}) {
    return isMobile(context) ? mobile : desktop;
  }
}

/// Responsive widget builder that provides different layouts for different screen sizes
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context) desktop;

  const ResponsiveBuilder({super.key, required this.mobile, this.tablet, required this.desktop});

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isMobile(context)) {
      return mobile(context);
    } else if (ResponsiveHelper.isTablet(context) && tablet != null) {
      return tablet!(context);
    } else {
      return desktop(context);
    }
  }
}

/// Responsive layout widget that automatically adapts between mobile and desktop layouts
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool centerContent;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth = 1300.0, // CSS max-width
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isMobile(context)) {
      return child;
    }

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      margin: centerContent ? const EdgeInsets.symmetric(horizontal: 16) : null,
      child: centerContent && ResponsiveHelper.isDesktop(context) ? Center(child: child) : child,
    );
  }
}

/// Responsive text style helper
class ResponsiveTextStyle {
  /// Header text style (responsive)
  static TextStyle header(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveHelper.getResponsiveFontSize(
        context,
        mobile: 26, // --primary-header-font-size mobile
        desktop: 30, // --primary-header-font-size desktop
      ),
      fontWeight: FontWeight.bold,
      color: const Color(0x87000000),
    );
  }

  /// Subheader text style (responsive)
  static TextStyle subheader(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveHelper.getResponsiveFontSize(
        context,
        mobile: 20, // --tertiary-header-font-size mobile
        desktop: 22, // --tertiary-header-font-size desktop
      ),
      fontWeight: FontWeight.w500,
      color: const Color(0x87000000),
    );
  }

  /// Body text style (responsive)
  static TextStyle body(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveHelper.getResponsiveFontSize(
        context,
        mobile: 14, // --instructions-font-size mobile
        desktop: 16, // --instructions-font-size desktop
      ),
      fontWeight: FontWeight.w300,
      color: const Color(0x87000000),
    );
  }

  /// Chinese character text style (responsive)
  static TextStyle chineseCharacter(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveHelper.getResponsiveFontSize(
        context,
        mobile: 22, // --target-language-font-size mobile
        desktop: 24, // --target-language-font-size desktop
      ),
      fontWeight: FontWeight.w400,
      color: const Color(0x87000000),
    );
  }

  /// Search text style (responsive)
  static TextStyle search(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveHelper.getResponsiveFontSize(
        context,
        mobile: 16, // --search-font-size mobile
        desktop: 20, // --search-font-size desktop
      ),
      fontWeight: FontWeight.w300,
      color: const Color(0x87000000),
    );
  }
}

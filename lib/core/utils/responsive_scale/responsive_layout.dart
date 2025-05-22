

import 'package:flutter/material.dart';
import 'responsive_helper.dart'; 

class ResponsiveLayout extends StatelessWidget {
  final Widget watch;
  final Widget mobile;
  final Widget tablet;
  final Widget smallDesktop;
  final Widget desktop;
  final Widget largeDesktop;

  const ResponsiveLayout({
    super.key,
    required this.watch,
    required this.mobile,
    required this.tablet,
    required this.smallDesktop,
    required this.desktop,
    required this.largeDesktop,
  });

  const ResponsiveLayout.autoScale({
    super.key,
    required this.mobile,
    Widget? watch,
    Widget? tablet,
    Widget? smallDesktop, 
    Widget? desktop,
    Widget? largeDesktop,
  })  : watch = watch ?? mobile,
        tablet = tablet ?? mobile,
        smallDesktop = smallDesktop ?? mobile,
        desktop = desktop ?? mobile,
        largeDesktop = largeDesktop ?? mobile;

  @override
  Widget build(BuildContext context) {
    return context.responsive.valueByScreen(
      watch: watch,
      mobile: mobile,
      tablet: tablet,
      smallDesktop: smallDesktop,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int watchColumnCount;
  final int mobileColumnCount;
  final int tabletColumnCount;
  final int smallDesktopColumnCount;
  final int desktopColumnCount;
  final int largeDesktopColumnCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.watchColumnCount = 1,
    this.mobileColumnCount = 2,
    this.tabletColumnCount = 3,
    this.smallDesktopColumnCount = 4,
    this.desktopColumnCount = 5,
    this.largeDesktopColumnCount = 6,
    this.mainAxisSpacing = 10.0,
    this.crossAxisSpacing = 10.0,
    this.childAspectRatio = 1.0,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
  });

  const ResponsiveGrid.autoScale({
    super.key,
    required this.children,
    required int columnCount,  
    this.mainAxisSpacing = 10.0,
    this.crossAxisSpacing = 10.0,
    this.childAspectRatio = 1.0,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
  })  : watchColumnCount = (columnCount > 1) ? columnCount - 1 : 1,
        mobileColumnCount = columnCount,
        tabletColumnCount = columnCount + 1,
        smallDesktopColumnCount = columnCount + 2,
        desktopColumnCount = columnCount + 3,
        largeDesktopColumnCount = columnCount + 4;

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount = context.responsive.valueByScreen(
      watch: watchColumnCount,
      mobile: mobileColumnCount,
      tablet: tabletColumnCount,
      smallDesktop: smallDesktopColumnCount,
      desktop: desktopColumnCount,
      largeDesktop: largeDesktopColumnCount,
    );

    return GridView.count(
      key: key,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      children: children,
    );
  }
}

class ResponsiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment rowMainAxisAlignment;
  final MainAxisSize rowMainAxisSize;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final TextDirection? rowTextDirection;
  final VerticalDirection rowVerticalDirection;
  final TextBaseline? rowTextBaseline;
  final MainAxisAlignment columnMainAxisAlignment;
  final MainAxisSize columnMainAxisSize;
  final CrossAxisAlignment columnCrossAxisAlignment;
  final TextDirection? columnTextDirection;
  final VerticalDirection columnVerticalDirection;
  final TextBaseline? columnTextBaseline;
  final ScreenType switchToRowBreakpoint; 

  const ResponsiveRowColumn({
    super.key,
    required this.children,
    this.rowMainAxisAlignment = MainAxisAlignment.start,
    this.rowMainAxisSize = MainAxisSize.max,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.rowTextDirection,
    this.rowVerticalDirection = VerticalDirection.down,
    this.rowTextBaseline,
    this.columnMainAxisAlignment = MainAxisAlignment.start,
    this.columnMainAxisSize = MainAxisSize.max,
    this.columnCrossAxisAlignment = CrossAxisAlignment.center,
    this.columnTextDirection,
    this.columnVerticalDirection = VerticalDirection.down,
    this.columnTextBaseline,
    this.switchToRowBreakpoint = ScreenType.tablet, 
  });

  @override
  Widget build(BuildContext context) {
    final currentScreenType = context.responsive.screenType;
    bool useRow = currentScreenType.index >= switchToRowBreakpoint.index;

    if (useRow) {
      return Row(
        key: key, 
        mainAxisAlignment: rowMainAxisAlignment,
        mainAxisSize: rowMainAxisSize,
        crossAxisAlignment: rowCrossAxisAlignment,
        textDirection: rowTextDirection,
        verticalDirection: rowVerticalDirection,
        textBaseline: rowTextBaseline,
        children: children,
      );
    } else {
      return Column(
        key: key, 
        mainAxisAlignment: columnMainAxisAlignment,
        mainAxisSize: columnMainAxisSize,
        crossAxisAlignment: columnCrossAxisAlignment,
        textDirection: columnTextDirection,
        verticalDirection: columnVerticalDirection,
        textBaseline: columnTextBaseline,
        children: children,
      );
    }
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double padding;
  final bool symmetric;
  final bool horizontal;
  final bool vertical;

  const ResponsivePadding({
    super.key,
    required this.child,
    required this.padding,
    this.symmetric = true,
    this.horizontal = true,
    this.vertical = true,
  });

  const ResponsivePadding.symmetric({
    super.key,
    required this.child,
    required this.padding,
    this.horizontal = true,
    this.vertical = true,
  }) : symmetric = true;

  const ResponsivePadding.all({
    super.key,
    required this.child,
    required this.padding,
  })  : symmetric = false,
        horizontal = true,
        vertical = true;

  const ResponsivePadding.horizontal({
    super.key,
    required this.child,
    required this.padding,
  })  : symmetric = true,
        horizontal = true,
        vertical = false;

  const ResponsivePadding.vertical({
    super.key,
    required this.child,
    required this.padding,
  })  : symmetric = true,
        horizontal = false,
        vertical = true;

  @override
  Widget build(BuildContext context) {
    final scaledPadding = context.responsive.autoScaleSpace(padding);

    if (symmetric) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal ? scaledPadding : 0,
          vertical: vertical ? scaledPadding : 0,
        ),
        child: child,
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(scaledPadding),
        child: child,
      );
    }
  }
}

class ResponsiveSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const ResponsiveSizedBox({
    super.key,
    this.width,
    this.height,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scaledWidth = width != null 
        ? context.responsive.autoScaleSpace(width!)
        : null;
    final scaledHeight = height != null 
        ? context.responsive.autoScaleSpace(height!)
        : null;

    return SizedBox(
      width: scaledWidth,
      height: scaledHeight,
      child: child,
    );
  }
}
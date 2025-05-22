

import 'package:flutter/material.dart';
import 'responsive_helper.dart';

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  
  final double? watchSize;
  final double? mobileSize;
  final double? tabletSize;
  final double? smallDesktopSize;
  final double? desktopSize;
  final double? largeDesktopSize;

  
  final double? size;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.watchSize,
    this.mobileSize,
    this.tabletSize,
    this.smallDesktopSize,
    this.desktopSize,
    this.largeDesktopSize,
  }) : size = null;

  const ResponsiveText.simple(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    required this.size,
  })  : watchSize = null,
        mobileSize = null,
        tabletSize = null,
        smallDesktopSize = null,
        desktopSize = null,
        largeDesktopSize = null;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    
    
    double fontSize;
    
    if (size != null) {
    
      fontSize = responsive.autoScaleFontSize(size!);
    } else {
  
      fontSize = responsive.valueByScreen(
        watch: watchSize!,
        mobile: mobileSize!,
        tablet: tabletSize!,
        smallDesktop: smallDesktopSize!,
        desktop: desktopSize!,
        largeDesktop: largeDesktopSize!,
      );
    }

   
    final finalStyle = (style ?? DefaultTextStyle.of(context).style).copyWith(
      fontSize: fontSize,
    );

    
    return Text(
      text,
      key: key,
      style: finalStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
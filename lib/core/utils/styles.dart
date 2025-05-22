import 'package:flutter/material.dart';

class AppStyles {
  static TextStyle styleMedium16(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).brightness == Brightness.dark 
          ? Colors.white 
          : Colors.black,
    );
  }

  static TextStyle styleMedium20(BuildContext context) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).brightness == Brightness.dark 
          ? Colors.white 
          : Colors.black,
    );
  }

  static TextStyle styleMedium24(BuildContext context) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).brightness == Brightness.dark 
          ? Colors.white 
          : Colors.black,
    );
  }

  static TextStyle styleSemiBold24(BuildContext context) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).brightness == Brightness.dark 
          ? Colors.white 
          : Colors.black,
    );
  }
}
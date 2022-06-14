import 'package:flutter/material.dart';

class UITexts {
  static const iconHeader = TextStyle(
    fontSize: FontSizes.iconHeaderFontSize,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const sectionHeader = TextStyle(
    fontSize: FontSizes.sectionHeaderFontSize,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const sectionSubheader = TextStyle(
    fontSize: FontSizes.sectionSubheaderFontSize,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  static const mediumText = TextStyle(
    fontSize: FontSizes.mediumTextSize,
    color: Colors.black,
  );

  static const bigText = TextStyle(
    fontSize: FontSizes.bigTextSize,
    color: Colors.black,
  );

  static const smallButtonText = TextStyle(
    fontSize: FontSizes.mediumTextSize,
  );

  static const mediumButtonText = TextStyle(
    fontSize: FontSizes.bigTextSize,
    fontWeight: FontWeight.bold,
  );

  static const bigButtonText = TextStyle(
    fontSize: FontSizes.sectionHeaderFontSize,
    fontWeight: FontWeight.bold,
  );
}

class FontSizes {
  static const iconHeaderFontSize = 40.0;
  static const sectionHeaderFontSize = 28.0;
  static const sectionSubheaderFontSize = 24.0;
  static const bigTextSize = 20.0;
  static const mediumTextSize = 16.0;
}

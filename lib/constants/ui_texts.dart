import 'package:flutter/material.dart';

class UITexts {
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

  static const mediumButtonText = TextStyle(
    fontSize: FontSizes.mediumTextSize,
    fontWeight: FontWeight.bold,
  );

  static const bigButtonText = TextStyle(
    fontSize: FontSizes.sectionSubheaderFontSize,
    fontWeight: FontWeight.bold,
  );
}

class FontSizes {
  static const sectionHeaderFontSize = 26.0;
  static const sectionSubheaderFontSize = 20.0;
  static const mediumTextSize = 16.0;
}

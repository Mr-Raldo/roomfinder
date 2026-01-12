import 'package:flutter/material.dart';

// Room Finder Color Palette - Blue & Teal Theme
const Color primaryColor = Color(0xFF2196F3); // Blue
const Color secondaryColor = Color(0xFF00BCD4); // Cyan/Teal
const Color accentColor = Color(0xFF4CAF50); // Green for success states
const Color darkBlue = Color(0xFF1976D2);
const Color lightBlue = Color(0xFF64B5F6);
const Color skyBlue = Color(0xFFE3F2FD);
const Color tealAccent = Color(0xFF80DEEA);
const Color charcoalBlack = Color(0xFF222222);
const Color coolGray = Color(0xFF666666);

// Background colors
const Color screenBGColor = Color(0xFFFAFAFA);
const Color whiteColor = Colors.white;
const Color blackColor = Colors.black;
const Color greyColor = Color(0xFFAAA9A9);
const Color greyD9Color = Color(0xFFD9D9D9);
const Color redColor = Color(0xFFE46554);
const Color yellowColor = Color(0xFFFFB300);

// Gradient definitions
const LinearGradient primaryGradient = LinearGradient(
  colors: [primaryColor, secondaryColor],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient subtleGradient = LinearGradient(
  colors: [skyBlue, tealAccent],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

// Spacing
const double fixPadding = 10.0;
const SizedBox heightSpace = SizedBox(height: fixPadding);
const SizedBox height5Space = SizedBox(height: 5.0);
const SizedBox height20Space = SizedBox(height: 20.0);
const SizedBox widthSpace = SizedBox(width: fixPadding);
const SizedBox width5Space = SizedBox(width: 5.0);
const SizedBox width20Space = SizedBox(width: 20.0);

// Shadows
final List<BoxShadow> boxShadow = [
  BoxShadow(
    color: blackColor.withOpacity(0.4),
    blurRadius: 10.0,
    offset: const Offset(0, 10),
  )
];

final List<BoxShadow> softShadow = [
  BoxShadow(
    color: blackColor.withOpacity(0.04),
    blurRadius: 12.0,
    offset: const Offset(0, 4),
  )
];

final List<BoxShadow> buttonShadow = [
  BoxShadow(
    color: primaryColor.withOpacity(0.3),
    blurRadius: 16.0,
    offset: const Offset(0, 8),
  )
];

// Text Styles
const TextStyle bold16Primary =
    TextStyle(color: primaryColor, fontSize: 16.0, fontWeight: FontWeight.w700);

const TextStyle bold18White =
    TextStyle(color: whiteColor, fontSize: 18.0, fontWeight: FontWeight.w700);

const TextStyle semibold16Primary =
    TextStyle(color: primaryColor, fontSize: 16.0, fontWeight: FontWeight.w600);

const TextStyle semibold14Primary =
    TextStyle(color: primaryColor, fontSize: 14.0, fontWeight: FontWeight.w600);

const TextStyle semibold16White =
    TextStyle(color: whiteColor, fontSize: 16.0, fontWeight: FontWeight.w600);

const TextStyle semibold14Grey =
    TextStyle(color: greyColor, fontSize: 14.0, fontWeight: FontWeight.w600);

const TextStyle medium16Grey =
    TextStyle(color: greyColor, fontSize: 16.0, fontWeight: FontWeight.w500);

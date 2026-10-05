import 'package:flutter/material.dart';

class AppShadows {
  static const BoxShadow neumorphicLight = BoxShadow(
    color: Color(0x1A000000), // black.withOpacity(0.12)
    offset: Offset(0, 4),
    blurRadius: 12,
    spreadRadius: 0,
  );

  static const BoxShadow neumorphicTopLight = BoxShadow(
    color: Color(0x4DFFFFFF), // white.withOpacity(0.3)
    offset: Offset(-2, -2),
    blurRadius: 8,
    spreadRadius: 0,
  );

  static const BoxShadow neumorphicDark = BoxShadow(
    color: Color(0x73000000), // black.withOpacity(0.45)
    offset: Offset(0, 4),
    blurRadius: 16,
    spreadRadius: 0,
  );

  static const BoxShadow cardGlow = BoxShadow(
    color: Color(0x1AFF6B35),
    offset: Offset(0, 4),
    blurRadius: 20,
    spreadRadius: 0,
  );
}

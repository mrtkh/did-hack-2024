import 'package:flutter/material.dart';

class AppColors {
  // Base colors
  static const backgroundColor = Color(0xFF171717);
  static const primaryBlue = Color(0xFF1F95C8);
  static const primaryPink = Color(0xFFDB5D9C);
  
  // Derived colors
  static const cardBackground = Color(0xFF2C2C2E);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFAAAAAA);
  
  // Gradient
  static const gradient = LinearGradient(
    colors: [primaryBlue, primaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Button colors
  static final selectedTagColor = primaryPink.withOpacity(0.8);
  static const unselectedTagColor = Color(0xFF2C2C2E);
} 
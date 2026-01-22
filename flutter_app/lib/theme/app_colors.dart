import 'package:flutter/material.dart';

// Modern Emerald Theme Colors
class AppColors {
  // Primary Colors
  static const Color emeraldPrimary = Color(0xFF059669);
  static const Color emeraldSecondary = Color(0xFF10B981);
  static const Color mintLight = Color(0xFF6EE7B7);
  static const Color mintPale = Color(0xFFD1FAE5);

  // Slate Colors
  static const Color slateDeep = Color(0xFF1E293B);
  static const Color slateMedium = Color(0xFF475569);
  static const Color slateLight = Color(0xFF94A3B8);
  static const Color slatePale = Color(0xFFF1F5F9);

  // Accent Colors
  static const Color coralAccent = Color(0xFFFF6B6B);
  static const Color amberAccent = Color(0xFFFBBF24);
  static const Color tealAccent = Color(0xFF14B8A6);

  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);

  // Category Colors
  static const Color categoryFood = Color(0xFFFF6B6B);
  static const Color categoryTransport = Color(0xFF4ECDC4);
  static const Color categoryShopping = Color(0xFFFFBE0B);
  static const Color categoryEntertainment = Color(0xFF9B59B6);
  static const Color categoryBills = Color(0xFF3498DB);
  static const Color categoryHealth = Color(0xFF2ECC71);
  static const Color categoryEducation = Color(0xFFE74C3C);
  static const Color categoryOthers = Color(0xFF95A5A6);

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return categoryFood;
      case 'transport':
        return categoryTransport;
      case 'shopping':
        return categoryShopping;
      case 'entertainment':
        return categoryEntertainment;
      case 'bills':
        return categoryBills;
      case 'health':
        return categoryHealth;
      case 'education':
        return categoryEducation;
      case 'salary':
        return tealAccent;
      case 'freelance':
        return emeraldSecondary;
      default:
        return categoryOthers;
    }
  }
}

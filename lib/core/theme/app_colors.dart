import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 800
  
  static const Color secondary = Color(0xFF0D9488); // Teal 600
  static const Color secondaryLight = Color(0xFF14B8A6); // Teal 500
  
  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Call Specific Semantic Colors
  static const Color incomingCall = Color(0xFF10B981); // Emerald
  static const Color outgoingCall = Color(0xFF3B82F6); // Blue
  static const Color endCall = Color(0xFFEF4444); // Red
  static const Color callActive = Color(0xFF10B981);
  static const Color callMuted = Color(0xFFF59E0B);
  
  // Light Theme Colors
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLight = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceContainerHighestLight = Color(0xFFE2E8F0); // Slate 200
  
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF475569); // Slate 600
  static const Color borderLight = Color(0xFFCBD5E1); // Slate 300
  
  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color surfaceContainerDark = Color(0xFF0B1120); // Slate 950
  static const Color surfaceContainerHighestDark = Color(0xFF334155); // Slate 700
  
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color borderDark = Color(0xFF334155); // Slate 700
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkSurfaceGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient callBackgroundGradient = LinearGradient(
    colors: [Color(0xFF312E81), Color(0xFF0F172A)], // Indigo 900 to Slate 900
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

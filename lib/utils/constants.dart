import 'package:flutter/material.dart';

class AppColors {
  static const Color sunnyTop = Color(0xFF4A90E2);
  static const Color sunnyBottom = Color(0xFF50E3C2);
  
  static const Color rainyTop = Color(0xFF2C3E50);
  static const Color rainyBottom = Color(0xFF3498DB);
  
  static const Color cloudyTop = Color(0xFF7F8C8D);
  static const Color cloudyBottom = Color(0xFFBDC3C7);
  
  static const Color nightTop = Color(0xFF141E30);
  static const Color nightBottom = Color(0xFF243B55);

  static const Color textLight = Colors.white;
  static const Color textDark = Colors.black87;
}

class AppStyles {
  static const TextStyle headline = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
  );
  
  static const TextStyle temperature = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
  );
  
  static const TextStyle subhead = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textLight,
  );
}

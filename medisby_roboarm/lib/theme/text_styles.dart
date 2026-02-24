import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Display: 로고/모달 제목 (42-44px) ──
  static TextStyle get displayLarge => GoogleFonts.notoSansKr(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        height: 1.0,
        color: AppColors.textBlack,
      );

  static TextStyle get displayMedium => GoogleFonts.notoSansKr(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.textWhite,
      );

  // ── Heading: 섹션 제목 (28-32px) ──
  static TextStyle get headingLarge => GoogleFonts.notoSansKr(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.125,
        color: AppColors.textWhite,
      );

  static TextStyle get headingMedium => GoogleFonts.notoSansKr(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.textWhite,
      );

  // ── Title: 본문 제목 / 버튼 라벨 (22-24px) ──
  static TextStyle get titleLarge => GoogleFonts.notoSansKr(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.5,
        color: AppColors.textWhite,
      );

  static TextStyle get titleMedium => GoogleFonts.notoSansKr(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        height: 1.25,
        color: AppColors.textWhite,
      );

  static TextStyle get titleSmall => GoogleFonts.notoSansKr(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.textWhite,
      );

  // ── Body: 메뉴/상태 텍스트 (18px) ──
  static TextStyle get bodyLarge => GoogleFonts.notoSansKr(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.textWhite,
      );

  static TextStyle get bodyMedium => GoogleFonts.notoSansKr(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.2,
        color: AppColors.textWhite,
      );

  // ── Caption: 상태바/보조 텍스트 (16px) ──
  static TextStyle get caption => GoogleFonts.notoSansKr(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.textWhite,
      );

  static TextStyle get captionLight => GoogleFonts.notoSansKr(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.2,
        color: AppColors.textGray,
      );
}

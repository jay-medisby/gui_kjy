import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Background ──
  static const Color background = Color(0xFF002060); // 메인 배경 (Deep Navy)
  static const Color sidebarBackground = Color(0xFF444444); // 사이드바/섹션 배경

  // ── Surface / Card ──
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color cardBlack = Color(0xFF000000);

  // ── Primary Buttons ──
  static const Color green = Color(0xFF10B981); // 상태 표시, Ready, 액션 버튼
  static const Color blue = Color(0xFF3B82F6); // Start 버튼 (활성)
  static const Color blueDeep = Color(0xFF3057B9); // Online 상태 표시
  static const Color red = Color(0xFFFF6D6D); // 경고, Exit
  static const Color orange = Color(0xFFFF8C42); // 경고 상태 텍스트

  // ── Neutral / Disabled ──
  static const Color grayHighlight = Color(0xFFA6A6A6); // 비활성 하이라이트 버튼
  static const Color grayDark = Color(0xFF404040); // 상태 보조 텍스트
  static const Color mintGreen = Color(0xFFE6FFE8); // Home 이동 버튼 배경

  // ── Text ──
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textBlack = Color(0xFF000000);
  static const Color textGray = Color(0xFF404040);
  static const Color textGreen = Color(0xFF10B981);
  static const Color textRed = Color(0xFFFF6D6D);
  static const Color textOrange = Color(0xFFFF8C42);

  // ── Overlay ──
  static const Color modalOverlay = Color(0x99000000); // rgba(0,0,0,0.6)
  static const Color modalOverlayDark = Color(0xCC000000); // rgba(0,0,0,0.8)

  // ── Semi-transparent ──
  static const Color statusBarBg = Color(0x1AFFFFFF); // rgba(255,255,255,0.1)
  static const Color buttonInactive = Color(0x0DFFFFFF); // rgba(255,255,255,0.05)

  // ── Stroke / Border ──
  static const Color borderLight = Color(0x1AFFFFFF); // rgba(255,255,255,0.1)
  static const Color borderDark = Color(0x4D000000); // rgba(0,0,0,0.3)
  static const Color borderGray = Color(0x808899A6); // rgba(136,153,166,0.5)
  static const Color borderGreen = Color(0xFF10B981);

  // ── Settings Modal ──
  static const Color settingsCardBg = Color(0xFF262626); // 다크 모달 카드 배경
  static const Color settingsCardBorder = Color(0xFF404040); // 카드 내 row 테두리

  // ── Stop Flow ──
  static const Color emergencyBg = Color(0xFF2B0E0E); // 비상정지 모달 배경
  static const Color emergencyAccent = Color(0xFFFF0000); // 비상정지 강조색
  static const Color safeBg = Color(0xFF3B3B10); // 보호정지 모달 배경
  static const Color safeAccent = Color(0xFFCCB800); // 보호정지 강조색
}

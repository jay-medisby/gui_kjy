import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../theme/colors.dart';

/// 모든 프리뷰에서 공유하는 wrapper — Provider + MaterialApp(다크 테마) 주입
Widget previewWrapper(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => DeviceProvider()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          surface: AppColors.background,
          primary: AppColors.blue,
          error: AppColors.red,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: child,
      ),
    ),
  );
}

/// Preview theme 콜백
PreviewThemeData medisbyTheme() {
  return PreviewThemeData(
    materialDark: ThemeData(
      colorScheme: ColorScheme.dark(
        surface: AppColors.background,
        primary: AppColors.blue,
        error: AppColors.red,
      ),
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
    ),
  );
}

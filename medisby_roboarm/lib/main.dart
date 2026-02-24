import 'package:flutter/material.dart';
import 'models/menu_type.dart';
import 'widgets/app_scaffold.dart';
import 'theme/colors.dart';
import 'theme/text_styles.dart';

void main() {
  runApp(const MedisbyApp());
}

class MedisbyApp extends StatelessWidget {
  const MedisbyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medisby ROBOARM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF002060)),
      ),
      home: const _DemoHome(),
    );
  }
}

/// 임시 데모 화면 — AppScaffold 동작 확인용
class _DemoHome extends StatefulWidget {
  const _DemoHome();

  @override
  State<_DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<_DemoHome> {
  MenuType _currentMenu = MenuType.start;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentMenu: _currentMenu,
      onMenuTap: (menu) => setState(() => _currentMenu = menu),
      child: Center(
        child: Text(
          '${_currentMenu.label} 화면',
          style: AppTextStyles.headingLarge.copyWith(
            color: AppColors.textWhite,
          ),
        ),
      ),
    );
  }
}

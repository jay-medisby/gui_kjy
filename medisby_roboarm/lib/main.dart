import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/device_provider.dart';
import 'router.dart';
import 'theme/colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 랜드스케이프 고정 (Android/모바일 대응)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MedisbyApp());
}

class MedisbyApp extends StatelessWidget {
  const MedisbyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
      ],
      child: MaterialApp.router(
        title: 'Medisby ROBOARM',
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
        routerConfig: appRouter,
      ),
    );
  }
}

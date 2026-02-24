import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';

class VelTestFlow extends StatelessWidget {
  const VelTestFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '속도 테스트',
        style: AppTextStyles.headingLarge.copyWith(color: AppColors.textWhite),
      ),
    );
  }
}

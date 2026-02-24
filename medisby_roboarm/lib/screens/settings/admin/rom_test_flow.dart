import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';

class RomTestFlow extends StatelessWidget {
  const RomTestFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'ROM 테스트',
        style: AppTextStyles.headingLarge.copyWith(color: AppColors.textWhite),
      ),
    );
  }
}

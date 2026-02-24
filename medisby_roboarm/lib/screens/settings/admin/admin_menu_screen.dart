import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';

class AdminMenuScreen extends StatelessWidget {
  const AdminMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Admin',
        style: AppTextStyles.headingLarge.copyWith(color: AppColors.textWhite),
      ),
    );
  }
}

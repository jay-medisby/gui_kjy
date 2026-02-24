import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '사용자 관리',
        style: AppTextStyles.headingLarge.copyWith(color: AppColors.textWhite),
      ),
    );
  }
}

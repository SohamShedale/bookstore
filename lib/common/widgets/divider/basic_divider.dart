import 'package:bookstore/core/configs/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BasicDivider extends StatelessWidget {
  const BasicDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Divider(
            color: AppColors.grey,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Text("or"),
        ),
        Expanded(
          flex: 1,
          child: Divider(
            color: AppColors.grey,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

import 'package:bookstore/core/configs/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BasicAppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final Color? color;
  final bool border;
  const BasicAppButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.color,
    this.border = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: Size(
            double.infinity,
            50,
          ),
          backgroundColor: (color != null) ? color : AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
            side: (border)
                ? BorderSide(
                    color: Colors.white,
                  )
                : BorderSide.none,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: (color != null) ? AppColors.primary : Colors.white,
          ),
        ));
  }
}

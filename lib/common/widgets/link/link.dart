import 'package:bookstore/core/configs/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Link extends StatelessWidget {
  final String text;
  final String link;
  final Widget page;
  const Link({
    super.key,
    required this.text,
    required this.link,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(
            color: AppColors.grey,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (BuildContext context) => page),
            );
          },
          child: Text(
            link,
            style: TextStyle(
              color: Color(0xff787878),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

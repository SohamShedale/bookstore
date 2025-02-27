import 'package:bookstore/common/widgets/button/basic_app_button.dart';
import 'package:bookstore/core/configs/assets/app_images.dart';
import 'package:bookstore/core/configs/theme/app_colors.dart';
import 'package:bookstore/pages/auth/pages/sign_in.dart';
import 'package:bookstore/pages/auth/pages/sign_up.dart';
import 'package:flutter/material.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              top: 60,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppImages.logo,
                ),
                SizedBox(
                  height: 70,
                ),
                Text(
                  "Welcome",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                  ),
                ),
                Text(
                  "Read without limits",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 70,
                ),
                BasicAppButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => SignUp(),
                      ),
                    );
                  },
                  title: "Create Account",
                  color: Colors.white,
                ),
                SizedBox(
                  height: 30,
                ),
                BasicAppButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => SignIn(),
                      ),
                    );
                  },
                  title: "Log in",
                  border: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

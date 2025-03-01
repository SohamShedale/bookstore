import 'package:bookstore/common/widgets/button/basic_app_button.dart';
import 'package:bookstore/core/configs/theme/app_colors.dart';
import 'package:bookstore/provider/api_calls_provider.dart';
import 'package:bookstore/provider/auth_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  final BuildContext homeContext;
  const CustomDrawer({super.key, required this.homeContext});

  @override
  Widget build(BuildContext context) {
    final apiProvider =
        Provider.of<ApiCallsProvider>(homeContext, listen: false);
    final authUser = Provider.of<AuthUserProvider>(homeContext, listen: false);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.only(
          left: 8,
          top: 40,
          right: 8,
        ),
        children: [
          ListTile(
            title: Text(
              "ALPHA Bookstore",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pushReplacementNamed(homeContext, "/home");
            },
            leading: Icon(Icons.home),
            title: Text("Home"),
          ),
          ListTile(
            onTap: () {
              Navigator.pushReplacementNamed(homeContext, "/wishlist");
            },
            leading: Icon(Icons.favorite_border),
            title: Text("My Wish List"),
          ),
          ListTile(
            onTap: () {
              Navigator.pushReplacementNamed(homeContext, "/mycart");
            },
            leading: Icon(Icons.trolley),
            title: Text("My Cart"),
          ),
          (apiProvider.userDetails != null)
              ? BasicAppButton(
                  onPressed: () async {
                    await apiProvider.clearUserDetails();
                    await authUser.signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        homeContext,
                        "/signin",
                        (route) => false,
                      );
                    }
                  },
                  title: "Sign Out",
                )
              : BasicAppButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      homeContext,
                      "/signin",
                      (route) => false,
                    );
                  },
                  title: "Sign In",
                ),
        ],
      ),
    );
  }
}

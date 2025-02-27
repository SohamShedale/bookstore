import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:bookstore/common/widgets/button/basic_app_button.dart';
import 'package:bookstore/common/widgets/divider/basic_divider.dart';
import 'package:bookstore/common/widgets/link/link.dart';
import 'package:bookstore/common/widgets/loading/loading.dart';
import 'package:bookstore/core/configs/assets/app_images.dart';
import 'package:bookstore/core/configs/theme/app_colors.dart';
import 'package:bookstore/pages/auth/pages/sign_up.dart';
import 'package:bookstore/provider/auth_user_provider.dart';
import 'package:bookstore/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late TextEditingController _email;
  late TextEditingController _password;
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authUser = Provider.of<AuthUserProvider>(context, listen: false);
      if (authUser.user != null) {
        Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
      }
    });
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthUserProvider>(builder: (context, authUser, child) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (authUser.errorMessage != null) {
          showSnackBar(
            context,
            authUser.errorMessage!,
            ContentType.failure,
          );
          authUser.clearErrorMessage();
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (authUser.successMessage != null) {
          showSnackBar(
            context,
            authUser.successMessage!,
            ContentType.success,
          );
          authUser.clearSuccessMessage();
        }
      });
      return Scaffold(
        body: Stack(
          children: [
            if (authUser.isLoading) Loading(),
            SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 150,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Image.asset(
                          AppImages.logo2,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        _emailField(),
                        SizedBox(
                          height: 30,
                        ),
                        _passwordField(),
                        SizedBox(
                          height: 30,
                        ),
                        BasicAppButton(
                          onPressed: () async {
                            bool success = _formKey.currentState!.validate();
                            if (success) {
                              await authUser.signInWithEmailAndPassword(
                                _email.text,
                                _password.text,
                              );
                              if (authUser.user != null) {
                                _email.clear();
                                _password.clear();
                                if (context.mounted) {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    "/home",
                                    (route) => false,
                                  );
                                }
                              }
                            }
                          },
                          title: "Log In",
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Link(
                          text: "Don't have an account? ",
                          link: "Sign up here",
                          page: SignUp(),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        BasicDivider(),
                        SizedBox(
                          height: 30,
                        ),
                        _googleSignInButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _emailField() {
    return TextFormField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: "tricia@gmail.com",
        hintStyle: TextStyle(
          color: AppColors.grey,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.grey,
          ),
        ),
      ),
      validator: (value) {
        RegExp regExp =
            RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
        return regExp.hasMatch(value!) ? null : "Enter valid email";
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _password,
      obscureText: _obscureText,
      obscuringCharacter: "*",
      decoration: InputDecoration(
        errorMaxLines: 2,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          icon: (_obscureText)
              ? Icon(Icons.visibility)
              : Icon(Icons.visibility_off),
        ),
        hintText: "***********",
        hintStyle: TextStyle(
          color: AppColors.grey,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.grey,
          ),
        ),
      ),
      validator: (value) {
        RegExp regExp =
            RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$");
        return regExp.hasMatch(value!)
            ? null
            : "Password is too weak. Please include uppercase, lowercase, and numbers.";
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget _googleSignInButton() {
    final authUser = Provider.of<AuthUserProvider>(context, listen: false);
    return SignInButton(
      onPressed: () async {
        await authUser.signInWithGoogle();
        if (mounted) {
          if (authUser.user != null) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/home",
              (route) => false,
            );
          }
        }
      },
      Buttons.google,
    );
  }
}

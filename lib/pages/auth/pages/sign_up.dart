import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:bookstore/common/widgets/button/basic_app_button.dart';
import 'package:bookstore/common/widgets/divider/basic_divider.dart';
import 'package:bookstore/common/widgets/link/link.dart';
import 'package:bookstore/common/widgets/loading/loading.dart';
import 'package:bookstore/core/configs/assets/app_images.dart';
import 'package:bookstore/core/configs/theme/app_colors.dart';
import 'package:bookstore/pages/auth/pages/sign_in.dart';
import 'package:bookstore/provider/auth_user_provider.dart';
import 'package:bookstore/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late TextEditingController _fullName;
  late TextEditingController _email;
  late TextEditingController _password;
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _fullName = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthUserProvider>(
        builder: (context, authUser, child) {
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
            (authUser.isLoading)
                ? Loading()
                : SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 80,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Image.asset(
                                AppImages.logo2,
                              ),
                              SizedBox(
                                height: 60,
                              ),
                              _fullNameField(),
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
                                  bool success =
                                      _formKey.currentState!.validate();
                                  if (success) {
                                    final isUserCreated = await authUser
                                        .signUpWithEmailAndPassword(
                                      _fullName.text,
                                      _email.text,
                                      _password.text,
                                    );
                                    if (isUserCreated) {
                                      _fullName.clear();
                                      _email.clear();
                                      _password.clear();
                                      if (context.mounted) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          "/home",
                                        );
                                      }
                                    }
                                  }
                                },
                                title: "Create Account",
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Link(
                                text: "Already have an account? ",
                                link: "Log in here",
                                page: SignIn(),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              BasicDivider(),
                              SizedBox(
                                height: 30,
                              ),
                              _googleSignUpButton(),
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

  Widget _fullNameField() {
    return TextFormField(
      controller: _fullName,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "Tricia",
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
      validator: (name) =>
          (name!.length < 3) ? "Name should be at least 3 characters" : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
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

  Widget _googleSignUpButton() {
    final authUser =
        Provider.of<AuthUserProvider>(context, listen: false);
    return SignInButton(
      onPressed: () async {
        await authUser.signInWithGoogle();
        if (mounted) {
          if (authUser.user != null) {
            Navigator.pushReplacementNamed(
              context,
              "/home",
            );
          }
        }
      },
      Buttons.google,
      text: "Sign up with Google",
    );
  }
}

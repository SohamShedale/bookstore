import 'package:bookstore/firebase_options.dart';
import 'package:bookstore/pages/auth/pages/sign_in.dart';
import 'package:bookstore/pages/auth/pages/sign_up.dart';
import 'package:bookstore/pages/books/pages/home.dart';
import 'package:bookstore/pages/cart/my_cart.dart';
import 'package:bookstore/pages/welcome/pages/on_boarding_page.dart';
import 'package:bookstore/provider/api_calls_provider.dart';
import 'package:bookstore/provider/auth_user_provider.dart';
import 'package:bookstore/provider/cart_provider.dart';
import 'package:bookstore/provider/wish_list_provider.dart';
import 'package:bookstore/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.instance.initialize();

  final authUserProvider = AuthUserProvider();
  await authUserProvider.initAuthState();
  runApp(MyApp(
    initialRoute: authUserProvider.user != null ? "/home" : "/onboarding",
    authUserProvider: authUserProvider,
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final AuthUserProvider authUserProvider;
  MyApp({
    super.key,
    required this.initialRoute,
    required this.authUserProvider,
  });
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: authUserProvider,
        ),
        ChangeNotifierProvider(create: (context) => ApiCallsProvider()),
        ChangeNotifierProvider(create: (context) => WishListProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MaterialApp(
        routes: {
          "/onboarding": (context) => OnBoardingPage(),
          "/singup": (context) => SignUp(),
          "/signin": (context) => SignIn(),
          "/home": (context) => Home(),
          "/mycart": (context) => MyCart(),
        },
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
      ),
    );
  }
}

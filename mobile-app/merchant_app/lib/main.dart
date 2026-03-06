import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const MerchantApp());
}

class MerchantApp extends StatelessWidget {
  const MerchantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Merchant Dashboard',
      theme: AppTheme.lightTheme(context),
      initialRoute: SplashScreen.routeName,
      routes: routes,
    );
  }
}
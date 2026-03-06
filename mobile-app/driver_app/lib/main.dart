import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:driver_app/View/Themes/app_theme.dart' as theme;
import 'package:driver_app/View/Screens/Main_Screens/Home_Screen/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set status bar to transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weasy',
      debugShowCheckedModeBanner: false,
      theme: theme.AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
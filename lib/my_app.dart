import 'package:flutter/material.dart';
import 'package:spider_doctor/features/auth/view/screen/login_screen.dart';
import 'package:spider_doctor/features/auth/view/screen/signup_screen.dart';
import 'package:spider_doctor/features/home/view/screen/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        'login': (context) => LoginScreen(),
        'signup': (context) => SignUpScreen(),
        'home': (context) => HomeScreen(),
      },

      title: 'Flutter Demo',
      home: LoginScreen(),
    );
  }
}

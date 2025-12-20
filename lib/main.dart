import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'screens/login.dart';

// Define custom colors (use 0xFF for fully opaque ARGB)
const Color primaryColor = Color(0xFF005F73);
const Color secondaryColor = Color(0x00ee9b00);

void main() {
  runApp(const HoopHubApp());
}

class HoopHubApp extends StatelessWidget {
  const HoopHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<CookieRequest>(
      create: (_) => CookieRequest(),
      child: MaterialApp(
        title: 'hoophub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData( 
          useMaterial3: true,
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(seedColor: primaryColor).copyWith(secondary: secondaryColor,
          ),
        ),
        home: LoginPage(),
      ),
    );
  }
}
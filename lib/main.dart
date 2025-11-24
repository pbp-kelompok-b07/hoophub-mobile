import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'screens/login.dart';

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
        title: 'HoopHub Mobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF006B6B), // mirip warna web
          ),
        ),
        home: const LoginPage(),
      ),
    );
  }
}

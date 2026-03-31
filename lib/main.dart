import 'package:flutter/material.dart';
import 'admin/screens/admin_login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grampanchayat Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF800000)),
        useMaterial3: true,
      ),
      home: const AdminLoginScreen(),
    );
  }
}

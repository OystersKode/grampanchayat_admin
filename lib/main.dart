import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'admin/services/auth_service.dart';
import 'admin/services/member_requests_service.dart';
import 'admin/services/news_service.dart';
import 'admin/screens/admin_login_screen.dart';

void main() {
  AuthService.initialize();
  NewsService.initialize();
  MemberRequestsService.initialize();
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('mr', ''),
        Locale('hi', ''),
      ],
      home: const AdminLoginScreen(),
    );
  }
}

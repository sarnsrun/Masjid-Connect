import 'package:flutter/material.dart';
import 'screens/login_page.dart';

void main() {
  runApp(const MasjidConnectApp());
}

class MasjidConnectApp extends StatelessWidget {
  const MasjidConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masjid Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A4D3C),
        ),
      ),
      
      // Set the Login Page as the first screen
      home: const LoginPage(),
    );
  }
}

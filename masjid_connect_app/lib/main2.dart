import 'package:flutter/material.dart';


// --- IMPORTS ---
import 'navigation_layout.dart'; 
import 'screens/splash_screen.dart'; 

// --- PAGE IMPORTS FOR ROUTES ---
import 'package:masjid_connect_app/screens/homepage.dart';


void main() {
  

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TimeFission',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A7BEE), 
        ),
      ),

      // 1. CHANGE: Start directly with SplashScreen
      home: const SplashScreen(), 

     
    );
  }
}


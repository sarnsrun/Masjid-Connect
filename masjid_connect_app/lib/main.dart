import 'package:flutter/material.dart';


// --- IMPORTS ---
import 'navigation_layout.dart'; 

// --- PAGE IMPORTS FOR ROUTES ---
import 'package:masjid_connect_app/screens/homepage.dart';


void main() {
  

  runApp(const MasjidConnectApp());
}

class MasjidConnectApp extends StatelessWidget {
  const MasjidConnectApp({super.key});

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

home: const MainLayout(),
    
     
    );
  }
}


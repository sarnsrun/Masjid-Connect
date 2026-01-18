import 'package:flutter/material.dart';
import 'package:masjid_connect_app/screens/homepage.dart';

// --- IMPORT YOUR PAGES ---
// Ensure these paths match your project structure exactly
import 'package:masjid_connect_app/screens/homepage.dart';


class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // The pages corresponding to your bottom tabs
  final List<Widget> _pages = const [
    HomePage(),           // Index 0
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserves page state when switching tabs
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color.fromARGB(226, 255, 255, 255),
        indicatorColor: const Color(0xFF4A7BEE).withOpacity(0.3),
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Donation',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Tasbih',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: 'Events',
          ),
           NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Masjid Info',
          ), 
        ],
      ),
    );
  }
}
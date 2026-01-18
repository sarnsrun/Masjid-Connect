import 'package:flutter/material.dart';
import 'package:masjid_connect_app/screens/homepage.dart';
import 'package:masjid_connect_app/screens/donation_page.dart';

// --- COLOR CONSTANTS (Adjust these to match your theme) ---
const Color kPrimaryGreen = Color(0xFF0D5D40); // Example Green
const Color kAccentGold = Color(0xFFD4AF37);   // Example Gold
const Color kInactiveGrey = Colors.white54;    // Example Inactive color

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // The pages corresponding to your bottom tabs
  // NOTE: I added placeholders for the missing pages so the app doesn't crash
  final List<Widget> _pages = const [
    HomePage(),                     // Index 0: Home
    DonationPage(),                  // Index 1: Donation
    Center(child: Text("Tasbih Page")),   // Index 2: Tasbih (Placeholder)
    Center(child: Text("Events Page")),   // Index 3: Events (Placeholder)
    Center(child: Text("Info Page")),     // Index 4: Info (Placeholder)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserves page state when switching tabs
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // We extend the body behind the bottom bar so the floating effect looks good
      extendBody: true, 
      
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- CUSTOM NAVIGATION BUILDER ---
  Widget _buildBottomNavBar() {
    return Padding(
      // Add padding to make it "float" above the bottom edge
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), 
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: kPrimaryGreen,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home, "Home"),
            _buildNavItem(1, Icons.volunteer_activism, "Donation"),
            // Make sure "assets/images/tasbih_false.png" exists in pubspec.yaml
            _buildNavImageItem(2, "assets/images/tasbih_false.png", "Tasbih"), 
            _buildNavItem(3, Icons.calendar_month, "Events"),
            _buildNavItem(4, Icons.info_outline, "Masjid Info"),
          ],
        ),
      ),
    );
  }

  // Modified to handle onTap and Index checking
  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque, // Ensures the whole area is clickable
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, 
            color: isActive ? kAccentGold : kInactiveGrey, 
            size: 24
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? kAccentGold : kInactiveGrey,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }

  // Modified to handle onTap and Index checking for Images
  Widget _buildNavImageItem(int index, String assetPath, String label) {
    bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            assetPath,
            width: 24,
            height: 24,
            // Apply color filter to image to match active/inactive state
            color: isActive ? kAccentGold : kInactiveGrey,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.error, 
              color: kInactiveGrey,
              size: 24,
            ), 
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? kAccentGold : kInactiveGrey,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}
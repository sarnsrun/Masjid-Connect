import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/homepage.dart';
import 'screens/donation_page.dart';
import 'screens/tasbih_page.dart';
import 'screens/login_page.dart';
import 'screens/events_list_page.dart';

// --- COLOR CONSTANTS ---
const Color kPrimaryGreen = Color(0xFF0A4D3C);
const Color kAccentGold = Color(0xFFC5A059);
const Color kInactiveGrey = Colors.white54;

class MainLayout extends StatefulWidget {
  final String userRole; 

  const MainLayout({super.key, required this.userRole});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _titles = [
    "Masjid-Connect",
    "Donation Campaign",
    "Digital Tasbih",
    "Upcoming Events",
    "Masjid Info"
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      DonationPage(userRole: widget.userRole, currentMasjidName: ""), 
      const TasbihPage(),
      EventsListPage(userRole: widget.userRole, currentMasjidName: ""),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFD3E2DF),
      
      // 1. GLOBAL HEADER
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80), 
        child: Container(
          padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
          decoration: const BoxDecoration(
            color: kPrimaryGreen,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
            ]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: kAccentGold, size: 30),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Text(
                _titles[_currentIndex],
                style: const TextStyle(
                  color: kAccentGold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person, color: kAccentGold, size: 30),
                onPressed: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => const LoginPage()),
                   );
                },
              ),
            ],
          ),
        ),
      ),

      // 2. SMART SIDEBAR (Now receives the role!)
      drawer: SidebarMenu(userRole: widget.userRole),

      // 3. BODY CONTENT
      extendBody: true, 
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildFloatingNavBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 25), 
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: kPrimaryGreen,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Home", 0),
            _buildNavItem(Icons.volunteer_activism, "Donation", 1),
            _buildNavImageItem("assets/images/tasbih_false.png", "Tasbih", 2),
            _buildNavItem(Icons.calendar_month, "Events", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? kAccentGold : kInactiveGrey, size: 26),
          if (isActive) ...[
             const SizedBox(height: 4),
             Container(width: 4, height: 4, decoration: const BoxDecoration(color: kAccentGold, shape: BoxShape.circle))
          ]
        ],
      ),
    );
  }

  Widget _buildNavImageItem(String assetPath, String label, int index) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            assetPath, 
            width: 26, 
            height: 26, 
            color: isActive ? kAccentGold : kInactiveGrey,
            errorBuilder: (c,e,s) => const Icon(Icons.error, color: kInactiveGrey),
          ),
          if (isActive) ...[
             const SizedBox(height: 4),
             Container(width: 4, height: 4, decoration: const BoxDecoration(color: kAccentGold, shape: BoxShape.circle))
          ]
        ],
      ),
    );
  }
}

// --- UPDATED SIDEBAR MENU CLASS ---
class SidebarMenu extends StatefulWidget {
  final String userRole;
  
  const SidebarMenu({super.key, required this.userRole});

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  String _userName = "Loading..."; // Default text
  String _email = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch the Name from Firestore
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (mounted && userDoc.exists) {
          setState(() {
            _userName = userDoc['name'] ?? "Masjid Member";
            _email = userDoc['email'] ?? "";
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine Role Display Text
    String roleDisplay = widget.userRole == 'admin' ? "Masjid Admin" : "Masjid Member";

    return Drawer(
      backgroundColor: kPrimaryGreen, 
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF083E30)), 
            // 1. Show Real Name
            accountName: Text(
              _userName, 
              style: const TextStyle(color: kAccentGold, fontWeight: FontWeight.bold, fontSize: 18)
            ),
            // 2. Show Role & Email
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(roleDisplay, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                if (_email.isNotEmpty) Text(_email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: kAccentGold,
              child: Icon(
                widget.userRole == 'admin' ? Icons.admin_panel_settings : Icons.person, 
                color: kPrimaryGreen, 
                size: 40
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(Icons.exit_to_app, "Log Out", () {
                    Navigator.pop(context);
                    // Sign out from Firebase
                    FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                }),
                _buildMenuItem(Icons.settings_outlined, "Settings", () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: kAccentGold),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
    );
  }
}
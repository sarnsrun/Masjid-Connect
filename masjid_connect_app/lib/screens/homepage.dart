import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:masjid_connect_app/screens/events_list_page.dart';

// --- PAGE IMPORTS ---
import 'login_page.dart';
import 'donation_page.dart';
import 'tasbih_page.dart';
import 'event_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- 1. SETUP & VARIABLES ---
  
  // Key to control the Scaffold (for opening the Drawer)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Color Palette
  final Color kPrimaryGreen = const Color(0xFF0A4D3C);
  final Color kAccentGold = const Color(0xFFC5A059);
  final Color kInactiveGrey = const Color(0xFF8FA7A3);

  // Location Variables
  String _currentAddress = "Locating...";
  String _mosqueName = "Finding nearest mosque...";

  // Data Variables
  List<Map<String, String>> _prayerTimes = []; 
  String _nextPrayerName = "Fajr"; 

  // Timer Logic Variables
  Timer? _timer;
  DateTime? _targetAdhanTime; 
  DateTime? _targetIqamatTime;
  Duration _timeUntilAdhan = Duration.zero;
  Duration _timeUntilIqamat = Duration.zero;

  // Bottom Nav Selection
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _getUserLocation();
  }

  // --- 2. LOCATION & API LOGIC ---

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check GPS
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _currentAddress = "Location services disabled");
      return;
    }

    // Check Permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _currentAddress = "Location permission denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _currentAddress = "Location permissions are permanently denied");
      return;
    }

    // Get Position
    try {
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude
      );

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress = "${place.locality}, ${place.administrativeArea}";
        
        // Logic to simulate finding specific mosque
        if (place.administrativeArea != null && place.administrativeArea!.contains("Selangor")) {
           _mosqueName = "SULTAN HAJI AHMAD SHAH MOSQUE";
        } else {
           _mosqueName = "CITY CENTRAL MOSQUE";
        }
      });

      // Fetch Prayer Times
      _fetchPrayerTimes(place.locality ?? "Kuala Lumpur");

    } catch (e) {
      setState(() => _currentAddress = "Failed to get address");
      print(e);
    }
  }

  Future<void> _fetchPrayerTimes(String city) async {
    // Determine Zone Code
    String zoneCode = "WLY01"; // Default KL
    String c = city.toLowerCase();
    
    if (c.contains("gombak") || c.contains("petaling") || c.contains("shah alam")) {
      zoneCode = "SGR01"; 
    } else if (c.contains("johor bahru")) {
      zoneCode = "JHR02";
    } else if (c.contains("kuantan")) {
      zoneCode = "PHG02";
    }

    // Call JAKIM API
    final url = Uri.parse("https://www.e-solat.gov.my/index.php?r=esolatApi/TakwimSolat&period=today&zone=$zoneCode");
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final times = data['prayerTime'][0];

        if (mounted) {
          setState(() {
            _prayerTimes = [
              {"name": "Fajr", "time": _cleanTime(times['fajr'])},
              {"name": "Syuruk", "time": _cleanTime(times['syuruk'])},
              {"name": "Dhuhr", "time": _cleanTime(times['dhuhr'])},
              {"name": "Asr", "time": _cleanTime(times['asr'])},
              {"name": "Maghrib", "time": _cleanTime(times['maghrib'])},
              {"name": "Isha", "time": _cleanTime(times['isha'])},
            ];
            
            // Recalculate timer immediately
            _calculateNextPrayer();
          });
        }
      }
    } catch (e) {
      print("Error fetching prayer times: $e");
    }
  }

  String _cleanTime(String fullTime) {
    if (fullTime.length >= 5) {
      return fullTime.substring(0, 5);
    }
    return fullTime;
  }

  // --- 3. SMART TIMER LOGIC ---

  void _calculateNextPrayer() {
    if (_prayerTimes.isEmpty) return;

    final now = DateTime.now();
    DateTime? upcomingPrayerTime;
    String upcomingName = "Fajr";

    // Loop to find next prayer today
    for (var i = 0; i < _prayerTimes.length; i++) {
      final pName = _prayerTimes[i]["name"]!;
      final pTime = _prayerTimes[i]["time"]!;

      if (pName == "Syuruk") continue; // Skip sunrise

      final parts = pTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final candidateTime = DateTime(now.year, now.month, now.day, hour, minute);

      if (candidateTime.isAfter(now)) {
        upcomingPrayerTime = candidateTime;
        upcomingName = pName;
        break; 
      }
    }

    // If none left today, target tomorrow's Fajr
    if (upcomingPrayerTime == null) {
      final fajrTime = _prayerTimes[0]["time"]!;
      final parts = fajrTime.split(':');
      final tomorrow = now.add(const Duration(days: 1));
      
      upcomingPrayerTime = DateTime(
        tomorrow.year, tomorrow.month, tomorrow.day, 
        int.parse(parts[0]), int.parse(parts[1])
      );
      upcomingName = "Fajr";
    }

    setState(() {
      _nextPrayerName = upcomingName;
      _targetAdhanTime = upcomingPrayerTime;
      _targetIqamatTime = upcomingPrayerTime!.add(const Duration(minutes: 5));
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_targetAdhanTime == null) return; 

      final now = DateTime.now();
      
      if (mounted) {
        setState(() {
          _timeUntilAdhan = _targetAdhanTime!.difference(now);
          _timeUntilIqamat = _targetIqamatTime!.difference(now);

          // If prayer passed, recalculate
          if (_timeUntilAdhan.isNegative) {
             _calculateNextPrayer();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return "00h 00m 00s";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${d.inHours}h ${twoDigitMinutes}m ${twoDigitSeconds}s";
  }

  // --- 4. UI BUILD ---

  // Content for Home Tab
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMosqueHeader(),
          const SizedBox(height: 10),
          _buildTimerCard(),
          const SizedBox(height: 10),
          _buildTimetableCard(),
        ],
      ),
    );
  }

  // Placeholder for missing Tabs
  Widget _buildPlaceholderPage(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: kAccentGold.withOpacity(0.5)),
          const SizedBox(height: 20),
          Text(
            "$title Page",
            style: TextStyle(color: kAccentGold, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text("Coming Soon", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pages List for IndexedStack
    // We insert your existing DonationPage and TasbihPage here
    final List<Widget> pages = [
      _buildHomeContent(),                  // Index 0: Home
      const DonationPage(),                 // Index 1: Donation (Loaded from file)
      const TasbihPage(),                   // Index 2: Tasbih (Loaded from file)
       EventsListPage(),            // Index 3: Events (Loaded from file)
      _buildPlaceholderPage("Masjid Info", Icons.info),
    ];

    // Titles for AppBar
    final List<String> titles = [
      "Masjid-Connect", "Donation", "Digital Tasbih", "Events", "Masjid Info"
    ];

    return Scaffold(
      key: _scaffoldKey, // Attach key here for Drawer
      drawer: const SidebarMenu(), // Attach the Sidebar
      extendBodyBehindAppBar: true, 
      
      body: Stack(
        children: [
          // A. BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFD3E2DF), // Light Sage Green
                  Color(0xFFF6F1E9), // Cream
                  Color(0xFFF6F1E9),
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // B. BACKGROUND PATTERN (Watermark)
          Positioned(
            top: 100,
            right: -100,
            child: Transform.rotate(
              angle: 0.2,
              child: Icon(
                Icons.star_border_rounded, 
                size: 400,
                color: kPrimaryGreen.withOpacity(0.05), 
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: -80,
            child: Transform.rotate(
              angle: -0.2,
              child: Icon(
                Icons.mosque_outlined, 
                size: 300,
                color: kAccentGold.withOpacity(0.05), 
              ),
            ),
          ),

          // C. MAIN CONTENT
          Column(
            children: [
              _buildCustomAppBar(titles[_selectedIndex]),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: pages,
                ),
              ),
            ],
          ),
          
          // D. FLOATING NAV BAR
          Positioned(
            left: 20,
            right: 20,
            bottom: 30, 
            child: _buildBottomNavBar(),
          ),
        ],
      ),
    );
  }

  // Header Widget
  Widget _buildCustomAppBar(String title) {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: kPrimaryGreen,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // MENU BUTTON -> Opens Drawer
          IconButton(
            icon: Icon(Icons.menu, color: kAccentGold, size: 30),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          Text(
            title,
            style: TextStyle(
              color: kAccentGold,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          // PROFILE BUTTON -> Link to Login Page
          IconButton(
            icon: Icon(Icons.person, color: kAccentGold, size: 30),
            onPressed: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const LoginPage()),
               );
            },
          ),
        ],
      ),
    );
  }

  // Mosque Name Widget
  Widget _buildMosqueHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.mosque, color: kPrimaryGreen, size: 40),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              _mosqueName.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kAccentGold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: kAccentGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Timer Widget
  Widget _buildTimerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryGreen, const Color.fromARGB(255, 10, 46, 39)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
           BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Adhan Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Next Adhan:", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(_nextPrayerName, style: TextStyle(color: kAccentGold, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(_formatDuration(_timeUntilAdhan), style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          // Middle: Iqamat Info
          Padding(
            padding: const EdgeInsets.only(top: 15.0), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Next Iqamat:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 5),
                Text(_formatDuration(_timeUntilIqamat), style: const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
          // Right: Icon
          Icon(Icons.hourglass_bottom_rounded, color: kAccentGold, size: 50),
        ],
      ),
    );
  }

  // Timetable Widget
  Widget _buildTimetableCard() {
    return Container(
      decoration: BoxDecoration(
        color: kPrimaryGreen,
        gradient: LinearGradient(
          colors: [kPrimaryGreen, const Color.fromARGB(255, 10, 46, 39)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            // 1. Reduced vertical padding here (was 15)
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color.fromARGB(255, 135, 104, 58), kAccentGold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Day", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Timetable", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          // List
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero, // 2. Removes any default top/bottom padding from the list itself
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _prayerTimes.length,
            itemBuilder: (context, index) {
              return Padding(
                // 3. Reduced vertical padding here (was 12) to make list items closer
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6), 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _prayerTimes[index]["name"]!,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      _prayerTimes[index]["time"]!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
          // Footer Info
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white54, size: 14),
                const SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_currentAddress, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    const Text("JAKIM, Malaysia", style: TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // Bottom Navigation Widget
  Widget _buildBottomNavBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: kPrimaryGreen,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 25, spreadRadius: 2, offset: Offset(0, 10))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, "Home", 0),
          _buildNavItem(Icons.volunteer_activism, "Donation", 1),
          _buildNavImageItem("assets/images/tasbih_false.png", "Tasbih", 2),
          _buildNavItem(Icons.calendar_month, "Events", 3),
          _buildNavItem(Icons.info_outline, "Masjid Info", 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? kAccentGold : Colors.white54, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? kAccentGold : Colors.white54,
                fontSize: 10,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNavImageItem(String assetPath, String label, int index) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetPath,
              width: 24,
              height: 24,
              color: isActive ? kAccentGold : kInactiveGrey,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: kInactiveGrey), 
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? kAccentGold : kInactiveGrey,
                fontSize: 10,
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- 5. SIDEBAR MENU CLASS ---
class SidebarMenu extends StatelessWidget {
  final Color kPrimaryGreen = const Color(0xFF0A4D3C);
  final Color kAccentGold = const Color(0xFFC5A059);

  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: kPrimaryGreen, 
      child: Column(
        children: [
          // Menu Header (Profile)
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF083E30)), 
            accountName: Text(
              "Masjid Member",
              style: TextStyle(color: kAccentGold, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text(
              "View Profile",
              style: TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: GestureDetector(
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: CircleAvatar(
                backgroundColor: kAccentGold,
                child: Icon(Icons.person, color: kPrimaryGreen, size: 40),
              ),
            ),
          ),

          // Menu Items List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(Icons.person_outline, "Profile", () {
                    Navigator.pop(context); // Close Drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                }),
                _buildMenuItem(Icons.home_outlined, "Home", () { Navigator.pop(context); }),
                _buildMenuItem(Icons.volunteer_activism_outlined, "Donation", () {}),
                _buildMenuItem(Icons.fingerprint, "Tasbih", () {}),
                _buildMenuItem(Icons.calendar_month_outlined, "Events", () {}),
                _buildMenuItem(Icons.info_outline, "Masjid Info", () {}),
              ],
            ),
          ),

          // Settings at Bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 30, top: 10),
            child: Column(
              children: [
                const Divider(color: Colors.white24),
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
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}
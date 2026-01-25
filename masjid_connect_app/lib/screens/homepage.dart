import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart'; // Import for Feature 1
import '../services/google_location.dart';
import '../services/prayer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- VARIABLES ---
  final Color kPrimaryGreen = const Color(0xFF0A4D3C);
  final Color kAccentGold = const Color(0xFFC5A059);

  // Services
  final GoogleLocationService _locationService = GoogleLocationService();
  final PrayerService _prayerService = PrayerService();

  // State Variables
  String _currentAddress = "Locating...";
  String _mosqueName = "Finding nearest mosque...";
  String _hijriDate = ""; // Feature 1 Variable
  List<Map<String, String>> _prayerTimes = []; 
  String _nextPrayerName = "Fajr"; 
  
  // Timer Variables
  Timer? _timer;
  DateTime? _targetAdhanTime; 
  DateTime? _targetIqamatTime;
  Duration _timeUntilAdhan = Duration.zero;
  Duration _timeUntilIqamat = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initHijriDate(); // Feature 1 Init
    _startTimer();
    _loadData();
  }

  // HIJRI DATE LOGIC 
  void _initHijriDate() {
    HijriCalendar.setLocal('en'); 
    final _today = HijriCalendar.now();
    setState(() {
      _hijriDate = "${_today.hDay} ${_today.longMonthName} ${_today.hYear}H";
    });
  }

  Future<void> _loadData() async {
    try {
      // 1. Location & Mosque
      final locationData = await _locationService.getCurrentLocation();
      String city = locationData['city']!;
      String detectedMosque = locationData['mosqueName'] ?? "Nearby Mosque";

      if (mounted) {
        setState(() {
          _currentAddress = locationData['address']!;
          _mosqueName = detectedMosque;
        });
      }

      // 2. Prayer Times
      final times = await _prayerService.getPrayerTimes(city);

      if (mounted) {
        setState(() {
          _prayerTimes = times;
          _calculateNextPrayer();
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = "Location Error";
          _mosqueName = "Check Internet/GPS";
        });
      }
      print("Error loading data: $e");
    }
  }

  // --- TIMER LOGIC ---
  void _calculateNextPrayer() {
    if (_prayerTimes.isEmpty) return;
    final now = DateTime.now();
    DateTime? upcomingPrayerTime;
    String upcomingName = "Fajr";

    for (var i = 0; i < _prayerTimes.length; i++) {
      final pName = _prayerTimes[i]["name"]!;
      final pTime = _prayerTimes[i]["time"]!;
      if (pName == "Syuruk") continue; 

      final parts = pTime.split(':');
      final candidateTime = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));

      if (candidateTime.isAfter(now)) {
        upcomingPrayerTime = candidateTime;
        upcomingName = pName;
        break; 
      }
    }

    if (upcomingPrayerTime == null) {
      final fajrTime = _prayerTimes[0]["time"]!;
      final parts = fajrTime.split(':');
      final tomorrow = now.add(const Duration(days: 1));
      upcomingPrayerTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, int.parse(parts[0]), int.parse(parts[1]));
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
          if (_timeUntilAdhan.isNegative) _calculateNextPrayer();
        });
      }
    });
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return "00h 00m 00s";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${d.inHours}h ${twoDigits(d.inMinutes.remainder(60))}m ${twoDigits(d.inSeconds.remainder(60))}s";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFD3E2DF), Color(0xFFF6F1E9), Color(0xFFF6F1E9)],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
        ),
        // Content
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30), // Adjusted padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMosqueHeader(), // Contains Feature 1
              const SizedBox(height: 15),
              _buildTimerCard(),
              const SizedBox(height: 15),
              _buildTimetableCard(),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMosqueHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column( // Changed Row to Column to stack Hijri date
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 4),
          // Feature 1: Hijri Date Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: kPrimaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _hijriDate,
              style: TextStyle(
                color: kPrimaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          )
        ],
      ),
    );
  }

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
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Next Adhan:", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(_nextPrayerName, style: TextStyle(color: kAccentGold, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(_formatDuration(_timeUntilAdhan), style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
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
          Icon(Icons.hourglass_bottom_rounded, color: kAccentGold, size: 50),
        ],
      ),
    );
  }

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
          Container(
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
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero, 
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _prayerTimes.length,
            itemBuilder: (context, index) {
              return Padding(
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
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white54, size: 14),
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentAddress,
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text("JAKIM, Malaysia", style: TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  int _counter = 0;
  String _selectedDhikr = "لَا إِلٰهَ إِلَّا اللهُ";
  String _transliteration = "lā ilāha-illāllāh";

  final Color kPrimaryGreen = const Color(0xFF0A4D3C);
  final Color kAccentGold = const Color(0xFFC5A059);

  final List<Map<String, String>> _dhikrOptions = [
    {"arabic": "لَا إِلٰهَ إِلَّا اللهُ", "trans": "lā ilāha-illāllāh"},
    {"arabic": "سُبْحَانَ اللهِ", "trans": "SubhanAllah"},
    {"arabic": "الْحَمْدُ لِلَّهِ", "trans": "Alhamdulillah"},
    {"arabic": "اللهُ أَكْبَرُ", "trans": "Allahu Akbar"},
  ];

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF6F1E9),
        title: Text("Choose Dhikr", style: TextStyle(color: kPrimaryGreen)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _dhikrOptions.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(_dhikrOptions[index]["arabic"]!, textAlign: TextAlign.right),
              subtitle: Text(_dhikrOptions[index]["trans"]!),
              onTap: () {
                setState(() {
                  _selectedDhikr = _dhikrOptions[index]["arabic"]!;
                  _transliteration = _dhikrOptions[index]["trans"]!;
                  _counter = 0;
                });
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Edit Section
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.edit, color: kAccentGold, size: 35),
                onPressed: _showEditDialog,
              ),
            ),
          ),
          Text(_selectedDhikr, style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold)),
          Text(_transliteration, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
          const SizedBox(height: 30),
          
          // 2. Counter Section with STACK for the Background Image
          Stack(
            alignment: Alignment.center,
            children: [
              // Bottom Layer: The Bead Circle
              Image.asset(
                'assets/images/beadstasbih.png', 
                width: 300,
                height: 300,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.blur_circular, 
                  size: 300, 
                  color: kAccentGold.withOpacity(0.2)
                ),
              ),
              // Top Layer: The Counter Number
              Text(
                "$_counter", 
                style: const TextStyle(fontSize: 90, fontWeight: FontWeight.w400)
              ),
            ],
          ),
          
          const SizedBox(height: 30),

          // 3. Plus Button
          GestureDetector(
            onTap: () => setState(() => _counter++),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 50),
            ),
          ),

          const SizedBox(height: 20),

          // 4. Reset Button
          TextButton.icon(
            onPressed: () {
              setState(() {
                _counter = 0; // Resets the count to zero
              });
            },
            icon: const Icon(Icons.refresh, color: Colors.grey),
            label: const Text(
              "RESET COUNTER",
              style: TextStyle(
                color: Colors.grey, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 1.2
              ),
            ),
          ),
        ],
      ),
    );
  }
}
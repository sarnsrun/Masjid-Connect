import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // To get API Key
import 'package:url_launcher/url_launcher.dart'; // To open external map
import '../models/event.dart';

// Your App Theme Colors
final Color kPrimaryGreen = const Color(0xFF0A4D3C);
final Color kAccentGold = const Color(0xFFC5A059);
final Color kBackgroundCream = const Color(0xFFF6F1E9);

class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  bool isDetailsSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundCream,
      appBar: AppBar(
        title: Text("Event Details", style: TextStyle(color: kAccentGold, fontWeight: FontWeight.bold)),
        backgroundColor: kPrimaryGreen,
        iconTheme: IconThemeData(color: kAccentGold),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Event Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.event.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title & Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kPrimaryGreen),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: kAccentGold),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          widget.event.location,
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text("By ${widget.event.organizer}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Toggle Buttons
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300)
              ),
              child: Row(
                children: [
                  _buildToggleButton("Details", isDetailsSelected),
                  _buildToggleButton("Location", !isDetailsSelected),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Content Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: isDetailsSelected ? _buildDetailsContent() : _buildLocationContent(),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildToggleButton(String text, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isDetailsSelected = (text == "Details")),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? kPrimaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? kAccentGold : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.event.description, style: TextStyle(color: Colors.grey[800], height: 1.5)),
        const SizedBox(height: 20),
        Text("Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryGreen)),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.access_time, size: 20, color: kAccentGold),
            const SizedBox(width: 10),
            Text(widget.event.time),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationContent() {
    // 1. Construct the Static Map URL
    // Format: staticmap?center=Lat,Lng&zoom=15&size=600x300&markers=color:red|Lat,Lng&key=API_KEY
    final String apiKey = dotenv.env['GOOGLE_API_KEY'] ?? "";
    final String staticMapUrl = "https://maps.googleapis.com/maps/api/staticmap?center=${widget.event.latitude},${widget.event.longitude}&zoom=15&size=600x300&markers=color:red%7C${widget.event.latitude},${widget.event.longitude}&key=$apiKey";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Venue Location:", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        // 2. Static Image wrapped in GestureDetector
        GestureDetector(
          onTap: () => _showOpenMapDialog(widget.event.latitude, widget.event.longitude),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200], // Placeholder color
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: kPrimaryGreen.withOpacity(0.3)),
              image: apiKey.isNotEmpty 
                ? DecorationImage(
                    image: NetworkImage(staticMapUrl),
                    fit: BoxFit.cover,
                  )
                : null, // Fallback if no API key
            ),
            child: Stack(
              children: [
                // If API Key is missing, show a broken icon
                if (apiKey.isEmpty)
                   const Center(child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.map_outlined, size: 40, color: Colors.grey),
                       Text("Map Unavailable", style: TextStyle(color: Colors.grey))
                     ],
                   )),
                
                // "Tap to Open" overlay label
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.open_in_new, size: 14, color: kPrimaryGreen),
                        const SizedBox(width: 4),
                        Text("Open in Maps", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kPrimaryGreen)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        
        // Location Text
        Row(
          children: [
            Icon(Icons.location_on, color: kPrimaryGreen),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                widget.event.location,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryGreen),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 3. Logic to launch External App
  Future<void> _showOpenMapDialog(double lat, double lng) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Open Google Maps?"),
        content: const Text("Do you want to leave the app and view this location in Google Maps?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              // Construct Google Maps URL
              final Uri googleUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

              if (await canLaunchUrl(googleUrl)) {
                await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Could not open maps.")),
                );
              }
            },
            child: const Text("Open", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
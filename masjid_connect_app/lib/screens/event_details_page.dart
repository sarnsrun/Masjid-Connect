import 'package:flutter/material.dart';
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
      backgroundColor: kBackgroundCream, // Consistent background
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
            // Main Image
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
            SizedBox(height: 20),
            
            // Title & Organizer Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kPrimaryGreen),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: kAccentGold),
                      SizedBox(width: 5),
                      Text(widget.event.location, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text("By ${widget.event.organizer}", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Toggle Buttons
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(4),
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
            SizedBox(height: 20),

            // Conditional Rendering
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: isDetailsSelected ? _buildDetailsContent() : _buildLocationContent(),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isDetailsSelected = (text == "Details");
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            // Use your app's Primary Green for the active state
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
        Text(
          widget.event.description,
          style: TextStyle(color: Colors.grey[800], height: 1.5),
        ),
        SizedBox(height: 20),
        Text("Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryGreen)),
        SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.access_time, size: 20, color: kAccentGold),
            SizedBox(width: 10),
            Text(widget.event.time),
          ],
        ),
      ],
    );
  }

 Widget _buildLocationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Venue Location:", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: kPrimaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: kPrimaryGreen.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 40, color: kPrimaryGreen),
              const SizedBox(height: 10),
              // HERE IS THE CHANGE: It uses the actual event location text
              Text(
                widget.event.location, 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryGreen),
              ),
              const SizedBox(height: 5),
              const Text("(Open Google Maps manually for directions)", style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}
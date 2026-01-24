import 'package:flutter/material.dart';
import 'package:masjid_connect_app/models/event.dart';
import 'package:masjid_connect_app/screens/event_details_page.dart';

// Your App Theme Colors
final Color kPrimaryGreen = const Color(0xFF0A4D3C);
final Color kAccentGold = const Color(0xFFC5A059);
final Color kBackgroundCream = const Color(0xFFF6F1E9);

class EventsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      backgroundColor: kBackgroundCream, // Match the app background
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: mockEvents.length,
        itemBuilder: (context, index) {
          final event = mockEvents[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailsPage(event: event),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryGreen.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Image
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.network(
                      event.imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      // Add error builder in case image fails
                      errorBuilder: (ctx, err, stack) => 
                        Container(height: 150, color: Colors.grey[300], child: Icon(Icons.image_not_supported)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              event.title,
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold,
                                color: kPrimaryGreen // Using your theme color
                              ),
                            ),
                            Row(
                              children: [
                                Text(event.distance, style: TextStyle(color: Colors.grey)),
                                SizedBox(width: 4),
                                Icon(Icons.location_on, size: 16, color: kAccentGold),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(event.location, style: TextStyle(color: Colors.grey)),
                            Row(
                              children: [
                                Text(event.date, style: TextStyle(color: Colors.grey)),
                                SizedBox(width: 4),
                                Icon(Icons.calendar_today, size: 16, color: kPrimaryGreen),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
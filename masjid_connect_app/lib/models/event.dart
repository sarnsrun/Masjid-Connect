import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String location;
  final double latitude;  // Add this
  final double longitude; // Add this
  final String date; 
  final String time; 
  final String description;
  final String organizer;
  final String imageUrl;

  Event({
    required this.id,
    required this.title,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.time,
    required this.description,
    required this.organizer,
    required this.imageUrl,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? 'Untitled Event',
      location: data['location'] ?? 'Unknown Location',
      latitude: (data['latitude'] ?? 3.1390).toDouble(),   // Default to KL if null
      longitude: (data['longitude'] ?? 101.6869).toDouble(),
      date: data['date'] ?? 'No Date',
      time: data['time'] ?? 'No Time',
      description: data['description'] ?? 'No Description',
      organizer: data['organizer'] ?? 'Masjid Admin',
      imageUrl: data['imageUrl'] ?? 'https://placehold.co/600x400/png?text=Event',
    );
  }
}
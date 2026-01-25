import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id; // We need ID to handle clicks or edits
  final String title;
  final String location;
  final String date; 
  final String time; 
  final String description;
  final String organizer;
  final String imageUrl;

  Event({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.description,
    required this.organizer,
    required this.imageUrl,
  });

  // Factory to convert Firebase Data -> Event Object
  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? 'Untitled Event',
      location: data['location'] ?? 'Unknown Location',
      date: data['date'] ?? 'No Date',
      time: data['time'] ?? 'No Time',
      description: data['description'] ?? 'No Description',
      organizer: data['organizer'] ?? 'Masjid Admin',
      imageUrl: data['imageUrl'] ?? 'https://placehold.co/600x400/png?text=Event',
    );
  }
}
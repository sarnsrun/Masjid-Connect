import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import 'event_details_page.dart';
import 'admin_add_event.dart';

// Theme Colors
final Color kPrimaryGreen = const Color(0xFF0A4D3C);
final Color kAccentGold = const Color(0xFFC5A059);

class EventsListPage extends StatefulWidget {
  final String userRole;
  final String currentMasjidName; 

  const EventsListPage({
    super.key, 
    required this.userRole, 
    required this.currentMasjidName 
  });

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  late Stream<QuerySnapshot> _eventsStream; 

  @override
  void initState() {
    super.initState();
    _eventsStream = FirebaseFirestore.instance
        .collection('events')
        .where('masjidName', isEqualTo: widget.currentMasjidName) 
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      // ADMIN ADD BUTTON
      floatingActionButton: widget.userRole == 'admin'
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton.extended(
                heroTag: "EventBtn",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddEventDialog(
                      masjidName: widget.currentMasjidName 
                    )
                  );
                },
                backgroundColor: kAccentGold,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Add Event", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          : null,

      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFD3E2DF),
                  const Color(0xFFF6F1E9),
                  const Color(0xFFF6F1E9),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          StreamBuilder<QuerySnapshot>(
            stream: _eventsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}')); 
              }              
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              
              var docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 50, color: kPrimaryGreen.withOpacity(0.5)),
                      const SizedBox(height: 10),
                      Text("No events for ${widget.currentMasjidName}", style: TextStyle(color: kPrimaryGreen, fontSize: 16)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 130),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  Event event = Event.fromFirestore(docs[index]);
                  return _buildEventCard(context, event);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event) {
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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: kPrimaryGreen.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                event.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) =>
                    Container(height: 150, color: Colors.grey[300], child: const Icon(Icons.image_not_supported)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryGreen),
                  ),
                  const SizedBox(height: 8),
                  
                  // --- FIX STARTS HERE ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // WRAP THIS ROW IN EXPANDED
                      // This tells the Location Row to take up all "available" space
                      // causing the Expanded inside it to work correctly.
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: kAccentGold),
                            const SizedBox(width: 4),
                            // This Expanded now knows exactly how much space it has
                            Expanded(
                              child: Text(
                                event.location, 
                                style: const TextStyle(color: Colors.grey), 
                                overflow: TextOverflow.ellipsis
                              )
                            ),
                          ],
                        ),
                      ),
                      
                      // Add a small gap between location and date
                      const SizedBox(width: 10),

                      // Date Row (keeps its intrinsic width)
                      Row(
                        children: [
                          Text(event.date, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(width: 4),
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
  }
}
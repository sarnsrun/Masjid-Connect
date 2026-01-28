import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Needed for API Key
import 'package:http/http.dart' as http; // Needed for fetching coords
import '../services/google_location.dart';
import 'login_page.dart'; // Reuse the search dialog from Login

// Theme Colors
final Color kPrimaryGreen = const Color(0xFF0A4D3C);
final Color kAccentGold = const Color(0xFFC5A059);

class AddEventDialog extends StatefulWidget {
  final String masjidName; 

  const AddEventDialog({super.key, required this.masjidName});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _organizerController = TextEditingController();
  final _imageUrlController = TextEditingController();

  final GoogleLocationService _locationService = GoogleLocationService();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _dateText = "Select Date";
  String _timeText = "Select Time";
  
  // New variables to store coordinates
  double? _eventLat;
  double? _eventLng;
  bool _isLoadingCoords = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _organizerController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // 1. Opens the search dialog
  void _showLocationSearch() {
    showDialog(
      context: context,
      builder: (context) => MosqueSearchDialog(
        service: _locationService, 
        onSelected: (name, id) async {
          setState(() {
            _locationController.text = name;
            _isLoadingCoords = true;
          });
          
          // 2. Fetch detailed coordinates using the Place ID
          await _fetchCoordinates(id);
        }
      ),
    );
  }

  // 3. Helper to get Lat/Lng from Google Places Details API
  Future<void> _fetchCoordinates(String placeId) async {
    String apiKey = dotenv.env['GOOGLE_API_KEY'] ?? "";
    if (apiKey.isEmpty) return;

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$apiKey"
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == "OK") {
          final location = data["result"]["geometry"]["location"];
          setState(() {
            _eventLat = location["lat"];
            _eventLng = location["lng"];
            _isLoadingCoords = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching coordinates: $e");
      setState(() => _isLoadingCoords = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Event @ ${widget.masjidName}",
          style: TextStyle(color: kPrimaryGreen, fontSize: 16)), 
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Event Title")),
            const SizedBox(height: 10),
            
            // LOCATION FIELD WITH SPINNER
            GestureDetector(
              onTap: _showLocationSearch,
              child: AbsorbPointer(
                child: TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: "Location",
                    hintText: "Tap to search mosque database",
                    prefixIcon: const Icon(Icons.location_on),
                    suffixIcon: _isLoadingCoords 
                        ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(10.0), child: CircularProgressIndicator(strokeWidth: 2))) 
                        : null,
                  ),
                ),
              ),
            ),

            TextField(controller: _organizerController, decoration: const InputDecoration(labelText: "Organizer")),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(_dateText, style: const TextStyle(fontSize: 12)),
                    onPressed: _pickDate,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text(_timeText, style: const TextStyle(fontSize: 12)),
                    onPressed: _pickTime,
                  ),
                ),
              ],
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: "Image Link (URL)",
                hintText: "Paste a link from Google/Imgur",
                prefixIcon: Icon(Icons.link),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
          onPressed: _saveEvent,
          child: const Text("Post Event", style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateText = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeText = picked.format(context);
      });
    }
  }

  void _saveEvent() {
    if (_titleController.text.isNotEmpty && _selectedDate != null && _selectedTime != null) {
      String finalImage = _imageUrlController.text.isNotEmpty
          ? _imageUrlController.text
          : "https://placehold.co/600x400/png?text=Event";

      // SAVE WITH COORDINATES
      FirebaseFirestore.instance.collection('events').add({
        'title': _titleController.text,
        'location': _locationController.text,
        'latitude': _eventLat ?? 3.1390, // Default fallback if fetch failed
        'longitude': _eventLng ?? 101.6869,
        'organizer': _organizerController.text,
        'description': _descriptionController.text,
        'date': _dateText,
        'time': _timeText,
        'imageUrl': finalImage,
        'createdAt': DateTime.now(),
        'masjidName': widget.masjidName, 
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event Posted!")));
    }
  }
}
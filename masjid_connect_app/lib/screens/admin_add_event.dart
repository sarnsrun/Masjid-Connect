import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _dateText = "Select Date";
  String _timeText = "Select Time";

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _organizerController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Event @ ${widget.masjidName}",
          style: TextStyle(color: kPrimaryGreen, fontSize: 16)), 
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Event Title")),
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: "Location")),
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

      FirebaseFirestore.instance.collection('events').add({
        'title': _titleController.text,
        'location': _locationController.text,
        'organizer': _organizerController.text,
        'description': _descriptionController.text,
        'date': _dateText,
        'time': _timeText,
        'imageUrl': finalImage,
        'createdAt': DateTime.now(),
        'masjidName': widget.masjidName, // <--- NEW: Save the specific Mosque Name
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event Posted!")));
    }
  }
}
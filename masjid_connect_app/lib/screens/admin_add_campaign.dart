import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Constants
final Color kPrimaryGreen = const Color(0xFF0A4D3C);
final Color kAccentGold = const Color(0xFFC5A059);

class AddCampaignDialog extends StatefulWidget {
  final String currentMasjidName;

  const AddCampaignDialog({super.key, required this.currentMasjidName});

  @override
  State<AddCampaignDialog> createState() => _AddCampaignDialogState();
}

class _AddCampaignDialogState extends State<AddCampaignDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  
  // Category Selection
  String _selectedCategory = 'Construction';
  final List<String> _categories = ['Construction', 'Food Bank', 'Education', 'Maintenance', 'Emergency'];
  
  bool _isUploading = false;
  String? _previewUrl; // Stores the URL to show the preview

  @override
  void initState() {
    super.initState();
    // Listener: Updates the preview box immediately when user pastes a link
    _imageUrlController.addListener(() {
      setState(() {
        _previewUrl = _imageUrlController.text;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _goalController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _postCampaign() async {
    if (_titleController.text.isEmpty || _goalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in Title and Goal")));
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. Get the Image URL (or use a placeholder if empty)
      String finalImage = _imageUrlController.text.isNotEmpty 
          ? _imageUrlController.text 
          : "https://placehold.co/600x400/png?text=Donation";

      // 2. Save to Firestore
      await FirebaseFirestore.instance.collection('campaigns').add({
        'title': _titleController.text,
        'location': _locationController.text,
        'goalAmount': double.tryParse(_goalController.text) ?? 1000,
        'currentAmount': 0,
        'imageUrl': finalImage, // Saves the link you pasted
        'createdAt': DateTime.now(),
        'masjidName': widget.currentMasjidName,
        'category': _selectedCategory,
        'status': 'active',
      });

      if (mounted) {
        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Campaign Posted Successfully!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("New Campaign", style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGE PREVIEW AREA ---
            Text("Campaign Image", style: TextStyle(color: kAccentGold, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              // If we have a URL, try to show the image. Otherwise show an icon.
              child: _previewUrl != null && _previewUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _previewUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.broken_image, color: Colors.grey),
                            const SizedBox(height: 5),
                            Text("Invalid Link", style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 40, color: Colors.grey[400]),
                        const SizedBox(height: 5),
                        Text("Preview will appear here", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
            ),
            const SizedBox(height: 15),
            // --------------------------

            // Image URL Input
            TextField(
              controller: _imageUrlController, 
              decoration: const InputDecoration(
                labelText: "Paste Image Link",
                hintText: "https://example.com/image.jpg",
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)
              )
            ),
            
            const SizedBox(height: 15),
            
            // Title Input
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Campaign Title", prefixIcon: Icon(Icons.title))),
            
            const SizedBox(height: 10),
            
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: "Category", prefixIcon: Icon(Icons.category)),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),

            const SizedBox(height: 10),
            
            // Location Input
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: "Location", prefixIcon: Icon(Icons.location_on))),
            
            const SizedBox(height: 10),
            
            // Goal Input
            TextField(controller: _goalController, decoration: const InputDecoration(labelText: "Goal (RM)", prefixIcon: Icon(Icons.monetization_on)), keyboardType: TextInputType.number),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
          onPressed: _isUploading ? null : _postCampaign,
          child: _isUploading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Post Campaign", style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }
}
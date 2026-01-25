import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- COLOR PALETTE ---
final Color kPrimaryGreen = const Color(0xFF0A4D3C);
final Color kAccentGold = const Color(0xFFC5A059);
final Color kBackgroundCream = const Color(0xFFF6F1E9);

// --- 1. MAIN DONATION SCREEN (With Admin Features) ---
class DonationPage extends StatefulWidget {
  final String userRole; // Needed to check if Admin
  final String currentMasjidName; // <--- NEW: Required to filter data

  const DonationPage({
    super.key, 
    required this.userRole, 
    required this.currentMasjidName // <--- Add this
  });

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  late Stream<QuerySnapshot> _campaignStream; // Changed to late

  @override
  void initState() {
    super.initState();
    // FIX: Filter campaigns so we only see ones for the detected mosque
    _campaignStream = FirebaseFirestore.instance
        .collection('campaigns')
        .where('masjidName', isEqualTo: widget.currentMasjidName) // <--- The Logic Fix
        .snapshots();
  }

  // Function to Add New Campaign (Admin Only)
  void _showAddCampaignDialog() {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final goalController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Campaign @ ${widget.currentMasjidName}", // Show mosque name
            style: TextStyle(color: kPrimaryGreen, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Campaign Title")),
              TextField(controller: locationController, decoration: const InputDecoration(labelText: "Location")),
              TextField(controller: goalController, decoration: const InputDecoration(labelText: "Goal Amount (RM)"), keyboardType: TextInputType.number),
              TextField(controller: imageController, decoration: const InputDecoration(labelText: "Image URL (Optional)")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
            onPressed: () {
              if (titleController.text.isNotEmpty && goalController.text.isNotEmpty) {
                // FIX: Save the 'masjidName' so it appears for the right users
                FirebaseFirestore.instance.collection('campaigns').add({
                  'title': titleController.text,
                  'location': locationController.text,
                  'goalAmount': double.tryParse(goalController.text) ?? 1000,
                  'currentAmount': 0, 
                  'imageUrl': imageController.text.isNotEmpty 
                      ? imageController.text 
                      : "https://placehold.co/600x400/png?text=Donation",
                  'createdAt': DateTime.now(),
                  'masjidName': widget.currentMasjidName, // <--- SAVED HERE
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Post", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      
      // ADMIN BUTTON
      floatingActionButton: widget.userRole == 'admin' 
        ? Padding(
            padding: const EdgeInsets.only(bottom: 80), 
            child: FloatingActionButton.extended(
              onPressed: _showAddCampaignDialog,
              backgroundColor: kAccentGold,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Add Campaign", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            stream: _campaignStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text('Something went wrong'));
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

              var docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                 return Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.volunteer_activism, size: 50, color: Colors.grey[400]),
                       const SizedBox(height: 10),
                       Text("No campaigns for ${widget.currentMasjidName}", style: TextStyle(color: kPrimaryGreen)),
                     ],
                   ),
                 );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 130),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> data = docs[index].data()! as Map<String, dynamic>;
                  String docId = docs[index].id;
                  return _buildCampaignCard(context, data, docId);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, Map<String, dynamic> data, String docId) {
    String title = data['title'] ?? "Untitled";
    String location = data['location'] ?? "Unknown";
    String imageUrl = data['imageUrl'] ?? "https://placehold.co/600x400";
    double current = (data['currentAmount'] ?? 0).toDouble();
    double goal = (data['goalAmount'] ?? 100).toDouble();
    double percent = (current / goal).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonationDetailScreen(data: data, campaignId: docId),
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
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(height: 150, color: Colors.grey[300], child: const Icon(Icons.image_not_supported)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: kPrimaryGreen, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(children: [const Icon(Icons.location_on, size: 16, color: Colors.grey), const SizedBox(width: 4), Text(location, style: const TextStyle(color: Colors.grey))]),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: percent,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(kAccentGold),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("RM ${current.toStringAsFixed(0)}", style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.bold)),
                      Text("${(percent * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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

// --- 2. DETAIL SCREEN (Unchanged Logic, just ensuring consistent imports) ---
class DonationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String campaignId;

  const DonationDetailScreen({super.key, required this.data, required this.campaignId});

  @override
  State<DonationDetailScreen> createState() => _DonationDetailScreenState();
}

class _DonationDetailScreenState extends State<DonationDetailScreen> {
  int selectedAmountIndex = 1;
  final List<int> donationAmounts = [10, 50, 100, 500];
  final TextEditingController _customAmountController = TextEditingController();
  bool _isLoading = false;

  Future<void> _processPayment() async {
    double amount = 0;
    if (selectedAmountIndex != -1) {
      amount = donationAmounts[selectedAmountIndex].toDouble();
    } else {
      amount = double.tryParse(_customAmountController.text) ?? 0;
    }

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid amount")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      String userId = user?.uid ?? "anonymous";
      String userName = user?.email ?? "Anonymous Donor";

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference campaignRef = FirebaseFirestore.instance.collection('campaigns').doc(widget.campaignId);
        DocumentSnapshot snapshot = await transaction.get(campaignRef);

        if (!snapshot.exists) throw Exception("Campaign does not exist!");

        double newCurrent = (snapshot.get('currentAmount') ?? 0) + amount;

        transaction.update(campaignRef, {'currentAmount': newCurrent});

        DocumentReference donationRef = FirebaseFirestore.instance.collection('donations').doc();
        transaction.set(donationRef, {
          'campaignId': widget.campaignId,
          'campaignTitle': widget.data['title'],
          'userId': userId,
          'userName': userName,
          'amount': amount,
          'timestamp': DateTime.now(),
        });
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Payment Successful"),
            content: Text("Thank you for donating RM ${amount.toStringAsFixed(2)}!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); 
                  Navigator.pop(context); 
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.data['imageUrl'] ?? "https://placehold.co/600x400";
    String title = widget.data['title'] ?? "Donation";
    String location = widget.data['location'] ?? "Malaysia";

    return Scaffold(
      backgroundColor: kBackgroundCream,
      appBar: AppBar(
        backgroundColor: kPrimaryGreen,
        leading: const BackButton(color: Colors.white),
        title: Text("Make a Donation", style: TextStyle(color: kAccentGold, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0,2))]),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(width: 80, height: 80, color: Colors.grey)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Donating to:", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        Text(title, style: TextStyle(color: kPrimaryGreen, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(location, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: kPrimaryGreen, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: kPrimaryGreen.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 10))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Select Amount", style: TextStyle(color: kAccentGold, fontSize: 16, fontWeight: FontWeight.bold)), const Icon(Icons.volunteer_activism, color: Colors.white54)]),
                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 12, runSpacing: 12,
                    children: List.generate(donationAmounts.length, (index) {
                      final isSelected = selectedAmountIndex == index;
                      return InkWell(
                        onTap: () => setState(() { selectedAmountIndex = index; _customAmountController.clear(); }),
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 92) / 2,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(color: isSelected ? kAccentGold : Colors.transparent, border: Border.all(color: kAccentGold.withOpacity(0.5), width: 1.5), borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: Text("RM ${donationAmounts[index]}", style: TextStyle(color: isSelected ? Colors.white : Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: _customAmountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(filled: true, fillColor: Colors.black.withOpacity(0.2), hintText: "Enter custom amount", hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)), prefixIcon: const Icon(Icons.edit, color: Colors.white70, size: 20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
                    onChanged: (val) { if (val.isNotEmpty) setState(() => selectedAmountIndex = -1); },
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _processPayment,
                      style: ElevatedButton.styleFrom(backgroundColor: kAccentGold, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Proceed to Pay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
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
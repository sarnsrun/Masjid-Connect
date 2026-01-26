import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Constants
final Color kPrimaryGreen = const Color(0xFF0A4D3C);
final Color kAccentGold = const Color(0xFFC5A059);
final Color kBackgroundCream = const Color(0xFFF6F1E9);

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
  final TextEditingController _niatController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _customAmountController.dispose();
    _niatController.dispose();
    super.dispose();
  }

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
      
      // --- 1. FINAL NAME FETCHING LOGIC ---
      String fullName = "Anonymous Donor"; 
      
      if (user != null) {
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
          
          if (userDoc.exists && userDoc.data() != null) {
            Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            // Priority: 'name' -> 'fullName' -> 'username'
            if (userData.containsKey('name')) {
              fullName = userData['name'];
            } else if (userData.containsKey('fullName')) {
              fullName = userData['fullName'];
            } else if (userData.containsKey('username')) {
              fullName = userData['username'];
            }
          }
        } catch (e) {
          // Silent catch
        }

        if (fullName == "Anonymous Donor" && user.displayName != null && user.displayName!.isNotEmpty) {
          fullName = user.displayName!;
        }
      }

      String niatText = _niatController.text.trim();

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference campaignRef = FirebaseFirestore.instance.collection('campaigns').doc(widget.campaignId);
        DocumentSnapshot snapshot = await transaction.get(campaignRef);

        if (!snapshot.exists) throw Exception("Campaign does not exist!");

        double current = (snapshot.get('currentAmount') ?? 0).toDouble();
        double goal = (snapshot.get('goalAmount') ?? 1000).toDouble();
        
        double newCurrent = current + amount;

        if (newCurrent >= goal) {
          transaction.update(campaignRef, {
            'currentAmount': newCurrent,
            'status': 'completed',
          });
        } else {
          transaction.update(campaignRef, {
            'currentAmount': newCurrent,
            'status': 'active', 
          });
        }

        DocumentReference donationRef = FirebaseFirestore.instance.collection('donations').doc();
        transaction.set(donationRef, {
          'campaignId': widget.campaignId,
          'campaignTitle': widget.data['title'],
          'userId': userId,
          'userName': fullName, 
          'amount': amount,
          'niat': niatText.isNotEmpty ? niatText : "General Donation",
          'timestamp': DateTime.now(),
        });
      });

      if (mounted) {
        _niatController.clear();
        bool isFinished = (widget.data['currentAmount'] ?? 0) + amount >= (widget.data['goalAmount'] ?? 1000);
        
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Payment Successful"),
            content: Text(
              isFinished 
              ? "Alhamdulillah! Your donation completed this campaign!"
              : "Thank you for donating RM ${amount.toStringAsFixed(2)}!",
            ),
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
            // Info Card
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

            // Payment Section
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
                  
                  const SizedBox(height: 20),
                  Text("Dedication (Niat)", style: TextStyle(color: kAccentGold, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _niatController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true, 
                      fillColor: Colors.black.withOpacity(0.2), 
                      hintText: "E.g. On behalf of Arwah Haji Ahmad", 
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)), 
                      prefixIcon: const Icon(Icons.favorite, color: Colors.white70, size: 20), 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), 
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
                    ),
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
            
            // 3. List of Supporters
            const SizedBox(height: 30),
            Row(
              children: [
                Icon(Icons.handshake, color: kPrimaryGreen),
                const SizedBox(width: 10),
                Text("Recent Dedications", style: TextStyle(color: kPrimaryGreen, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 15),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('donations')
                  .where('campaignId', isEqualTo: widget.campaignId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                var allDocs = snapshot.data!.docs;

                // FILTER: Only show items with a valid NIAT
                var docs = allDocs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String niat = data['niat'] ?? 'General Donation';
                  return niat != 'General Donation' && niat.isNotEmpty;
                }).toList();
                
                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text("No public dedications yet.", style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic)),
                    ),
                  );
                }

                // SORT: Newest First
                docs.sort((a, b) {
                  Timestamp t1 = a['timestamp'];
                  Timestamp t2 = b['timestamp'];
                  return t2.compareTo(t1); 
                });

                return ListView.builder(
                  shrinkWrap: true, 
                  physics: const NeverScrollableScrollPhysics(), 
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    String name = data['userName'] ?? 'Anonymous';
                    String niat = data['niat'] ?? '';
                    double amount = (data['amount'] ?? 0).toDouble();
                    
                    Timestamp t = data['timestamp'] ?? Timestamp.now();
                    String dateString = DateFormat('dd MMM yyyy, h:mm a').format(t.toDate());

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: kPrimaryGreen.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: kPrimaryGreen.withOpacity(0.1),
                            child: Text(name.isNotEmpty ? name[0].toUpperCase() : "?", style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.bold, fontSize: 15)),
                                        Text(dateString, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                                      ],
                                    ),
                                    Text("RM ${amount.toStringAsFixed(0)}", style: TextStyle(color: kAccentGold, fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // Niat Container
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: kBackgroundCream,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.format_quote, size: 16, color: kPrimaryGreen.withOpacity(0.5)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          niat,
                                          style: TextStyle(color: Colors.grey[700], fontSize: 13, fontStyle: FontStyle.italic),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
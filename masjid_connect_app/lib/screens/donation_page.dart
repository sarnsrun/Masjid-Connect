import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_add_campaign.dart';
import 'donation_details.dart';

// --- PALETTE ---
final Color kPrimaryGreen = const Color(0xFF0A4D3C);
final Color kAccentGold = const Color(0xFFC5A059);
final Color kUrgentRed = const Color(0xFFE63946); 

class DonationPage extends StatefulWidget {
  final String userRole;
  final String currentMasjidName;

  const DonationPage({
    super.key,
    required this.userRole,
    required this.currentMasjidName,
  });

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  late Stream<QuerySnapshot> _campaignStream;
  
  final List<String> categories = ['All', 'Construction', 'Food Bank', 'Education', 'Maintenance', 'Emergency'];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _campaignStream = FirebaseFirestore.instance
        .collection('campaigns')
        .where('masjidName', isEqualTo: widget.currentMasjidName)
        .snapshots();
  }

  void _openAddCampaignDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCampaignDialog(currentMasjidName: widget.currentMasjidName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        backgroundColor: Colors.transparent, 
        
        floatingActionButton: widget.userRole == 'admin'
            ? Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: FloatingActionButton.extended(
                  onPressed: _openAddCampaignDialog,
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
                  colors: [const Color(0xFFD3E2DF), const Color(0xFFF6F1E9), const Color(0xFFF6F1E9)],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),

            Column(
              children: [
                const SizedBox(height: 10),
                
                // TAB BAR
                Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: kPrimaryGreen.withOpacity(0.2)),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(color: kPrimaryGreen, borderRadius: BorderRadius.circular(25)),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    tabs: const [Tab(text: "Active Campaigns"), Tab(text: "Success Stories")],
                  ),
                ),

                const SizedBox(height: 15),

                // CATEGORY CHIPS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: categories.map((category) {
                      bool isSelected = selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            if (selected) setState(() => selectedCategory = category);
                          },
                          selectedColor: kAccentGold,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : kPrimaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? Colors.transparent : kPrimaryGreen.withOpacity(0.3),
                            ),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _campaignStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return const Center(child: Text('Something went wrong'));
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                      var allDocs = snapshot.data!.docs;

                      var activeDocs = allDocs.where((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        String status = data['status'] ?? 'active';
                        String category = data['category'] ?? 'General';
                        return status != 'completed' && (selectedCategory == 'All' || category == selectedCategory);
                      }).toList();

                      var completedDocs = allDocs.where((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        String status = data['status'] ?? 'active';
                        String category = data['category'] ?? 'General';
                        return status == 'completed' && (selectedCategory == 'All' || category == selectedCategory);
                      }).toList();

                      return TabBarView(
                        children: [
                          _buildList(activeDocs, isCompletedTab: false),
                          _buildList(completedDocs, isCompletedTab: true),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<QueryDocumentSnapshot> docs, {required bool isCompletedTab}) {
    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isCompletedTab ? Icons.emoji_events : Icons.volunteer_activism, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text(
              isCompletedTab ? "No success stories here." : "No active campaigns here.", 
              style: TextStyle(color: kPrimaryGreen)
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 130),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> data = docs[index].data()! as Map<String, dynamic>;
        String docId = docs[index].id;
        return _buildCampaignCard(context, data, docId, isCompletedTab);
      },
    );
  }

  Widget _buildCampaignCard(BuildContext context, Map<String, dynamic> data, String docId, bool isCompleted) {
    String title = data['title'] ?? "Untitled";
    String location = data['location'] ?? "Unknown";
    String category = data['category'] ?? "General";
    String imageUrl = data['imageUrl'] ?? "https://placehold.co/600x400";
    double current = (data['currentAmount'] ?? 0).toDouble();
    double goal = (data['goalAmount'] ?? 100).toDouble();
    double percent = (current / goal).clamp(0.0, 1.0);

    // URGENCY LOGIC ---
    bool isUrgent = percent >= 0.75 && !isCompleted;
    Color progressBarColor = isCompleted ? kPrimaryGreen : (isUrgent ? kUrgentRed : kAccentGold);

    return GestureDetector(
      onTap: () {
        if (!isCompleted) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => DonationDetailScreen(data: data, campaignId: docId)));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: kPrimaryGreen.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(height: 150, color: Colors.grey[300])),
                ),
                
                // Category Badge (Right Side)
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                    child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),

                // URGENCY BADGE (Left Side)
                if (isUrgent)
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kUrgentRed, // Red Background
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: kUrgentRed.withOpacity(0.4), blurRadius: 6)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text("Almost There!", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                
                // COMPLETED OVERLAY
                if (isCompleted)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: const BorderRadius.vertical(top: Radius.circular(15))),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(border: Border.all(color: kAccentGold, width: 3), borderRadius: BorderRadius.circular(10), color: kPrimaryGreen.withOpacity(0.8)),
                          child: Text("COMPLETED", style: TextStyle(color: kAccentGold, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2)),
                        ),
                      ),
                    ),
                  ),
              ],
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
                  
                  // Progress Bar (Color changes dynamically)
                  LinearProgressIndicator(
                    value: percent,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("RM ${current.toStringAsFixed(0)}", style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.bold)),
                      Text(
                        isCompleted ? "Goal Reached!" : "${(percent * 100).toStringAsFixed(0)}%", 
                        style: TextStyle(
                          color: isUrgent ? kUrgentRed : (isCompleted ? kAccentGold : Colors.grey), 
                          fontWeight: FontWeight.bold
                        )
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
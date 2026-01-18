import 'package:flutter/material.dart';

// --- COLOR PALETTE (Matched to Homepage) ---
final Color kPrimaryGreen = const Color(0xFF0A4D3C);
final Color kAccentGold = const Color(0xFFC5A059);
final Color kBackgroundCream = const Color(0xFFF6F1E9);

// --- 1. DATA MODEL ---
class Campaign {
  final String title;
  final String location;
  final String imageUrl;
  final double currentAmount;
  final double goalAmount;

  Campaign({
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.currentAmount,
    required this.goalAmount,
  });
}

// --- 2. MAIN DONATION LIST SCREEN ---
class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    // Sample Data
    final List<Campaign> campaigns = [
      Campaign(
        title: "Sultan Haji Ahmad Shah Mosque",
        location: "Gombak, Selangor",
        imageUrl: "https://placehold.co/600x400/png?text=Mosque+A",
        currentAmount: 75000,
        goalAmount: 100000,
      ),
      Campaign(
        title: "Masjid Al-Falah Renovation",
        location: "Subang Jaya",
        imageUrl: "https://placehold.co/600x400/png?text=Renovation",
        currentAmount: 12000,
        goalAmount: 50000,
      ),
      Campaign(
        title: "Community Iftar Fund",
        location: "Kuala Lumpur",
        imageUrl: "https://placehold.co/600x400/png?text=Iftar",
        currentAmount: 5000,
        goalAmount: 15000,
      ),
    ];

    // NOTE: We use a Container with a gradient background instead of a Scaffold
    // because the MainLayout already provides the Scaffold.
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD3E2DF), // Light Sage Green
            Color(0xFFF6F1E9), // Cream
          ],
        ),
      ),
      child: Column(
        children: [
          // Custom Header (Similar to Home Page)
          _buildHeader(),
          
          // List Content
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 100), // Bottom padding for nav bar
              itemCount: campaigns.length,
              itemBuilder: (context, index) {
                return _buildCampaignCard(context, campaigns[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: kPrimaryGreen,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
        ]
      ),
      child: Center(
        child: Text(
          "Donation Campaigns",
          style: TextStyle(
            color: kAccentGold,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, Campaign campaign) {
    return GestureDetector(
      onTap: () {
        // Navigate to Detail Page
        // Note: We use Navigator.push here to go to a full screen detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonationDetailScreen(campaign: campaign),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: kPrimaryGreen.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                campaign.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                  Container(height: 150, color: Colors.grey[300], child: const Icon(Icons.image_not_supported)),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.title,
                    style: TextStyle(
                      color: kPrimaryGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        campaign.location,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Progress Bar
                  LinearProgressIndicator(
                    value: campaign.currentAmount / campaign.goalAmount,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(kAccentGold),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 8),
                  
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "RM ${campaign.currentAmount.toStringAsFixed(0)}",
                        style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${((campaign.currentAmount / campaign.goalAmount) * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
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

// --- 3. DONATION DETAIL SCREEN ---
// This screen keeps its Scaffold because it covers the whole screen when clicked.
class DonationDetailScreen extends StatefulWidget {
  final Campaign campaign;

  const DonationDetailScreen({super.key, required this.campaign});

  @override
  State<DonationDetailScreen> createState() => _DonationDetailScreenState();
}

class _DonationDetailScreenState extends State<DonationDetailScreen> {
  int selectedAmountIndex = 1;
  final List<int> donationAmounts = [10, 50, 100, 500];
  final TextEditingController _customAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundCream,
      appBar: AppBar(
        backgroundColor: kPrimaryGreen,
        leading: const BackButton(color: Colors.white),
        title: Text(
          "Make a Donation", 
          style: TextStyle(color: kAccentGold, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campaign Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0,2))
                ]
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.campaign.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(width: 80, height: 80, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Donating to:", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        Text(
                          widget.campaign.title,
                          style: TextStyle(color: kPrimaryGreen, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(widget.campaign.location, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 25),

            // Payment Panel
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kPrimaryGreen,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: kPrimaryGreen.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Amount",
                        style: TextStyle(color: kAccentGold, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.volunteer_activism, color: Colors.white54),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(donationAmounts.length, (index) {
                      final isSelected = selectedAmountIndex == index;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedAmountIndex = index;
                            _customAmountController.clear();
                          });
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 92) / 2,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? kAccentGold : Colors.transparent,
                            border: Border.all(color: kAccentGold.withOpacity(0.5), width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "RM ${donationAmounts[index]}",
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),
                  
                  // Custom Amount Field
                  TextField(
                    controller: _customAmountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.2),
                      hintText: "Enter custom amount",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                      prefixIcon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty) {
                        setState(() => selectedAmountIndex = -1);
                      }
                    },
                  ),

                  const SizedBox(height: 30),

                  // Pay Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement Payment Logic Here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Processing donation for ${widget.campaign.title}"))
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentGold,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Proceed to Pay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
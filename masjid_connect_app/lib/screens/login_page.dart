import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../navigation_layout.dart';
import '../services/google_location.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Color kPrimaryGreen = const Color(0xFF0A4D3C);
  final Color kAccentGold = const Color(0xFFC5A059);

  bool isLogin = true;
  String selectedRole = 'member';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  final _mosqueNameController = TextEditingController();
  String _selectedMasjidId = ""; 

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleLocationService _locationService = GoogleLocationService(); 

  void _showMosqueSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => MosqueSearchDialog(
        service: _locationService, 
        onSelected: (name, id) {
          setState(() {
            _mosqueNameController.text = name;
            _selectedMasjidId = id;
          });
        }
      ),
    );
  }

  Future<void> _handleAuth() async {
    // Check if Admin selected a mosque AND we have the ID
    if (!isLogin && selectedRole == 'admin') {
      if (_mosqueNameController.text.trim().isEmpty || _selectedMasjidId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please search and select your Mosque from the list.")),
        );
        return;
      }
    }

    try {
      UserCredential userCredential;

      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Fetch user data to route correctly
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        String role = userDoc.exists ? userDoc.get('role') : 'member';

        if (mounted) {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainLayout(userRole: role)));
        }

      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        Map<String, dynamic> userData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': selectedRole,
          'createdAt': DateTime.now(),
        };

        if (selectedRole == 'admin') {
          userData['masjidName'] = _mosqueNameController.text.trim(); 
          userData['masjidId'] = _selectedMasjidId; 
          userData['isVerified'] = false; 
        } else {
          userData['masjidName'] = "Not Assigned"; 
          userData['masjidId'] = null;
        }

        await _firestore.collection('users').doc(userCredential.user!.uid).set(userData);

        if (mounted) {
          // If admin, maybe show a "Pending Verification" screen instead? 
          // For now, we send them to Home but limit their actions there.
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainLayout(userRole: selectedRole)));
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Authentication Error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFFD3E2DF), Color(0xFFF6F1E9)],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.mosque, size: 80, color: kPrimaryGreen),
                  const SizedBox(height: 10),
                  Text("Masjid-Connect", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kPrimaryGreen)),
                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))],
                    ),
                    child: Column(
                      children: [
                        _buildToggleSwitch(),
                        const SizedBox(height: 30),

                        if (!isLogin) ...[
                          _buildTextField(Icons.person, "Full Name", _nameController, false),
                          const SizedBox(height: 20),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(color: const Color(0xFFF6F1E9), borderRadius: BorderRadius.circular(15)),
                            child: Row(
                              children: [
                                const SizedBox(width: 10),
                                Text("I am a: ", style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedRole,
                                      dropdownColor: const Color(0xFFF6F1E9),
                                      items: const [
                                        DropdownMenuItem(value: "member", child: Text("Masjid Member")),
                                        DropdownMenuItem(value: "admin", child: Text("Masjid Admin")),
                                      ],
                                      onChanged: (val) => setState(() => selectedRole = val!),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (selectedRole == 'admin') ...[
                            GestureDetector(
                              onTap: _showMosqueSearchDialog, 
                              child: AbsorbPointer( 
                                child: _buildTextField(Icons.search, "Tap to search your Mosque", _mosqueNameController, false),
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text("Select your mosque from Google Maps database", style: TextStyle(color: Colors.grey, fontSize: 10)),
                            const SizedBox(height: 20),
                          ],
                        ],

                        _buildTextField(Icons.email_outlined, "Email Address", _emailController, false),
                        const SizedBox(height: 20),
                        _buildTextField(Icons.lock_outline, "Password", _passwordController, true),
                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity, height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                            onPressed: _handleAuth,
                            child: Text(isLogin ? "LOG IN" : "CREATE ACCOUNT", style: TextStyle(color: kAccentGold, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(isLogin ? "Don't have an account? " : "Already have an account? "),
                      GestureDetector(
                        onTap: () => setState(() => isLogin = !isLogin),
                        child: Text(isLogin ? "Sign Up" : "Log In", style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint, TextEditingController controller, bool isPassword) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF6F1E9), borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: kPrimaryGreen),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      height: 50,
      decoration: BoxDecoration(color: const Color(0xFFF6F1E9), borderRadius: BorderRadius.circular(25)),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(width: MediaQuery.of(context).size.width * 0.35, margin: const EdgeInsets.all(4), decoration: BoxDecoration(color: kPrimaryGreen, borderRadius: BorderRadius.circular(20))),
          ),
          Row(
            children: [
              Expanded(child: GestureDetector(onTap: () => setState(() => isLogin = true), child: Center(child: Text("Log In", style: TextStyle(fontWeight: FontWeight.bold, color: isLogin ? kAccentGold : Colors.grey))))),
              Expanded(child: GestureDetector(onTap: () => setState(() => isLogin = false), child: Center(child: Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold, color: !isLogin ? kAccentGold : Colors.grey))))),
            ],
          ),
        ],
      ),
    );
  }
}

class MosqueSearchDialog extends StatefulWidget {
  final GoogleLocationService service;
  // Callback expects Name AND ID
  final Function(String name, String id) onSelected;

  const MosqueSearchDialog({super.key, required this.service, required this.onSelected});

  @override
  State<MosqueSearchDialog> createState() => _MosqueSearchDialogState();
}

class _MosqueSearchDialogState extends State<MosqueSearchDialog> {
  // Results are now Maps: {name, id, address}
  List<Map<String, String>> _results = []; 
  bool _isLoading = false;
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length < 3) return;
      setState(() => _isLoading = true);
      
      final results = await widget.service.searchMosques(query);
      
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Search Your Mosque"),
      content: SizedBox(
        width: double.maxFinite,
        // Wrapped in ScrollView to fix keyboard overflow
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Type name (e.g. Al-Falah)",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 10),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      height: 200, 
                      child: _results.isEmpty
                          ? const Center(child: Text("No results found"))
                          : ListView.separated(
                              itemCount: _results.length,
                              padding: EdgeInsets.zero, 
                              separatorBuilder: (c, i) => const Divider(),
                              itemBuilder: (context, index) {
                                final mosque = _results[index];
                                return ListTile(
                                  title: Text(mosque['name'] ?? "Unknown"),
                                  // Show Address so Admin can distinguish duplicates
                                  subtitle: Text(
                                    mosque['address'] ?? "", 
                                    maxLines: 1, 
                                    overflow: TextOverflow.ellipsis
                                  ),
                                  onTap: () {
                                    widget.onSelected(
                                      mosque['name']!, 
                                      mosque['id']!
                                    );
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel")),
      ],
    );
  }
}
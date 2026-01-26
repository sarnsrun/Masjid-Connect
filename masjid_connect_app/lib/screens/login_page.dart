import 'package:flutter/material.dart';
import 'homepage.dart'; 
import '../services/google_location.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Theme Colors
  final Color kPrimaryGreen = const Color(0xFF0A4D3C);
  final Color kAccentGold = const Color(0xFFC5A059);

  // Toggle State (true = Login, false = SignUp)
  bool isLogin = true;

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND GRADIENT (No Pattern)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFD3E2DF), Color(0xFFF6F1E9)],
              ),
            ),
          ),
          
          // 2. MAIN CONTENT
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mosque, size: 80, color: kPrimaryGreen),
                  const SizedBox(height: 10),
                  Text(
                    "Masjid-Connect",
                    style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold, color: kPrimaryGreen, fontFamily: 'Roboto', 
                    ),
                  ),
                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 20, offset: const Offset(0, 10))
                      ],
                    ),
                    child: Column(
                      children: [
                        // TOGGLE SWITCH
                        _buildToggleSwitch(),
                        const SizedBox(height: 30),

                        // FORM FIELDS
                        if (!isLogin) ...[
                          _buildTextField(Icons.person, "Full Name", _nameController, false),
                          const SizedBox(height: 20),
                        ],
                        _buildTextField(Icons.email_outlined, "Email Address", _emailController, false),
                        const SizedBox(height: 20),
                        _buildTextField(Icons.lock_outline, "Password", _passwordController, true),
                        const SizedBox(height: 10),

                        if (isLogin)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),

                        // ACTION BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 5,
                            ),
                            onPressed: () {
                              // Navigate to Home
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const HomePage()),
                              );
                            },
                            child: Text(
                              isLogin ? "LOG IN" : "CREATE ACCOUNT",
                              style: TextStyle(color: kAccentGold, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // BOTTOM TOGGLE TEXT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(isLogin ? "Don't have an account? " : "Already have an account? "),
                      GestureDetector(
                        onTap: () => setState(() => isLogin = !isLogin),
                        child: Text(
                          isLogin ? "Sign Up" : "Log In",
                          style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.bold),
                        ),
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
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1E9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: kPrimaryGreen),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1E9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.35,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: kPrimaryGreen,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isLogin = true),
                  child: Center(
                    child: Text(
                      "Log In",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isLogin ? kAccentGold : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isLogin = false),
                  child: Center(
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: !isLogin ? kAccentGold : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
}


class MosqueSearchDialog extends StatefulWidget {
  final GoogleLocationService service;
  final Function(String name, String id) onSelected;

  const MosqueSearchDialog({super.key, required this.service, required this.onSelected});

  @override
  State<MosqueSearchDialog> createState() => _MosqueSearchDialogState();
}

class _MosqueSearchDialogState extends State<MosqueSearchDialog> {
  final _searchController = TextEditingController();
  List<Map<String, String>> _results = [];
  bool _isLoading = false;

  void _search() async {
    if (_searchController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final res = await widget.service.searchMosques(_searchController.text);
    setState(() {
      _results = res;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Search Mosque Database"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(hintText: "Enter mosque name..."),
                  ),
                ),
                IconButton(onPressed: _search, icon: const Icon(Icons.search)),
              ],
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? const Padding(padding: EdgeInsets.all(8.0), child: Text("No results found"))
                    : SizedBox(
                        height: 200,
                        child: ListView.separated(
                          itemCount: _results.length,
                          separatorBuilder: (c, i) => const Divider(),
                          itemBuilder: (context, index) {
                            final mosque = _results[index];
                            return ListTile(
                              title: Text(mosque['name'] ?? "Unknown"),
                              subtitle: Text(mosque['address'] ?? "", maxLines: 1, overflow: TextOverflow.ellipsis),
                              onTap: () {
                                widget.onSelected(mosque['name']!, mosque['id']!);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
      ],
    );
  }
}

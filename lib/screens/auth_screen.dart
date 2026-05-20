import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Added for platform web detection
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // --- FORM INPUT CONTROLLERS ---
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // --- INTERFACE STATE FLAGS ---
  bool _isLogin = true;      // Toggles view mode between Login form and Sign Up registration form
  bool _rememberMe = false;  // Tracks the user's consent status for local asset credential saving

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials(); // Auto-populate input boxes on screen creation if records exist
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOCAL PERSISTENCE STORAGE ---

  // Fetches cached strings from the on-device local storage partition
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remembered_email') ?? '';
    final savedPassword = prefs.getString('remembered_password') ?? '';

    // If string records exist, dynamically populate text fields and toggle the checkmark flag active
    if (savedEmail.isNotEmpty && savedPassword.isNotEmpty) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  // Writes or deletes target credential strings in on-device storage depending on checkout flag conditions
  Future<void> _handleCredentialsSaving() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('remembered_email', _emailController.text.trim());
      await prefs.setString('remembered_password', _passwordController.text.trim());
    } else {
      // If unchecked, strip key values from storage keys map to forget user records
      await prefs.remove('remembered_email');
      await prefs.remove('remembered_password');
    }
  }

  // --- INTEGRATION WORKFLOW BACKEND ROUTING ---
  
  // Dispatches form values directly to Firebase Cloud Authentication service maps
  Future<void> _submit() async {
    try {
      if (_isLogin) {
        // LOGIN TARGET: Validate against existing cloud identity profiles registers
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        await _handleCredentialsSaving(); // Sync remember state selection to device memory
        return; 
      } else {
        // SIGNUP TARGET: Provisions a completely fresh account inside Firebase cloud buckets
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await _handleCredentialsSaving(); // Sync remember state selection to device memory
        return;
      }
    } catch (e) {
      if (!mounted) return;
      // Throw clear system error messages on-screen if login credentials/inputs are invalid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // --- SCREEN RENDERING INTERFACES ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Muted presentation backdrop color behind web frame elements
      body: Center(
        child: Container(
          // RESPONSIVE LAYOUT CLAUSE: Caps view container strictly to 450px on desktop web browsers, stretches full on mobile
          constraints: BoxConstraints(maxWidth: kIsWeb ? 450 : double.infinity),
          padding: const EdgeInsets.all(25.0),
          margin: EdgeInsets.all(kIsWeb ? 20.0 : 0.0),
          decoration: BoxDecoration(
            color: kIsWeb ? Colors.white : Colors.transparent, // Displays input fields inside floating cards on web
            borderRadius: BorderRadius.circular(kIsWeb ? 20 : 0),
            boxShadow: kIsWeb 
                ? [const BoxShadow(color: Colors.black12, blurRadius: 15, spreadRadius: 2)] 
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Clamps vertical sheet sizes on desktop window viewports
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLogin ? "Welcome Back" : "Create Account",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Email Field Form Entry Node
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              
              // Password Field Form Entry Node
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true, // Hides typed character inputs for field security guidelines
              ),
              const SizedBox(height: 10),
              
              // REMEMBER ME CHECKBOX ROW LAYER
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: Colors.blue,
                      onChanged: (bool? value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Remember Info",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
              
              const SizedBox(height: 15),
              
              // Form dispatch confirmation action module
              SizedBox(
                width: double.infinity, // Automatically stretches block sizes to fit desktop boundaries neatly
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(_isLogin ? "Login" : "Sign Up", style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 10),
              
              // Authentication form mode toggle hyperlink module
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? "Don't have an account? Sign up"
                      : "Already have an account? Login",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
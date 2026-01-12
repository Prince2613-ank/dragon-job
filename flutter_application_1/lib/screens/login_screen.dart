import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false; // State to toggle password visibility

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.white),
        ), // White title
        backgroundColor: Colors.blue, // Blue app bar
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
        elevation: 0, // No shadow for a flatter look
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0), // Consistent padding
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center content vertically
          children: [
            // Email Input Field
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                prefixIcon: const Icon(Icons.email), // Email icon
              ),
            ),
            const SizedBox(height: 20), // Spacing
            // Password Input Field
            TextField(
              obscureText: !_isPasswordVisible, // Toggle visibility
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                prefixIcon: const Icon(Icons.lock), // Lock icon
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible; // Toggle state
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30), // Spacing
            // Login Button
            SizedBox(
              width: double.infinity, // Full width
              height: 50, // Specific height
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Blue background
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  elevation: 5, // Subtle shadow
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ), // White text
                ),
                onPressed: () {
                  // After successful login, navigate to the main app wrapper
                  Navigator.pushReplacementNamed(context, '/main');
                },
              ),
            ),
            const SizedBox(height: 15), // Spacing
            // Forgot Password Link
            TextButton(
              onPressed: () {
                // Handle forgot password logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Forgot Password pressed!')),
                );
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

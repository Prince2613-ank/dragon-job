import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
          ), // Add horizontal padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Image
              Image.asset(
                'assets/dragon_image.png',
                height: 120, // Slightly smaller height for a cleaner look
              ),
              const SizedBox(height: 30),
              // Welcome Text
              const Text(
                'Welcome to Dragon Jobs',
                textAlign: TextAlign.center, // Center the text
                style: TextStyle(
                  fontSize: 32, // Larger font size
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Slightly softer black
                ),
              ),
              const SizedBox(height: 60), // More space before buttons
              // Login Button (ElevatedButton)
              SizedBox(
                width: double.infinity, // Make button full width
                height: 50, // Set a specific height
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Primary blue color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Rounded corners
                    ),
                    elevation: 5, // Add a subtle shadow
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ), // White text
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ),
              const SizedBox(height: 20), // Space between buttons
              // Sign Up Button (OutlinedButton)
              SizedBox(
                width: double.infinity, // Make button full width
                height: 50, // Set a specific height
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        Colors.blue, // Text color for outlined button
                    side: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ), // Blue border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                    ), // Blue text
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

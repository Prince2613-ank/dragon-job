// FILE: lib/main.dart

import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_app_wrapper.dart';
import 'screens/manage_resume_screen.dart';
import 'screens/saved_jobs_screen.dart'; // Make sure this is imported

import 'screens/notifications_screen.dart';
import 'screens/recommended_jobs_screen.dart';
import 'screens/filter_screen.dart';
import 'screens/post_job_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/analysis_results_screen.dart';
import 'screens/resume_builder_screen.dart';

void main() {
  runApp(const JobPortalApp());
}

class JobPortalApp extends StatelessWidget {
  const JobPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Portal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome',

      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/main': (context) => const MainAppWrapper(),
        '/manage_resume': (context) => const ManageResumeScreen(),
        '/saved_jobs': (context) =>
            const SavedJobsScreen(), // This line must be here

        '/notifications': (context) => const NotificationsScreen(),
        '/recommended_jobs': (context) => const RecommendedJobsScreen(),
        '/filters': (context) => const FilterScreen(),
        '/post_job': (context) => const PostJobScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/analysis_results': (context) => const AnalysisResultsScreen(),
        '/resume_builder': (context) => const ResumeBuilderScreen(),
      },
    );
  }
}

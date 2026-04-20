// FILE: lib/main.dart

import 'package:flutter/material.dart';

// AUTH & ENTRY
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

// MAIN APP
import 'screens/main_app_wrapper.dart';

// USER SCREENS
import 'screens/manage_resume_screen.dart';
import 'screens/saved_jobs_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/recommended_jobs_screen.dart';
import 'screens/filter_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/analysis_results_screen.dart';
import 'screens/resume_builder_screen.dart';
import 'screens/applied_jobs_screen.dart';

// ADMIN & SETTINGS (🔥 NEW)
import 'screens/settings_screen.dart';
import 'screens/admin_panel_screen.dart';
import 'screens/post_type_screen.dart';
import 'screens/post_form_screen.dart';

// POST
import 'screens/post_job_screen.dart';

void main() {
  runApp(const JobPortalApp());
}

class JobPortalApp extends StatelessWidget {
  const JobPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Portal',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      initialRoute: '/welcome',

      routes: {
        // ================= AUTH =================
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),

        // ================= MAIN =================
        '/main': (context) => const MainAppWrapper(),

        // ================= USER =================
        '/manage_resume': (context) => const ManageResumeScreen(),
        '/saved_jobs': (context) => const SavedJobsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/recommended_jobs': (context) => const RecommendedJobsScreen(),
        '/filters': (context) => const FilterScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/analysis_results': (context) => const AnalysisResultsScreen(),
        '/resume_builder': (context) => const ResumeBuilderScreen(),
        '/applied_jobs': (context) => const AppliedJobsScreen(),

        // ================= SETTINGS & ADMIN =================
        '/settings': (context) => const SettingsScreen(),
        '/admin': (context) => const AdminPanelScreen(),
        '/post_type': (context) => const PostTypeScreen(),

        // ================= POST =================
        '/post_job': (context) => const PostJobScreen(),

        // NOTE:
        // PostFormScreen needs arguments (postType),
        // so it should NOT be used directly with named routes
      },
    );
  }
}

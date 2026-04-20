# Services Documentation

This directory contains all the API service classes for the Dragon Jobs Flutter application. Services are organized as singleton instances for easy access and management.

## Overview

All services follow the singleton pattern and provide a centralized way to communicate with the backend API.

### Available Services

| Service | Purpose |
|---------|---------|
| **ApiClient** | Low-level HTTP client with auth token management |
| **AuthService** | Authentication (login, signup, logout, profile) |
| **PostsService** | Job posts management |
| **SavedJobsService** | Save/unsave jobs |
| **UserSkillsService** | User skills management |
| **JobRecommendationService** | AI resume analysis and job recommendations |
| **AppliedJobsService** | Track job applications |
| **NotificationService** | User notifications |
| **SearchService** | Advanced job search and filtering |

## Usage Examples

### via ServiceProvider (Recommended)

```dart
import 'package:flutter_application_1/services/service_provider.dart';

// ===== Authentication =====
// Login
try {
  final user = await ServiceProvider.auth.login(
    email: 'user@example.com',
    password: 'password',
  );
  print('Logged in as: ${user['name']}');
} catch (error) {
  print('Login failed: $error');
}

// Get current user
final currentUser = await ServiceProvider.auth.getCurrentUser();
print('Name: ${currentUser['name']}');
print('Email: ${currentUser['email']}');

// Update profile
await ServiceProvider.auth.updateCurrentUser(
  name: 'New Name',
  email: 'new@example.com',
);

// Logout
await ServiceProvider.auth.logout();

// ===== Posts/Jobs =====
// Fetch all posts
final allPosts = await ServiceProvider.posts.fetchPosts();

// Fetch specific type
final jobPosts = await ServiceProvider.posts.fetchPosts(type: 'job');
final internships = await ServiceProvider.posts.fetchPosts(type: 'internship');

// Get single post
final post = await ServiceProvider.posts.fetchPostById(1);
print('Job: ${post['role']} at ${post['company']}');

// Create post (admin only)
final newPost = await ServiceProvider.posts.createPost({
  'postType': 'job',
  'role': 'Flutter Developer',
  'company': 'Tech Corp',
  'salary': '60000 - 80000',
  'location': 'Remote',
  'description': 'We are looking for...',
});

// ===== Saved Jobs =====
// Fetch saved jobs
final savedJobs = await ServiceProvider.savedJobs.fetchSavedJobs();

// Save a job
await ServiceProvider.savedJobs.saveJob(1);

// Remove saved job
await ServiceProvider.savedJobs.unsaveJob(1);

// Check if saved
final isSaved = await ServiceProvider.savedJobs.isJobSaved(1);

// ===== Skills =====
// Fetch user skills
final skills = await ServiceProvider.skills.fetchSkills();

// Add a skill
await ServiceProvider.skills.addSkill('Flutter');

// Remove a skill
await ServiceProvider.skills.removeSkill('Dart');

// Replace all skills
await ServiceProvider.skills.replaceSkills(['Flutter', 'Dart', 'Firebase']);

// Check if skill exists
final hasFlutter = await ServiceProvider.skills.hasSkill('Flutter');

// ===== Job Recommendations =====
// Analyze resume and get recommendations
final analysis = await ServiceProvider.jobRecommendations
    .analyzeResumeAndGetRecommendations(
  filePath: '/path/to/resume.pdf',
  type: 'job',
);

// Extract parsed resume data
final parsedResume = ServiceProvider.jobRecommendations
    .extractParsedResume(analysis);
print('Skills detected: ${parsedResume["skills"]}');

// Get recommended jobs
final recommendedJobs = ServiceProvider.jobRecommendations
    .extractRecommendedJobs(analysis);
for (final job in recommendedJobs) {
  print('Job: ${job["post"]["role"]} - Score: ${job["score"]}');
}

// Get profile completion percentage
final completion = ServiceProvider.jobRecommendations
    .getProfileCompletion(analysis);
print('Profile ${completion}% complete');

// ===== Applied Jobs =====
// Fetch applied jobs
final applied = await ServiceProvider.appliedJobs.fetchAppliedJobs();

// Apply to job
await ServiceProvider.appliedJobs.applyToJob(
  1,
  coverLetter: 'I am very interested in this position...',
);

// Check if already applied
final alreadyApplied = await ServiceProvider.appliedJobs.hasApplied(1);

// Get application status
final status = await ServiceProvider.appliedJobs.getApplicationStatus(1);

// Withdraw application
await ServiceProvider.appliedJobs.withdrawApplication(appId);

// ===== Notifications =====
// Fetch all notifications
final notifications = await ServiceProvider.notifications.fetchNotifications();

// Fetch unread only
final unread = await ServiceProvider.notifications.fetchUnreadNotifications();

// Mark as read
await ServiceProvider.notifications.markAsRead(notificationId);

// Mark all as read
await ServiceProvider.notifications.markAllAsRead();

// Get unread count
final count = await ServiceProvider.notifications.getUnreadCount();

// Delete notification
await ServiceProvider.notifications.deleteNotification(notificationId);

// ===== Search =====
// Simple search
final results = await ServiceProvider.search.searchJobs(
  query: 'Flutter Developer',
);

// Search with filters
final filtered = await ServiceProvider.search.searchJobs(
  type: 'job',
  location: 'Remote',
  skills: ['Flutter', 'Dart'],
  limit: 20,
);

// Search by location
final locationJobs = await ServiceProvider.search.searchByLocation('Bangalore');

// Search by company
final companyJobs = await ServiceProvider.search.searchByCompany('Google');

// Filter by skills
final skillJobs = await ServiceProvider.search.filterBySkills(['Flutter']);

// Get trending searches
final trending = await ServiceProvider.search.getTrendingSearches();

// Get search suggestions
final suggestions = await ServiceProvider.search.getSearchSuggestions('flutter');
```

## Error Handling

All services throw `ApiException` on errors:

```dart
import 'package:flutter_application_1/services/api_client.dart';

try {
  final user = await ServiceProvider.auth.getCurrentUser();
} on ApiException catch (error) {
  print('Error: ${error.message}');
  print('Status: ${error.statusCode}');
  print('Original: ${error.originalError}');
}
```

## Service Methods Reference

### AuthService
| Method | Description |
|--------|-------------|
| `signup()` | Create new account |
| `login()` | Login with credentials |
| `getCurrentUser()` | Get current authenticated user |
| `updateCurrentUser()` | Update profile (name, email) |
| `isAuthenticated()` | Check if user is logged in |
| `logout()` | Logout and clear token |
| `getAuthToken()` | Get stored auth token |

### PostsService
| Method | Description |
|--------|-------------|
| `fetchPosts()` | Get all posts (optional type filter) |
| `fetchPostById()` | Get specific post by ID |
| `createPost()` | Create new post (admin only) |

### SavedJobsService
| Method | Description |
|--------|-------------|
| `fetchSavedJobs()` | Get all saved jobs |
| `saveJob()` | Save a job |
| `unsaveJob()` | Remove saved job |
| `isJobSaved()` | Check if job is saved |

### UserSkillsService
| Method | Description |
|--------|-------------|
| `fetchSkills()` | Get user skills |
| `addSkill()` | Add single skill |
| `replaceSkills()` | Replace all skills |
| `removeSkill()` | Remove skill |
| `hasSkill()` | Check if skill exists |

### JobRecommendationService
| Method | Description |
|--------|-------------|
| `analyzeResumeAndGetRecommendations()` | Upload & analyze resume |
| `extractRecommendedJobs()` | Get recommended jobs from analysis |
| `extractParsedResume()` | Get parsed resume data |
| `getProfileCompletion()` | Get completion percentage |
| `getTopMatchScore()` | Get best job match score |
| `getMatchedSkills()` | Get matching skills |
| `getMissingSkills()` | Get missing skills |

### AppliedJobsService
| Method | Description |
|--------|-------------|
| `fetchAppliedJobs()` | Get all applications |
| `fetchAppliedJobsByStatus()` | Filter by status |
| `applyToJob()` | Apply with optional cover letter |
| `withdrawApplication()` | Withdraw application |
| `hasApplied()` | Check if already applied |
| `getApplicationStatus()` | Get current status |

### NotificationService
| Method | Description |
|--------|-------------|
| `fetchNotifications()` | Get all notifications |
| `fetchUnreadNotifications()` | Get unread only |
| `markAsRead()` | Mark single as read |
| `markAllAsRead()` | Mark all as read |
| `deleteNotification()` | Delete single |
| `deleteAllNotifications()` | Delete all |
| `getUnreadCount()` | Get unread count |

### SearchService
| Method | Description |
|--------|-------------|
| `searchJobs()` | Multi-criteria search |
| `advancedSearch()` | Complex filter search |
| `searchByLocation()` | Filter by location |
| `searchByCompany()` | Filter by company |
| `searchByType()` | Filter by job type |
| `filterBySkills()` | Filter by required skills |
| `getTrendingSearches()` | Get trending searches |
| `getSearchSuggestions()` | Get search autocomplete |

## Best Practices

1. **Always use ServiceProvider** for consistency:
   ```dart
   // ✅ Good
   await ServiceProvider.auth.login(...);
   
   // ❌ Avoid
   await AuthService.instance.login(...);
   ```

2. **Handle errors appropriately**:
   ```dart
   try {
     final data = await ServiceProvider.posts.fetchPosts();
   } on ApiException catch (error) {
     // Handle API errors
     showErrorDialog(error.message);
   } catch (error) {
     // Handle other errors
     showErrorDialog('Unexpected error');
   }
   ```

3. **Check authentication** before protected calls:
   ```dart
   final isAuth = await ServiceProvider.auth.isAuthenticated();
   if (!isAuth) {
     navigateToLogin();
     return;
   }
   ```

4. **Initialize services in main.dart**:
   ```dart
   void main() async {
     await ServiceProvider.initialize();
     runApp(const JobPortalApp());
   }
   ```

5. **Use refresh pattern for list screens**:
   ```dart
   Future<void> _refreshPosts() async {
     try {
       final posts = await ServiceProvider.posts.fetchPosts();
       setState(() => _posts = posts);
     } catch (error) {
       showError(error);
     }
   }
   ```

## Configuration

### API Base URL

Default: `http://10.0.2.2:4000` (Android emulator)

Override:
```bash
flutter run --dart-define=API_BASE_URL=http://your-api-url
```

### Authentication

Token is automatically managed by ApiClient:
- Stored in SharedPreferences
- Attached to all authenticated requests
- Cleared on logout

## Notification Types

```dart
NotificationService.typeJobRecommendation   // 'job_recommendation'
NotificationService.typeApplicationStatus   // 'application_status'
NotificationService.typeSavedJob            // 'saved_job'
NotificationService.typeSkillUpdate         // 'skill_update'
NotificationService.typeProfileUpdate       // 'profile_update'
```

## Job Types

```dart
SearchService.jobTypes // ['job', 'internship', 'daily_wage']
```

## Application Statuses

```dart
AppliedJobsService.validStatuses
// ['pending', 'reviewed', 'accepted', 'rejected', 'withdrawn']
```

## Troubleshooting

### Token Expired
Services automatically refresh token on 401 response.

### No Network
All services throw ApiException with network error details.

### Service Not Available
Check if service is initialized via `ServiceProvider.initialize()`.

## Support

For issues or questions about services, refer to:
- Backend API documentation
- Service class documentation (inline comments)
- Example usage in screens

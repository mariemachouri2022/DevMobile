# SmartFit - Fitness Coaching Management App

A Flutter mobile application for managing fitness coaches and clients with user authentication, profile management, and coach-client assignment features.

## 📱 Project Overview

**SmartFit** is a comprehensive fitness coaching management system designed for three types of users:
- **Admin**: Full control over user management, create/edit/delete users, and assign coaches to clients
- **Coach**: Manage and view their assigned clients' profiles and information
- **Client**: View their profile, sessions, and performance data

## 👥 Team

- **Project Lead**: Achouri Mariem
- **Module**: User Management (Coaches & Clients)

## ✨ Features

### 1. Authentication System
- ✅ Secure login with email/password
- ✅ User registration with role selection
- ✅ Session persistence with SharedPreferences
- ✅ Logout functionality

### 2. User Management (CRUD)
- ✅ Create new users (Admin only)
- ✅ Read/View user profiles
- ✅ Update user information
- ✅ Delete users (Admin only)
- ✅ Search users by name, email, or phone
- ✅ Filter users by role (Admin, Coach, Client)

### 3. Profile Management
- ✅ View detailed user profiles
- ✅ Edit personal information
- ✅ Display contact information
- ✅ Role-based profile access

### 4. Coach-Client Association
- ✅ Assign coaches to clients (Admin only)
- ✅ View clients assigned to a coach
- ✅ Modify coach-client associations
- ✅ Display coach information on client profiles

### 5. User Interface
- ✅ Modern, responsive Material Design 3
- ✅ Custom purple theme matching mockups
- ✅ Intuitive navigation
- ✅ Role-based UI elements
- ✅ Search and filter capabilities

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/
│   └── user_model.dart      # User data model with roles
├── providers/
│   ├── auth_provider.dart   # Authentication state management
│   └── user_provider.dart   # User data state management
├── screens/
│   ├── login_screen.dart           # Login page
│   ├── register_screen.dart        # Registration page
│   ├── home_screen.dart            # Dashboard/Home
│   ├── user_list_screen.dart       # User list with search/filter
│   ├── user_profile_screen.dart    # User profile details
│   ├── user_form_screen.dart       # Create/Edit user form
│   └── assign_coach_screen.dart    # Coach assignment interface
├── services/
│   └── database_service.dart       # SQLite database operations
└── theme/
    └── app_theme.dart              # App theme configuration
```

### Tech Stack
- **Framework**: Flutter 3.35.3
- **State Management**: Provider
- **Database**: SQLite (sqflite)
- **Local Storage**: SharedPreferences
- **UI**: Material Design 3 with Google Fonts

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.2              # State management
  sqflite: ^2.3.3+1            # Local database
  path_provider: ^2.1.3         # File system paths
  path: ^1.9.0                  # Path manipulation
  google_fonts: ^6.2.1          # Custom fonts
  shared_preferences: ^2.2.3    # Local storage

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK ^3.9.2
- Android Studio / VS Code with Flutter extensions
- Android device/emulator or iOS device/simulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/mariemachouri2022/DevMobile.git
   cd DevMobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🔐 Default Credentials

The app comes with a pre-configured admin account:

- **Email**: `admin@smartfit.com`
- **Password**: `admin123`

## 📊 Database Schema

### Users Table
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  firstName TEXT NOT NULL,
  age INTEGER NOT NULL,
  phone TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  role TEXT NOT NULL,
  coachId INTEGER,
  FOREIGN KEY (coachId) REFERENCES users (id) ON DELETE SET NULL
)
```

## 🎨 UI Screens

1. **Authentication Screen**: Login and registration
2. **Home Screen**: Dashboard with quick actions based on role
3. **User List Screen**: Searchable and filterable list of users
4. **User Profile Screen**: Detailed user information
5. **User Form Screen**: Create/Edit user information
6. **Assign Coach Screen**: Interface for assigning coaches to clients

## 🔒 Role-Based Access Control

### Admin Capabilities
- ✅ View all users
- ✅ Create new users (any role)
- ✅ Edit any user
- ✅ Delete users
- ✅ Assign coaches to clients
- ✅ View all profiles

### Coach Capabilities
- ✅ View their assigned clients
- ✅ View client profiles
- ✅ Edit their own profile

### Client Capabilities
- ✅ View their own profile
- ✅ View assigned coach information
- ✅ Edit their own profile

## 🎯 Success Criteria

✅ **Authentication**: Secure login/logout with session persistence  
✅ **CRUD Operations**: Complete user management functionality  
✅ **Coach Assignment**: Functional coach-client association system  
✅ **Local Database**: SQLite implementation with offline functionality  
✅ **Responsive UI**: Mobile-optimized interface matching design mockups  
✅ **Search & Filter**: Advanced user discovery features  
✅ **Role-Based Access**: Proper permission controls for different user types  

## 🛠️ Development

### Running Tests
```bash
flutter test
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Code Formatting
```bash
flutter format lib/
```

### Analysis
```bash
flutter analyze
```

## 📝 Future Enhancements

- [ ] Session management and performance tracking
- [ ] Push notifications
- [ ] Chat between coaches and clients
- [ ] Exercise library
- [ ] Progress photos
- [ ] Workout plans
- [ ] Meal planning
- [ ] Export data to PDF/CSV

## 🐛 Known Issues

- None currently reported

## 📄 License

This project is part of an academic assignment.

## 👨‍💻 Developer

**Mariem Achouri**  
GitHub: [@mariemachouri2022](https://github.com/mariemachouri2022)

---

Built with ❤️ using Flutter

// Test Data Script for SmartFit
// You can use this to populate the database with test users

/*
EXAMPLE USERS TO CREATE:

1. Coach Example:
   - Name: Smith
   - First Name: John
   - Age: 35
   - Phone: 1234567890
   - Email: john.coach@smartfit.com
   - Password: coach123
   - Role: Coach

2. Client Example 1:
   - Name: Johnson
   - First Name: Emma
   - Age: 28
   - Phone: 2345678901
   - Email: emma.client@smartfit.com
   - Password: client123
   - Role: Client

3. Client Example 2:
   - Name: Williams
   - First Name: Michael
   - Age: 32
   - Phone: 3456789012
   - Email: michael.client@smartfit.com
   - Password: client123
   - Role: Client

4. Coach Example 2:
   - Name: Brown
   - First Name: Sarah
   - Age: 30
   - Phone: 4567890123
   - Email: sarah.coach@smartfit.com
   - Password: coach123
   - Role: Coach

TESTING WORKFLOW:

1. Login as Admin (admin@smartfit.com / admin123)
2. Create 2 coaches and 4 clients using the "Add User" button
3. Assign clients to coaches using the "Assign Coach" feature
4. Logout and login as a coach to see their clients
5. Logout and login as a client to see their assigned coach
6. Test search functionality with different queries
7. Test filter by role (Admin, Coach, Client)
8. Test edit profile functionality
9. Test delete user (admin only)

FEATURES TO TEST:

✅ Authentication
   - Login with correct credentials
   - Login with incorrect credentials
   - Register new account
   - Session persistence (close and reopen app)
   - Logout

✅ User Management (Admin)
   - Create new users
   - Edit existing users
   - Delete users
   - Search users
   - Filter by role

✅ Coach Features
   - View assigned clients
   - View client profiles
   - Edit own profile

✅ Client Features
   - View own profile
   - View assigned coach
   - Edit own profile

✅ Profile Management
   - View detailed profile
   - Edit personal information
   - View contact information
   - Role badge display

✅ Coach Assignment
   - Assign coach to client
   - Change coach assignment
   - View unassigned clients

DATABASE LOCATION:
The SQLite database is stored locally on the device at:
Android: /data/data/com.example.smartfit/databases/smartfit.db
iOS: ~/Library/Application Support/smartfit.db

To reset the database during development:
1. Uninstall the app
2. Reinstall and run again
3. The database will be recreated with the default admin user

TROUBLESHOOTING:

Issue: "Email already exists" when creating user
Solution: Use a unique email address for each user

Issue: Can't see clients as a coach
Solution: Make sure clients are assigned to that coach using admin account

Issue: Can't delete admin user
Solution: Admin user should not be deleted to maintain system access

Issue: Session not persisting
Solution: Check SharedPreferences implementation, may need to clear app data

PERFORMANCE TIPS:

1. The app uses Provider for state management - changes are reactive
2. All database operations are async - UI shows loading indicators
3. Search is case-insensitive and searches across multiple fields
4. Filtering happens in memory after loading users
5. RefreshIndicator available on lists to reload data

CUSTOMIZATION IDEAS:

1. Add profile pictures using image_picker
2. Add email validation with regex
3. Add password strength indicator
4. Add forgot password functionality
5. Add statistics dashboard for coaches
6. Add workout session tracking
7. Add progress photos for clients
8. Add meal planning features
9. Add chat between coach and client
10. Add push notifications for reminders

*/

void main() {
  print('SmartFit Test Data Guide');
  print('See comments in this file for test scenarios and data');
}

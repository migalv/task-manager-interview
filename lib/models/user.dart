// Base User class
abstract class User {
  final String id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
  
  // User methods
  bool canCreateTasks();
  bool canDeleteTasks();
  bool canViewAllTasks();
  List<String> getPermissions();
  void updateProfile(String name, String email);
  void changePassword(String newPassword);
  String getUserDisplayName();
}

// Regular user implementation
class RegularUser extends User {
  final String department;
  
  RegularUser({
    required super.id,
    required super.name,
    required super.email,
    required this.department,
  });
  
  @override
  bool canCreateTasks() => true;
  
  @override
  bool canDeleteTasks() => false;
  
  @override
  bool canViewAllTasks() => false;
  
  @override
  List<String> getPermissions() => ['create_task', 'edit_own_task'];
  
  @override
  void updateProfile(String name, String email) {
    // Validate profile data
    if (name.isEmpty || name.length < 2) {
      throw Exception('Name must be at least 2 characters');
    }
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      throw Exception('Invalid email format');
    }
    // Update profile logic here
  }
  
  @override
  void changePassword(String newPassword) {
    // Validate new password
    if (newPassword.isEmpty || newPassword.length < 8) {
      throw Exception('Password must be at least 8 characters');
    }
    if (!newPassword.contains(RegExp(r'[A-Z]'))) {
      throw Exception('Password must contain uppercase letter');
    }
    if (!newPassword.contains(RegExp(r'[0-9]'))) {
      throw Exception('Password must contain number');
    }
    // Change password logic
  }
  
  @override
  String getUserDisplayName() {
    return '$name ($department)';
  }
}

// Admin user implementation
class AdminUser extends User {
  final List<String> managedDepartments;
  
  AdminUser({
    required super.id,
    required super.name,
    required super.email,
    required this.managedDepartments,
  });
  
  @override
  bool canCreateTasks() => true;
  
  @override
  bool canDeleteTasks() => true;
  
  @override
  bool canViewAllTasks() => true;
  
  @override
  List<String> getPermissions() => [
    'create_task', 'edit_task', 'delete_task', 'view_all_tasks', 
    'manage_users', 'system_admin'
  ];
  
  @override
  void updateProfile(String name, String email) {
    // Validate profile data
    if (name.isEmpty || name.length < 2) {
      throw Exception('Name must be at least 2 characters');
    }
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      throw Exception('Invalid email format');
    }
    // Additional admin validation
    if (!email.endsWith('@company.com')) {
      throw Exception('Admin must use company email');
    }
    // Update profile logic here
  }
  
  @override
  void changePassword(String newPassword) {
    // Validate new password
    if (newPassword.isEmpty || newPassword.length < 8) {
      throw Exception('Password must be at least 8 characters');
    }
    if (!newPassword.contains(RegExp(r'[A-Z]'))) {
      throw Exception('Password must contain uppercase letter');
    }
    if (!newPassword.contains(RegExp(r'[0-9]'))) {
      throw Exception('Password must contain number');
    }
    // Additional admin requirements
    if (!newPassword.contains(RegExp(r'[!@#$%^&*]'))) {
      throw Exception('Admin password must contain special character');
    }
    // Change password logic
  }
  
  @override
  String getUserDisplayName() {
    return '$name (Admin - ${managedDepartments.join(', ')})';
  }
}

// Guest user implementation
class GuestUser extends User {
  GuestUser({required super.id, required super.name, required super.email});
  
  @override
  bool canCreateTasks() => false;
  
  @override
  bool canDeleteTasks() => false;
  
  @override
  bool canViewAllTasks() => false;
  
  @override
  List<String> getPermissions() => ['view_public_tasks'];
  
  // Guest users cannot update profile
  @override
  void updateProfile(String name, String email) {
    throw Exception('Guest users cannot update profile');
  }
  
  // Guest users cannot change password
  @override
  void changePassword(String newPassword) {
    throw Exception('Guest users cannot change password');
  }
  
  @override
  String getUserDisplayName() {
    return '$name (Guest)';
  }
}
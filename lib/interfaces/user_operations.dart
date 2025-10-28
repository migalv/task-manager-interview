// User operations interface
abstract class UserOperations {
  // Basic user operations
  Future<bool> login(String email, String password);
  Future<void> logout();
  
  // Profile operations
  Future<void> updateProfile(String name, String email);
  Future<void> changePassword(String newPassword);
  
  // Admin operations
  Future<List<String>> getAllUsers();
  Future<void> deleteUser(String userId);
  Future<void> promoteUserToAdmin(String userId);
  Future<void> demoteUserFromAdmin(String userId);
  Future<void> resetUserPassword(String userId, String newPassword);
  
  // System operations
  Future<void> backupDatabase();
  Future<void> restoreDatabase(String backupPath);
  Future<void> updateSystemSettings(Map<String, dynamic> settings);
  Future<List<String>> getSystemLogs();
  
  // Guest operations
  Future<void> requestAccount();
  Future<void> extendGuestSession();
  
  // Notification operations
  Future<void> sendEmailNotification(String userId, String message);
  Future<void> sendPushNotification(String userId, String message);
  Future<void> sendSMSNotification(String userId, String message);
  
  // Reporting operations
  Future<Map<String, dynamic>> generateUserReport(String userId);
  Future<Map<String, dynamic>> generateSystemReport();
  Future<void> exportUserData(String userId, String format);
  
  // Audit operations
  Future<void> logUserAction(String userId, String action);
  Future<List<String>> getUserAuditLog(String userId);
  Future<void> clearAuditLogs();
}


import 'dart:convert';
import 'package:http/http.dart' as http;

// Handles sending notifications to users
class NotificationSender {
  
  // Send notification based on type
  Future<bool> sendNotification(String type, String userId, String message, Map<String, dynamic>? options) async {
    try {
      // Determine notification type and send accordingly
      if (type == 'email') {
        return await _sendEmailNotification(userId, message, options);
      } else if (type == 'push') {
        return await _sendPushNotification(userId, message, options);
      } else if (type == 'sms') {
        return await _sendSMSNotification(userId, message, options);
      } else if (type == 'slack') {
        return await _sendSlackNotification(userId, message, options);
      } else if (type == 'teams') {
        return await _sendTeamsNotification(userId, message, options);
      } else if (type == 'webhook') {
        return await _sendWebhookNotification(userId, message, options);
      } else if (type == 'in_app') {
        return await _sendInAppNotification(userId, message, options);
      } else {
        throw Exception('Unknown notification type: $type');
      }
    } catch (e) {
      print('Notification failed: $e');
      return false;
    }
  }
  
  // Get icon for notification type
  String getNotificationIcon(String type) {
    // Return appropriate icon for each notification type
    if (type == 'email') {
      return '📧';
    } else if (type == 'push') {
      return '📱';
    } else if (type == 'sms') {
      return '💬';
    } else if (type == 'slack') {
      return '💼';
    } else if (type == 'teams') {
      return '👥';
    } else if (type == 'webhook') {
      return '🔗';
    } else if (type == 'in_app') {
      return '🔔';
    } else {
      return '❓';
    }
  }
  
  // Get default options for notification type
  Map<String, dynamic> getDefaultOptions(String type) {
    // Return default configuration for each notification type
    if (type == 'email') {
      return {'priority': 'normal', 'format': 'html'};
    } else if (type == 'push') {
      return {'sound': true, 'badge': true};
    } else if (type == 'sms') {
      return {'max_length': 160};
    } else if (type == 'slack') {
      return {'channel': 'general', 'markdown': true};
    } else if (type == 'teams') {
      return {'channel': 'general', 'markdown': true};
    } else if (type == 'webhook') {
      return {'timeout': 30, 'retry': 3};
    } else if (type == 'in_app') {
      return {'persistent': true, 'action_buttons': []};
    } else {
      return {};
    }
  }
  
  // Validate notification type
  bool isValidNotificationType(String type) {
    // Check if notification type is supported
    return ['email', 'push', 'sms', 'slack', 'teams', 'webhook', 'in_app'].contains(type);
  }
  
  // Individual notification methods
  Future<bool> _sendEmailNotification(String userId, String message, Map<String, dynamic>? options) async {
    // Send email notification
    try {
      final response = await http.post(
        Uri.parse('https://api.emailservice.com/send'),
        headers: {'Content-Type': 'application/json', 'API-Key': 'email-api-key'},
        body: jsonEncode({
          'user_id': userId,
          'message': message,
          'type': 'email',
          'options': options ?? getDefaultOptions('email'),
        }),
      );
      
      // Handle email API response
      if (response.statusCode == 200) {
        print('Email notification sent successfully');
        return true;
      } else {
        print('Email notification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Email notification error: $e');
      return false;
    }
  }
  
  Future<bool> _sendPushNotification(String userId, String message, Map<String, dynamic>? options) async {
    // Send push notification
    try {
      final response = await http.post(
        Uri.parse('https://api.pushservice.com/send'),
        headers: {'Content-Type': 'application/json', 'API-Key': 'push-api-key'},
        body: jsonEncode({
          'user_id': userId,
          'message': message,
          'type': 'push',
          'options': options ?? getDefaultOptions('push'),
        }),
      );
      
      // Handle push API response
      if (response.statusCode == 200) {
        print('Push notification sent successfully');
        return true;
      } else {
        print('Push notification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Push notification error: $e');
      return false;
    }
  }
  
  Future<bool> _sendSMSNotification(String userId, String message, Map<String, dynamic>? options) async {
    // Send SMS notification
    try {
      final response = await http.post(
        Uri.parse('https://api.smsservice.com/send'),
        headers: {'Content-Type': 'application/json', 'API-Key': 'sms-api-key'},
        body: jsonEncode({
          'user_id': userId,
          'message': message,
          'type': 'sms',
          'options': options ?? getDefaultOptions('sms'),
        }),
      );
      
      if (response.statusCode == 200) {
        print('SMS notification sent successfully');
        return true;
      } else {
        print('SMS notification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('SMS notification error: $e');
      return false;
    }
  }
  
  Future<bool> _sendSlackNotification(String userId, String message, Map<String, dynamic>? options) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.slack.com/send'),
        headers: {'Content-Type': 'application/json', 'API-Key': 'slack-api-key'},
        body: jsonEncode({
          'user_id': userId,
          'message': message,
          'type': 'slack',
          'options': options ?? getDefaultOptions('slack'),
        }),
      );
      
      if (response.statusCode == 200) {
        print('Slack notification sent successfully');
        return true;
      } else {
        print('Slack notification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Slack notification error: $e');
      return false;
    }
  }
  
  Future<bool> _sendTeamsNotification(String userId, String message, Map<String, dynamic>? options) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.teams.com/send'),
        headers: {'Content-Type': 'application/json', 'API-Key': 'teams-api-key'},
        body: jsonEncode({
          'user_id': userId,
          'message': message,
          'type': 'teams',
          'options': options ?? getDefaultOptions('teams'),
        }),
      );
      
      if (response.statusCode == 200) {
        print('Teams notification sent successfully');
        return true;
      } else {
        print('Teams notification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Teams notification error: $e');
      return false;
    }
  }
  
  Future<bool> _sendWebhookNotification(String userId, String message, Map<String, dynamic>? options) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.webhook.com/send'),
        headers: {'Content-Type': 'application/json', 'API-Key': 'webhook-api-key'},
        body: jsonEncode({
          'user_id': userId,
          'message': message,
          'type': 'webhook',
          'options': options ?? getDefaultOptions('webhook'),
        }),
      );
      
      if (response.statusCode == 200) {
        print('Webhook notification sent successfully');
        return true;
      } else {
        print('Webhook notification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Webhook notification error: $e');
      return false;
    }
  }
  
  Future<bool> _sendInAppNotification(String userId, String message, Map<String, dynamic>? options) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.inapp.com/send'),
        headers: {'Content-Type': 'application/json', 'API-Key': 'inapp-api-key'},
        body: jsonEncode({
          'user_id': userId,
          'message': message,
          'type': 'in_app',
          'options': options ?? getDefaultOptions('in_app'),
        }),
      );
      
      if (response.statusCode == 200) {
        print('In-app notification sent successfully');
        return true;
      } else {
        print('In-app notification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('In-app notification error: $e');
      return false;
    }
  }
}
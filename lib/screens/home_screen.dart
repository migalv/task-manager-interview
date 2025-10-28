import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/user_manager.dart';
import '../services/notification_sender.dart';
import '../widgets/task_widget.dart';

// More SOLID violations in the home screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // DIP VIOLATIONS: More direct concrete dependencies
  final UserManager _userManager = UserManager();
  final NotificationSender _notificationSender = NotificationSender();
  
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          // DIP VIOLATION: Direct access to user manager
          ListenableBuilder(
            listenable: _userManager,
            builder: (context, child) {
              return PopupMenuButton<String>(
                icon: CircleAvatar(
                  child: Text(
                    _userManager.currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Text('Hello, ${_userManager.currentUser?.getUserDisplayName() ?? 'User'}'),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'logout') {
                    _logout();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewTask,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTasks,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to create your first task',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          return TaskWidget(
            task: _tasks[index],
            onTaskUpdated: _loadTasks,
          );
        },
      ),
    );
  }
  
  // SRP VIOLATION: Home screen handling business logic
  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // DIP VIOLATION: Direct access to user manager
      if (_userManager.currentUser == null) {
        Navigator.pushReplacementNamed(context, '/');
        return;
      }
      
      // Simulate API call with duplicated error handling pattern
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock task data - in real app this would come from an API
      _tasks = _generateMockTasks();
      
    } catch (e) {
      _errorMessage = 'Failed to load tasks: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Mock data generation (would be replaced with real API calls)
  List<Task> _generateMockTasks() {
    final now = DateTime.now();
    return [
      Task(
        id: '1',
        title: 'Complete Flutter interview project',
        description: 'Review the task manager code for SOLID principle violations and code quality issues.',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        assignedUserId: _userManager.currentUser!.id,
        createdAt: now.subtract(const Duration(days: 2)),
        dueDate: now.add(const Duration(days: 1)),
      ),
      Task(
        id: '2',
        title: 'Refactor user management system',
        description: 'Improve the user management code to follow SOLID principles and reduce code duplication.',
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        assignedUserId: _userManager.currentUser!.id,
        createdAt: now.subtract(const Duration(days: 1)),
        dueDate: now.add(const Duration(days: 3)),
      ),
      Task(
        id: '3',
        title: 'Implement notification abstraction',
        description: 'Create a proper abstraction for the notification system to follow the Open/Closed principle.',
        status: TaskStatus.pending,
        priority: TaskPriority.urgent,
        assignedUserId: _userManager.currentUser!.id,
        createdAt: now.subtract(const Duration(hours: 6)),
        dueDate: now.subtract(const Duration(days: 1)), // This one is overdue
      ),
      Task(
        id: '4',
        title: 'Write unit tests',
        description: 'Add comprehensive unit tests for all the business logic components.',
        status: TaskStatus.completed,
        priority: TaskPriority.low,
        assignedUserId: _userManager.currentUser!.id,
        createdAt: now.subtract(const Duration(days: 5)),
        dueDate: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
  
  Future<void> _createNewTask() async {
    final result = await Navigator.pushNamed(context, '/create-task');
    if (result is Task) {
      // DIP VIOLATION: Direct notification usage
      await _notificationSender.sendNotification(
        'in_app',
        _userManager.currentUser!.id,
        'New task created successfully!',
        {'task_id': result.id},
      );
      _loadTasks();
    }
  }
  
  // More business logic in UI (SRP violation)
  Future<void> _logout() async {
    try {
      // DIP VIOLATION: Direct user manager access
      await _userManager.logout();
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      // Duplicated error handling pattern
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
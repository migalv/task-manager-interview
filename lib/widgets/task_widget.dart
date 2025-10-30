import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/user_manager.dart';
import '../services/notification_sender.dart';

class TaskWidget extends StatefulWidget {
  final Task task;
  final VoidCallback? onTaskUpdated;

  const TaskWidget({Key? key, required this.task, this.onTaskUpdated})
    : super(key: key);

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  final UserManager _userManager = UserManager();
  final NotificationSender _notificationSender = NotificationSender();

  late Task _currentTask;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task header with status
            Row(
              children: [
                Expanded(
                  child: Text(
                    _currentTask.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: _currentTask.status == TaskStatus.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                _buildPriorityChip(),
                const SizedBox(width: 8),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 8),

            // Task description
            Text(
              _currentTask.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),

            // Due date and overdue status
            if (_currentTask.dueDate != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: _isOverdue() ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(_currentTask.dueDate!)}',
                    style: TextStyle(
                      color: _isOverdue() ? Colors.red : Colors.grey[600],
                      fontWeight: _isOverdue()
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (_isOverdue()) ...[
                    const SizedBox(width: 8),
                    const Text(
                      'OVERDUE',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Action buttons
            Row(
              children: [
                if (_currentTask.status != TaskStatus.completed)
                  ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _updateTaskStatus(TaskStatus.completed),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Complete'),
                  ),
                const SizedBox(width: 8),
                if (_currentTask.status == TaskStatus.pending)
                  ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _updateTaskStatus(TaskStatus.inProgress),
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Start'),
                  ),
                const Spacer(),
                IconButton(
                  onPressed: _isLoading ? null : _deleteTask,
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),

            if (_isLoading) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip() {
    Color color;
    String label;

    switch (_currentTask.priority) {
      case TaskPriority.low:
        color = Colors.green;
        label = 'Low';
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        label = 'Medium';
        break;
      case TaskPriority.high:
        color = Colors.red;
        label = 'High';
        break;
      case TaskPriority.urgent:
        color = Colors.purple;
        label = 'Urgent';
        break;
    }

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.2),
      side: BorderSide(color: color),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    String label;
    IconData icon;

    switch (_currentTask.status) {
      case TaskStatus.pending:
        color = Colors.grey;
        label = 'Pending';
        icon = Icons.pending;
        break;
      case TaskStatus.inProgress:
        color = Colors.blue;
        label = 'In Progress';
        icon = Icons.refresh;
        break;
      case TaskStatus.completed:
        color = Colors.green;
        label = 'Completed';
        icon = Icons.check_circle;
        break;
      case TaskStatus.cancelled:
        color = Colors.red;
        label = 'Cancelled';
        icon = Icons.cancel;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  bool _isOverdue() {
    if (_currentTask.dueDate == null) return false;
    return DateTime.now().isAfter(_currentTask.dueDate!) &&
        _currentTask.status != TaskStatus.completed;
  }

  Future<void> _updateTaskStatus(TaskStatus newStatus) async {
    if (_userManager.currentUser == null) {
      _showError('You must be logged in to update tasks');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      _currentTask = _currentTask.copyWith(status: newStatus);

      String message;
      switch (newStatus) {
        case TaskStatus.completed:
          message = 'Task "${_currentTask.title}" completed!';
          break;
        case TaskStatus.inProgress:
          message = 'Task "${_currentTask.title}" started!';
          break;
        default:
          message = 'Task "${_currentTask.title}" updated!';
      }

      await _notificationSender.sendNotification(
        'in_app',
        _userManager.currentUser!.id,
        message,
        {'task_id': _currentTask.id},
      );

      widget.onTaskUpdated?.call();
    } catch (e) {
      _showError('Failed to update task: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTask() async {
    if (_userManager.currentUser == null) {
      _showError('You must be logged in to delete tasks');
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete "${_currentTask.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      await _notificationSender.sendNotification(
        'in_app',
        _userManager.currentUser!.id,
        'Task "${_currentTask.title}" deleted',
        {'task_id': _currentTask.id},
      );

      widget.onTaskUpdated?.call();
    } catch (e) {
      _showError('Failed to delete task: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

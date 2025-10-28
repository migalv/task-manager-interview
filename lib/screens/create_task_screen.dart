import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/user_manager.dart';
import '../services/notification_sender.dart';

// VIOLATES Dependency Inversion Principle
// More concrete dependencies and duplicated code patterns
class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // DIP VIOLATIONS: More direct concrete class dependencies
  final UserManager _userManager = UserManager();
  final NotificationSender _notificationSender = NotificationSender();

  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        actions: [
          IconButton(onPressed: _saveTask, icon: const Icon(Icons.save)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Title field with duplicated validation
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validateTitle(value),
              ),
              const SizedBox(height: 16),
              // Description field with duplicated validation
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => _validateDescription(value),
              ),
              const SizedBox(height: 16),
              // Priority dropdown
              DropdownButtonFormField<TaskPriority>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(_getPriorityDisplayName(priority)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Due date picker
              InkWell(
                onTap: _selectDueDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDueDate != null
                        ? DateFormat('MMM dd, yyyy').format(_selectedDueDate!)
                        : 'No due date selected',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _saveTask,
                  child: const Text('Create Task'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // DUPLICATED validation logic from Task model and other places
  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title cannot be empty';
    }
    if (value.length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (value.length > 100) {
      return 'Title cannot exceed 100 characters';
    }
    return null;
  }

  // DUPLICATED validation logic
  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description cannot be empty';
    }
    if (value.length < 10) {
      return 'Description must be at least 10 characters';
    }
    if (value.length > 500) {
      return 'Description cannot exceed 500 characters';
    }
    return null;
  }

  // Duplicated priority display logic (could be elsewhere too)
  String _getPriorityDisplayName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low Priority';
      case TaskPriority.medium:
        return 'Medium Priority';
      case TaskPriority.high:
        return 'High Priority';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // DIP VIOLATION: Direct access to concrete UserManager
    if (_userManager.currentUser == null) {
      _showError('You must be logged in to create tasks');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // More duplicated validation (already done in form validator)
      final title = _titleController.text;
      final description = _descriptionController.text;

      if (title.isEmpty || title.length < 3) {
        _showError('Invalid title');
        return;
      }
      if (description.isEmpty || description.length < 10) {
        _showError('Invalid description');
        return;
      }

      // Create task - this should use a proper service/repository pattern
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        status: TaskStatus.pending,
        priority: _selectedPriority,
        assignedUserId: _userManager.currentUser!.id,
        createdAt: DateTime.now(),
        dueDate: _selectedDueDate,
      );

      // Simulate API call with duplicated error handling pattern
      await Future.delayed(const Duration(seconds: 1));

      // DIP VIOLATION: Direct notification service usage
      await _notificationSender.sendNotification(
        'push',
        _userManager.currentUser!.id,
        'Task "${task.title}" created successfully',
        {'task_id': task.id},
      );

      if (mounted) {
        Navigator.pop(context, task);
      }
    } catch (e) {
      _showError('Failed to create task: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Duplicated error handling pattern
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

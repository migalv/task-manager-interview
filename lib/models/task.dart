enum TaskStatus { pending, inProgress, completed, cancelled }

enum TaskPriority { low, medium, high, urgent }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String assignedUserId;
  final DateTime createdAt;
  final DateTime? dueDate;
  final List<String> tags;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.assignedUserId,
    required this.createdAt,
    this.dueDate,
    this.tags = const [],
  });

  bool isOverdue() {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) && status != TaskStatus.completed;
  }

  static String? validateTitle(String title) {
    if (title.isEmpty) {
      return 'Title cannot be empty';
    }
    if (title.length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (title.length > 100) {
      return 'Title cannot exceed 100 characters';
    }
    return null;
  }

  static String? validateDescription(String description) {
    if (description.isEmpty) {
      return 'Description cannot be empty';
    }
    if (description.length < 10) {
      return 'Description must be at least 10 characters';
    }
    if (description.length > 500) {
      return 'Description cannot exceed 500 characters';
    }
    return null;
  }

  Task copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assignedUserId,
    DateTime? dueDate,
    List<String>? tags,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
    );
  }
}

# Task Manager App

A Flutter task management application for code review and improvement.

## Overview

This is a Flutter project that implements a basic task management system. Your objective is to review the codebase, identify areas for improvement, and implement better software engineering practices.

## Getting Started

### Prerequisites
- Flutter SDK
- Dart SDK
- Your preferred IDE (VS Code, Android Studio, etc.)

### Setup
```bash
# Navigate to the project directory
cd task_manager_interview_clean

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── user.dart            # User model and hierarchy
│   └── task.dart            # Task model
├── interfaces/
│   └── user_operations.dart # User operations interface
├── services/
│   ├── user_manager.dart    # User management service
│   └── notification_sender.dart # Notification service
├── screens/
│   ├── login_screen.dart    # Login interface
│   ├── home_screen.dart     # Main task list view
│   └── create_task_screen.dart # Task creation form
└── widgets/
    └── task_widget.dart     # Task display component
```

## Your Task

Please review this codebase and:

1. **Identify** code quality issues and areas for improvement
2. **Document** your findings with specific examples
3. **Prioritize** which issues should be addressed first
4. **Implement** improvements for the most critical issues
5. **Explain** your reasoning for the changes you make

## Focus Areas

Consider reviewing for:
- Code organization and responsibility separation
- Extensibility and maintainability
- Code duplication and reusability
- Dependency management and testability
- Adherence to software engineering best practices

## App Features

The application includes:
- User authentication (use any email/password combination)
- Task list display with sample data
- Task creation functionality
- Basic user management
- Priority-based task organization

## Testing

```bash
# Run tests (if any are implemented)
flutter test
```

## Notes

- The app is functional but may have architectural and code quality improvements that could be made
- Feel free to refactor, add tests, or implement additional features as you see fit
- Consider scalability and maintainability in your solutions
# Development Guidelines for Transport Scolaire App

## 🎯 Project Overview

This document outlines the development standards, practices, and conventions to ensure consistency across all feature teams working on the Transport Scolaire Flutter application.

---

## 🏗️ Project Architecture

### Feature-First Architecture
- Each feature corresponds to a backend microservice
- Features are completely isolated with their own:
  - Data layer (`data/`)
  - Models (`models/`)
  - Presentation layer (`presentation/`)
  - Documentation (`README.md`)

### Core Layer Responsibilities
- **api/**: Centralized HTTP client with JWT token management
- **constants/**: Shared application constants
- **errors/**: Global error handling and custom exceptions
- **theme/**: Application-wide theming
- **utils/**: Shared utility functions
- **widgets/**: Reusable UI components

---

## 📐 Development Standards

### 1. Code Style
- Follow Dart/Flutter official style guide
- Use descriptive variable and method names
- Maintain consistent indentation (2 spaces)
- Write comprehensive documentation comments for public APIs
- Follow the `lowerCamelCase` naming convention for methods and variables
- Use `UpperCamelCase` for class names
- Use `snake_case` for file and directory names

### 2. File Structure
```
lib/features/[feature_name]/
├── data/
│   ├── [feature_name]_api.dart
│   └── [feature_name]_repository.dart
├── models/
│   └── [model_name]_model.dart
├── presentation/
│   ├── screens/
│   │   └── [screen_name]_screen.dart
│   └── widgets/
│       └── [widget_name]_widget.dart
└── README.md
```

### 3. Naming Conventions
- **API Files**: `[feature_name]_api.dart` (e.g., `bus_api.dart`)
- **Repository Files**: `[feature_name]_repository.dart` (e.g., `bus_repository.dart`)
- **Model Files**: `[entity_name]_model.dart` (e.g., `bus_model.dart`)
- **Screen Files**: `[screen_name]_screen.dart` (e.g., `bus_list_screen.dart`)
- **Widget Files**: `[widget_name]_widget.dart` (e.g., `bus_card_widget.dart`)

---

## 🧱 Implementation Guidelines

### 1. Data Layer Standards
- All API calls must go through the central API client from `core/api/api_client.dart`
- Implement proper error handling using the core error system
- Create a repository class that abstracts API calls and provides clean methods to the presentation layer
- Handle offline scenarios with appropriate caching strategies
- Use DTOs (Data Transfer Objects) if data transformation is needed

### 2. Model Standards
- Implement `fromJson` and `toJson` methods for all data models
- Add validation methods for data integrity
- Use immutable data classes when possible
- Handle nullable fields appropriately
- Include computed properties for derived data

### 3. State Management
- Use the same state management approach across all features (Bloc, Provider, or Riverpod - team decision)
- Follow consistent patterns for loading, success, error states
- Implement proper error handling in state management
- Handle authentication state changes consistently

### 4. UI/UX Standards
- Use core theme for consistent styling
- Implement responsive design for different screen sizes
- Follow accessibility standards
- Use core widgets where possible to maintain consistency
- Implement loading states and error states consistently

---

## 🔗 API Integration Standards

### 1. Authentication
- All API calls must use the core API client (`lib/core/api/api_client.dart`) to ensure credentials are included automatically
- The API client automatically attaches JWT tokens to all requests using flutter_secure_storage
- Handle 401 Unauthorized responses globally
- Implement automatic token refresh if needed
- Follow proper authentication state management

### 2. Error Handling
- Handle common HTTP error codes consistently:
  - 400: Bad Request - Display validation errors
  - 401: Unauthorized - Redirect to login
  - 403: Forbidden - Display permission error
  - 404: Not Found - Handle gracefully
  - 500: Server Error - Display user-friendly message
- Log errors appropriately
- Provide meaningful error messages to users

### 3. Response Handling
- Standardize response format handling
- Implement proper timeout configurations
- Handle network connectivity issues
- Implement retry mechanisms for failed requests

---


## 🔄 Collaboration Guidelines

### 1. Git Workflow
- Use feature branches named as `feature/[feature-name]`
- Follow the pattern `feature/auth-login`, `feature/bus-management`
- Create pull requests for code review before merging to main
- Use conventional commits:
  - `feat:` for new features
  - `fix:` for bug fixes
  - `docs:` for documentation updates
  - `style:` for formatting changes
  - `refactor:` for code restructuring
  - `chore:` for maintenance tasks

### 2. Code Reviews
- All code must be reviewed by at least one other team member
- Focus on code quality, performance, and adherence to standards
- Ensure documentation and comments are adequate
- Test that code works as expected

### 3. Communication
- Use issue tracking for all feature development
- Update progress regularly in project management tools
- Schedule regular sync-ups between feature teams
- Maintain shared documentation for API contracts

---

## 🔐 Security Guidelines

### 1. Data Security
- Use flutter_secure_storage for sensitive data
- Never store sensitive information in plain text
- Validate data received from APIs
- Implement proper permissions handling

### 2. API Security
- Use HTTPS for all API communications
- Implement proper JWT token handling
- Protect against common vulnerabilities
- Validate input parameters

---

## 🚀 Deployment Considerations

### 1. Configuration Management
- Use environment variables for API URLs
- Different configurations for development, staging, and production
- Secure handling of API keys and secrets

### 2. Performance
- Optimize images and assets
- Implement proper caching strategies
- Handle memory usage efficiently
- Monitor app performance metrics

---

## 🆘 Support and Maintenance

### 1. Documentation
- Keep feature README.md files updated with implementation status
- Document API contracts and data structures
- Maintain troubleshooting guides
- Update architecture documentation as needed

### 2. Monitoring
- Implement proper logging for debugging
- Monitor app crashes and errors
- Track user interactions and performance metrics
- Set up alerts for critical errors

---

## 📞 Contact and Support

- Use shared Slack channels for communication
- Schedule weekly cross-team syncs
- Maintain shared documentation and API contract documents
- Escalation process for cross-feature dependencies
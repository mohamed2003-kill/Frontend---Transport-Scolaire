# Transport Scolaire App

This is a Flutter application following the Feature-First (Modular) Architecture to mirror the School Transport Microservices Backend.

## Architecture Overview

This project follows the architecture described in the School Transport Microservices Architecture (v2), where each feature module corresponds to a backend microservice:

### High-Level Directory Structure

```
lib/
├── main.dart                  # Entry point
├── app.dart                   # Material App configuration, global providers
├── core/                      # Shared logic across all microservices
│   ├── api/                   # Base HTTP Client (Dio/Http) - Acts as your API Gateway Client
│   ├── constants/             # App-wide constants (colors, strings)
│   ├── errors/                # Global error handling
│   ├── theme/                 # App UI Theme
│   ├── utils/                 # Helper functions (date formatting, validators)
│   └── widgets/               # Reusable UI components (buttons, input fields)
│
└── features/                  # EACH FOLDER HERE REPRESENTS A MICROSERVICE
    ├── auth/                  # Matches "Microservice Authentification"
    ├── bus_management/        # Matches "Microservice Gestion des Bus"
    ├── student_management/    # Matches "Microservice Gestion des Élèves"
    ├── tracking/              # Matches "Microservice Localisation et GPS"
    ├── notifications/         # Matches "Microservice Notifications"
    ├── planning/              # Matches "Microservice Planification"
    └── grouping/              # Matches "Microservice Groupement d'Élèves"
```

## Core Components

### API Gateway Client
The `ApiClient` in `core/api/` handles communication with your backend API Gateway, including JWT token management for authentication.

### Feature Modules
Each feature module follows the pattern:
- `data/`: API calls and repository implementations
- `models/`: Data models matching your backend JSON
- `presentation/`: UI screens and state management

## Getting Started

1. Make sure your backend API Gateway is running
2. Update the `_baseUrl` in `lib/core/api/api_client.dart` with your API Gateway URL
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application

## Dependencies

- `dio`: HTTP client for API communication
- `flutter_secure_storage`: Secure storage for JWT tokens and user data
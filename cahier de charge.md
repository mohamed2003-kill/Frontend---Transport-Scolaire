Based on the **School Transport Microservices Architecture (v2)** described in the second PDF, the best approach for your Flutter application is a **Feature-First (or Modular) Architecture**.

In this structure, you don't group files by type (controllers, views, models), but by **feature**. Each feature in Flutter will act as a mirror to one of your backend microservices. This makes the codebase scalable and allows different developers to work on "Buses" and "Students" simultaneously without conflict.

Here is the recommended project structure:

### High-Level Directory Structure

```text
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
    └── grouping/              # Matches "Microservice Groupement d’Élèves"
```

---

### Detailed Breakdown by Microservice

Here is how each folder corresponds to the definitions in your PDF, including the specific API endpoints mentioned.

#### 1. Core (The Glue)
This handles the **API Gateway** logic (Service 8 in your PDF).
*   **`core/api/api_client.dart`**: configured with the Base URL of your API Gateway. It handles token injection (JWT) for every request.

#### 2. Features (The Microservices)

Each feature folder generally follows this internal structure:
*   **`data/`**: Repositories and Data Sources (API calls).
*   **`models/`**: Dart classes matching your JSON.
*   **`presentation/`**: Screens (UI) and State Management (Bloc/Riverpod/Provider).

---

#### A. Feature: Auth (`features/auth`)
*Matches Service 7: Authentification et Sécurité*

*   **`data/auth_api.dart`**: Implements `POST /auth/login`, `POST /auth/register`, `GET /auth/roles`.
*   **`presentation/screens/`**: `LoginScreen`, `RegisterScreen`.
*   **Responsibility**: storage of the JWT token securely (using `flutter_secure_storage`).

#### B. Feature: Bus Management (`features/bus_management`)
*Matches Service 1: Gestion des Bus*

*   **`data/bus_api.dart`**:
    *   `fetchBuses()` -> `GET /buses`
    *   `addBus()` -> `POST /buses`
*   **`models/bus_model.dart`**: Properties: `immatriculation`, `capacite`, `chauffeur`.
*   **`presentation/`**:
    *   `BusListScreen` (for Admin).
    *   `BusDetailScreen`.

#### C. Feature: Student Management (`features/student_management`)
*Matches Service 2: Gestion des Élèves*

*   **`data/student_api.dart`**:
    *   `getStudents()` -> `GET /students`
    *   `updateStudent()` -> `PUT /students/{id}`
*   **`models/student_model.dart`**: Properties: `domicile_gps`, `classe`, etc.
*   **`presentation/`**:
    *   `StudentProfileScreen`.
    *   `StudentListScreen` (Admin/Driver view).

#### D. Feature: Tracking (`features/tracking`)
*Matches Service 3: Localisation et GPS*

*   **`data/tracking_api.dart`**:
    *   `sendLocation()` -> `POST /locations/student` (used if app is on parent's phone).
    *   `getBusLocation()` -> `GET /locations/{entity_id}`.
*   **`presentation/widgets/`**: `LiveMapWidget` (Uses Google Maps or Mapbox).
*   **Logic**: This module will contain the WebSocket or Polling logic to update the map in real-time.

#### E. Feature: Notifications (`features/notifications`)
*Matches Service 4: Notifications*

*   **`data/notification_api.dart`**:
    *   `getHistory()` -> `GET /notifications/history/{user_id}`.
    *   `registerDevice()` -> Sending FCM token to backend.
*   **`presentation/`**: `NotificationCenterScreen`.
*   **Services**: A background service handler (Firebase Messaging) to handle "Push 10 mins before arrival".

#### F. Feature: Planning & Routes (`features/planning`)
*Matches Service 5: Planification et Trajectoires*

*   **`data/planning_api.dart`**:
    *   `getOptimalRoute()` -> `GET /routes/optimal`.
    *   `getETA()` -> `GET /routes/eta/{student_id}`.
*   **`presentation/`**: `RouteViewScreen` (Shows the driver the order of stops).

#### G. Feature: Grouping (`features/grouping`)
*Matches Service 6: Groupement d’Élèves*

*   *Note: This is likely an Admin-only feature.*
*   **`data/grouping_api.dart`**:
    *   `generateGroups()` -> `POST /groups/generate`.
    *   `getGroups()` -> `GET /groups`.
*   **`presentation/`**: `GroupConfigurationScreen` (Interface to set parameter "X" size mentioned in PDF).

---

### Example Implementation: Bus Module
Here is how the file structure looks for just the Bus Microservice part:

```dart
// lib/features/bus_management/models/bus.dart
class Bus {
  final String id;
  final String plateNumber;
  final int capacity;
  // Constructor and fromJson...
}

// lib/features/bus_management/data/bus_repository.dart
class BusRepository {
  final ApiClient _client; // From Core
  
  Future<List<Bus>> getAllBuses() async {
    final response = await _client.get('/buses'); // Hits Service 1 via Gateway
    return (response.data as List).map((e) => Bus.fromJson(e)).toList();
  }
}

// lib/features/bus_management/presentation/bus_list_screen.dart
class BusListScreen extends StatelessWidget {
  // Uses BusRepository to fetch data and display ListView
}
```

### Summary of Benefits
1.  **Isolation**: If the "Planning" microservice is down or changing logic, you only touch the `features/planning` folder.
2.  **Role-Based Access**: You can easily hide the `features/bus_management` and `features/grouping` folders from the UI if the logged-in user is a "Parent" (Service 7 roles).
3.  **Parallel Development**: One Flutter dev can build the Map (Tracking) while another builds the Profile (Student).
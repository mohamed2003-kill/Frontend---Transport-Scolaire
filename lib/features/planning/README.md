# OptTrajFlutter - School Transport Frontend Application

This Flutter application provides a user interface for the school transport system, interacting with the OptTrajMS backend microservice to display optimal routes, estimated times of arrival (ETA), and manage bus circuits.

## 1. Project Structure

```
features/
├── planning/
│   └── main.dart
├── pubspec.yaml
├── README.md
└── ... (other Flutter project files)
```

## 2. Features

*   **Map Integration**: Uses OSRM data for map integration.
*   **ETA Display**: Shows estimated time of arrival for selected students.
*   **Route Generation**: Allows administrators to trigger route generation for morning and evening circuits.
*   **Circuit View**: Provides a simple interface for viewing morning and evening bus circuits.

## 3. Setup and Running the Project

### 3.1. Prerequisites

*   Flutter SDK (latest stable version recommended)
*   Android Studio or VS Code with Flutter and Dart plugins
*   An Android or iOS emulator/device for testing




### 3.3. Backend Configuration

Ensure the OptTrajMS backend microservice is running and accessible. Update the base URL for API calls in your Flutter application (e.g., in a `constants.dart` file or similar) to point to your backend instance:

```dart
const String BASE_URL = 'http://172.30.80.11:31013'; // Or your backend's public URL
```

### 3.4. Installing Dependencies

1.  Navigate to the `opttrajflutter` directory:

    ```bash
    cd opttrajflutter
    ```

2.  Get Flutter packages:

    ```bash
    flutter pub get
    ```

### 3.5. Running the Application

1.  Ensure an emulator is running or a device is connected.
2.  Run the application:

    ```bash
    flutter run
    ```

## 4. API Communication

The frontend communicates with the OptTrajMS backend using the `http` package to consume the following APIs:

*   `GET /routes/optimal`
*   `GET /routes/eta/{student_id}`
*   `POST /routes/generate`

## 5. Mock Data

Mock data for testing (e.g., sample student locations and bus routes) can be implemented within the Flutter application to simulate API responses during development or when the backend is not available.

## 6. Technologies Used

*   **Flutter**: UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
*   **OSRM**: For routing and ETA calculations.
*   **http**: A composable, Future-based library for making HTTP requests.

## 7. UI/UX and Platform Support

The application is designed with an intuitive and fluid interface, supporting both Android and iOS platforms.


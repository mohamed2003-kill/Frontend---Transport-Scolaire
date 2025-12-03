
---

### 1. `lib/features/auth/README.md`
**Microservice:** Authentification et Sécurité

#### 🏁 Goal
Manage user sessions, security tokens, and role-based access control (RBAC).

#### 🔗 API Endpoints to Consume
*   `POST /auth/login` - Authenticate user & receive JWT.
*   `POST /auth/register` - Register a new parent or driver.
*   `GET /auth/roles/{user_id}` - Fetch specific permissions.

#### 📦 Data Models (`models/`)
*   **User**: `id`, `username`, `email`, `role` (Admin, Chauffeur, Parent).
*   **AuthResponse**: `token`, `refreshToken`, `expiry`.

#### 📱 UI Components (`presentation/`)
1.  **LoginScreen**:
    *   Fields: Email, Password.
    *   Logic: On success, save JWT to `FlutterSecureStorage` and redirect to Home.
2.  **RegisterScreen**:
    *   Fields: Name, Email, Role selection, Password confirmation.
3.  **AuthGuard (Utility)**:
    *   A wrapper widget that checks if a user is logged in before showing protected routes.

#### 💡 Implementation Tips
*   Use a **Interceptor** in `core/api` to attach the JWT token to every request automatically.
*   Handle `401 Unauthorized` errors globally to redirect users back to Login.

---

### 2. `lib/features/bus_management/README.md`
**Microservice:** Gestion des Bus

#### 🏁 Goal
Allow Administrators to manage the fleet and Drivers to view their assigned vehicle details.

#### 🔗 API Endpoints to Consume
*   `GET /buses` - List all buses.
*   `POST /buses` - Add a new bus.
*   `PUT /buses/{id}` - Update bus details (e.g., change driver).
*   `DELETE /buses/{id}` - Remove a bus.

#### 📦 Data Models (`models/`)
*   **Bus**: `id`, `plateNumber`, `capacity` (int), `driverId`, `status` (Active, Maintenance).

#### 📱 UI Components (`presentation/`)
1.  **BusListScreen (Admin)**:
    *   ListView with search/filter.
    *   Floating Action Button (FAB) to add a bus.
2.  **BusDetailScreen**:
    *   Display info.
    *   Edit form for Admins.
3.  **MyBusWidget (Driver)**:
    *   A card on the dashboard showing the driver their current assigned vehicle.

---

### 3. `lib/features/student_management/README.md`
**Microservice:** Gestion des Élèves

#### 🏁 Goal
Manage student data and link them to their physical addresses for route calculation.

#### 🔗 API Endpoints to Consume
*   `GET /students` - List students.
*   `POST /students` - Register a child.
*   `PUT /students/{id}` - Update info or address.

#### 📦 Data Models (`models/`)
*   **Student**: `id`, `fullName`, `grade/class`, `parentId`, `address` (Object).
*   **Address**: `street`, `city`, `latitude`, `longitude`.

#### 📱 UI Components (`presentation/`)
1.  **StudentListScreen**:
    *   For Admins: Full list.
    *   For Parents: Only their children.
2.  **StudentProfileForm**:
    *   **Critical**: Must include a location picker (Google Maps pin drop) to capture `latitude` and `longitude` precisely.
3.  **StudentCard**:
    *   Summary widget showing Name, Class, and assigned Bus Route.

---

### 4. `lib/features/tracking/README.md`
**Microservice:** Localisation et GPS

#### 🏁 Goal
Real-time visualization of buses and students for parents and admins.

#### 🔗 API Endpoints to Consume
*   `POST /locations/bus` - (Driver App) Send current GPS coordinates.
*   `GET /locations/{entity_id}` - Get last known position.
*   **WebSocket/Stream**: Likely needed for live updates.

#### 📦 Data Models (`models/`)
*   **LocationUpdate**: `entityId`, `type` (Bus/Student), `lat`, `lng`, `timestamp`.

#### 📱 UI Components (`presentation/`)
1.  **LiveMapScreen**:
    *   Uses `google_maps_flutter` or `flutter_map`.
    *   **Parents**: Shows their child's bus moving in real-time.
    *   **Admins**: Shows all buses on one map.
2.  **DriverTrackerService** (Background Logic):
    *   A background service (using `flutter_background_service`) that grabs the phone's GPS and `POST`s it to the API every 30 seconds while driving.

---

### 5. `lib/features/notifications/README.md`
**Microservice:** Notifications

#### 🏁 Goal
Alert parents about bus arrivals, delays, or emergencies.

#### 🔗 API Endpoints to Consume
*   `POST /notifications/send` - (Admin) Broadcast a message.
*   `GET /notifications/history/{user_id}` - View past alerts.

#### 📦 Data Models (`models/`)
*   **NotificationItem**: `id`, `title`, `body`, `timestamp`, `isRead`.

#### 📱 UI Components (`presentation/`)
1.  **NotificationBell**:
    *   AppBar icon with a badge counter for unread messages.
2.  **NotificationHistoryScreen**:
    *   List of past messages (e.g., "Bus is 10 mins late").
3.  **PushHandler (Logic)**:
    *   Integration with **Firebase Cloud Messaging (FCM)** to handle incoming push notifications when the app is closed.

---

### 6. `lib/features/planning/README.md`
**Microservice:** Planification et Trajectoires

#### 🏁 Goal
Calculate and display the optimal pickup/drop-off sequence and ETA.

#### 🔗 API Endpoints to Consume
*   `GET /routes/optimal` - Fetch the calculated path.
*   `GET /routes/eta/{student_id}` - specific ETA for a child.
*   `POST /routes/generate` - Trigger a recalculation (Admin).

#### 📦 Data Models (`models/`)
*   **Route**: `id`, `busId`, `waypoints` (List of LatLng), `totalDuration`.
*   **Stop**: `studentId`, `location`, `estimatedTime`.

#### 📱 UI Components (`presentation/`)
1.  **RouteViewScreen (Driver)**:
    *   An ordered list of stops: "Next stop: Sarah (5 mins)".
    *   "Start Navigation" button launching Waze/Google Maps.
2.  **ParentEtaWidget**:
    *   Simple display: "Bus arriving at [08:15 AM]".

---

### 7. `lib/features/grouping/README.md`
**Microservice:** Groupement d’Élèves

#### 🏁 Goal
Admin tool to configure how students are clustered (e.g., by neighborhood) to optimize bus filling.

#### 🔗 API Endpoints to Consume
*   `POST /groups/generate` - Run the grouping algorithm.
*   `GET /groups` - View results.
*   `PUT /groups/{id}` - Manually move a student to a different group.

#### 📦 Data Models (`models/`)
*   **Group**: `id`, `name`, `studentCount`, `maxSize`.
*   **GroupConfig**: `maxDistance`, `maxStudentsPerGroup`.

#### 📱 UI Components (`presentation/`)
1.  **GroupingConfigScreen**:
    *   Sliders/Inputs to set "Max Group Size" (Parameter X from PDF).
    *   Button: "Generate Groups".
2.  **GroupResultList**:
    *   Expandable list showing which students are in which group.
    *   Drag-and-drop (if possible) to move students between groups manually.

---

### Summary of dependencies to add to `pubspec.yaml`
To implement these features, your team will need these packages:

*   **Core/Auth**: `dio`, `flutter_secure_storage`, `get_it`, `provider`/`flutter_bloc`.
*   **Tracking**: `google_maps_flutter`, `geolocator`.
*   **Notifications**: `firebase_messaging`, `flutter_local_notifications`.
*   **General UI**: `intl` (for date formatting), `go_router` (for navigation).
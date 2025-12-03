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

### 📋 Detailed Implementation Steps

#### 1. Data Layer (`data/`)
- **TrackingApi**:
  - Create methods for location updates (`sendLocation`, `getLocation`)
  - Implement WebSocket connection for live updates
  - Handle connection errors and reconnection logic
  - Add methods for batch location updates
  - Implement proper error handling for location services failures

- **TrackingRepository**:
  - Create a repository class that manages location data
  - Implement caching of recent locations
  - Handle offline location data storage and sync
  - Manage WebSocket connection state
  - Add methods to calculate distance and travel time estimates

#### 2. Models (`models/`)
- **LocationUpdate**:
  - Implement `fromJson` and `toJson` methods
  - Add validation methods for coordinate ranges
  - Create methods to calculate distance to other locations
  - Add computed properties for speed and direction if needed
  - Include accuracy information if available

- **LocationHistory**:
  - Create a model to hold historical location data
  - Add methods to analyze movement patterns
  - Include time-based filtering capabilities

#### 3. Presentation Layer (`presentation/`)
- **LiveMapScreen**:
  - Integrate with Google Maps or similar mapping service
  - Implement custom markers for buses and students
  - Add route visualization for bus paths
  - Include zoom controls and map type selection
  - Implement real-time updates from WebSocket
  - Add legend and information overlays
  - Create role-based filtering (show only child's bus for parents)
  - Add historical route playback functionality
  - Include distance and time indicators

- **State Management**:
  - Use Bloc, Provider, or Riverpod for tracking state
  - Handle WebSocket connection states (connecting, connected, disconnected)
  - Manage multiple marker positions efficiently
  - Handle real-time updates without UI performance issues

#### 4. Background Services (`presentation/`)
- **DriverTrackerService**:
  - Implement background location tracking using appropriate plugins
  - Handle location permissions and user notifications
  - Optimize battery usage with location sampling strategies
  - Handle app in background/foreground states
  - Implement retry logic for failed location uploads
  - Add geofencing capabilities if needed
  - Implement location filtering to avoid unnecessary updates

#### 5. Performance Considerations
- Implement efficient marker clustering for many vehicles
- Use debouncing for location updates to prevent excessive API calls
- Optimize map rendering for smooth real-time updates
- Implement proper memory management for location data
- Use efficient data structures for location history

#### 6. Permissions and Security
- Handle location permissions properly for different platforms
- Implement secure transmission of location data
- Add privacy controls for sensitive location information
- Include user consent management for location tracking
- Handle permissions changes during app runtime

#### 7. Platform-Specific Considerations
- Implement proper background location handling for Android and iOS
- Handle different platform location services (GPS, network, etc.)
- Address platform-specific battery optimization settings
- Handle location services availability and accuracy


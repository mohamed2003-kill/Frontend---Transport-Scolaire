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

### 📋 Detailed Implementation Steps

#### 1. Data Layer (`data/`)
- **PlanningApi**:
  - Create methods matching the API endpoints (`getOptimalRoute`, `getEta`, `generateRoute`)
  - Implement query parameters for route customization (bus ID, date, etc.)
  - Handle different HTTP status codes with appropriate error messages
  - Add methods for route optimization parameters
  - Implement proper error handling for route calculation failures

- **PlanningRepository**:
  - Create a repository class that uses PlanningApi
  - Implement caching mechanism for route data
  - Handle offline route data storage
  - Add methods for route validation and preprocessing
  - Implement synchronization between route calculations and student locations

#### 2. Models (`models/`)
- **Route**:
  - Implement `fromJson` and `toJson` methods
  - Add validation methods for route integrity (valid waypoints, duration)
  - Create computed properties for total distance and stops count
  - Add methods to calculate intermediate ETAs
  - Include route status (active, completed, cancelled)

- **Stop**:
  - Implement `fromJson` and `toJson` methods
  - Add validation methods for time and location data
  - Create computed properties for stop order in route
  - Add methods to check if stop is completed
  - Include special instructions for each stop

- **RouteFilter**:
  - Create a model for filtering routes (by bus, date, etc.)
  - Add methods to serialize filter parameters

#### 3. Presentation Layer (`presentation/`)
- **RouteViewScreen**:
  - Implement ordered list with visual indicators for next stop
  - Add progress tracking for route completion
  - Include navigation buttons to launch external navigation apps
  - Add confirmation functionality for completed stops
  - Show student information and special instructions at each stop
  - Implement real-time ETA updates
  - Add route summary with total duration and stops
  - Include options to report delays or issues
  - Add emergency contact functionality
  - Implement offline route viewing capability

- **ParentEtaWidget**:
  - Create a simple, clear display of arrival time
  - Add real-time updates for ETA changes
  - Include visual indicators for bus status (on time, delayed, etc.)
  - Show progress along the route
  - Add option to view detailed route information
  - Include refresh mechanism for ETA updates

- **State Management**:
  - Use Bloc, Provider, or Riverpod for planning state
  - Handle loading, success, and error states for route calculations
  - Manage route progression and stop completion states
  - Track real-time ETA updates

#### 4. Navigation Integration
- Integrate with Google Maps, Waze, or other navigation services
  - Implement deep linking to navigation apps with route information
  - Handle navigation app availability checks
  - Add fallback options if primary navigation app is not available
- Provide turn-by-turn navigation for drivers
- Include voice guidance capabilities if possible

#### 5. Route Optimization Logic
- Implement business logic for route validation
- Add algorithms for efficient stop ordering
- Handle special cases (student availability, address changes, etc.)
- Implement logic for handling delays and route modifications

#### 6. Real-time Updates
- Implement WebSocket or polling for real-time route status updates
- Handle route changes during execution
- Update ETAs based on actual progress and traffic conditions
- Notify parents of significant delays or route changes

#### 7. Offline Capabilities
- Cache route information for offline access
- Allow basic route viewing without network connection
- Synchronize route status when connection is restored
- Store critical route information locally for driver access

#### 8. UI/UX Considerations
- Design clear visual hierarchy for stop priority
- Implement intuitive swipe gestures for stop confirmation
- Add visual indicators for route progress
- Use appropriate colors and icons for different route states
- Ensure accessibility for all route information


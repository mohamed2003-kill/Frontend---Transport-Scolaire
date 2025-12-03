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

### 📋 Detailed Implementation Steps

#### 1. Data Layer (`data/`)
- **BusApi**:
  - Create methods matching the API endpoints (`getBuses`, `addBus`, `updateBus`, `deleteBus`)
  - Implement pagination for large bus fleets
  - Handle different HTTP status codes with appropriate error messages
  - Add query parameters for filtering and searching

- **BusRepository**:
  - Create a repository class that uses BusApi
  - Implement caching mechanism for bus data
  - Handle offline data with local storage (Hive or SQLite)
  - Add methods for data validation before sending to API

#### 2. Models (`models/`)
- **Bus**:
  - Implement `fromJson` and `toJson` methods
  - Add validation methods for plate number format, capacity limits
  - Create enum for bus status (Active, Maintenance, OutOfService)
  - Add computed properties for bus availability

- **BusFilter**:
  - Create a model for filtering buses (by status, capacity, etc.)
  - Add methods to serialize filter parameters

#### 3. Presentation Layer (`presentation/`)
- **BusListScreen**:
  - Implement pull-to-refresh for latest data
  - Add search functionality with debounced API calls
  - Implement filtering options (by status, capacity)
  - Add loading states and error handling
  - Create responsive grid/list view toggle
  - Add sorting options (by plate number, capacity, status)

- **BusDetailScreen**:
  - Implement form validation for bus details
  - Add driver assignment dropdown with available drivers
  - Show associated students on this bus route
  - Add image upload functionality for bus photo
  - Include maintenance history if available

- **MyBusWidget**:
  - Create a compact view for driver dashboard
  - Show basic vehicle information
  - Add quick access to route details
  - Include status indicator

- **State Management**:
  - Use Bloc, Provider, or Riverpod for bus management state
  - Handle loading, success, and error states
  - Implement form states for create/update operations

#### 4. Business Logic
- Implement validation for bus capacity constraints
- Add business rules for assigning drivers to buses
- Handle business logic for bus status transitions
- Validate plate number format based on local regulations

#### 5. UI/UX Considerations
- Design responsive layout for different screen sizes
- Implement smooth animations for better user experience
- Add accessibility features (screen reader support)
- Use appropriate icons for different bus statuses


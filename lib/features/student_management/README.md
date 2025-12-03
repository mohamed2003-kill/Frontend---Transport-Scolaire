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

### 📋 Detailed Implementation Steps

#### 1. Data Layer (`data/`)
- **StudentApi**:
  - Create methods matching the API endpoints (`getStudents`, `createStudent`, `updateStudent`, `deleteStudent`)
  - Implement pagination and filtering options for student lists
  - Add query parameters for searching by name, class, or parent
  - Handle different HTTP status codes with appropriate error messages

- **StudentRepository**:
  - Create a repository class that uses StudentApi
  - Implement caching mechanism for student data
  - Handle offline data with local storage (Hive or SQLite)
  - Add methods for data validation before sending to API
  - Implement synchronization between local and remote data

#### 2. Models (`models/`)
- **Student**:
  - Implement `fromJson` and `toJson` methods
  - Add validation methods for student information
  - Create computed properties for full address string
  - Add methods to check if student has valid location data
  - Include parent information if needed

- **Address**:
  - Implement `fromJson` and `toJson` methods
  - Add validation methods for coordinates (latitude/longitude ranges)
  - Create method to format address for display
  - Add method to calculate distance to other locations

- **StudentFilter**:
  - Create a model for filtering students (by class, parent, etc.)
  - Add methods to serialize filter parameters

#### 3. Presentation Layer (`presentation/`)
- **StudentListScreen**:
  - Implement role-based filtering (Admin sees all, Parent sees only their children)
  - Add search functionality with debounced API calls
  - Implement pull-to-refresh for latest data
  - Add sorting options (by name, class, etc.)
  - Create responsive grid/list view toggle
  - Add loading states and error handling
  - Implement infinite scrolling for large data sets

- **StudentProfileForm**:
  - Implement comprehensive form validation
  - Add GPS location picker with map integration
  - Include address auto-completion using geocoding
  - Add photo upload functionality for student
  - Include parent contact information fields
  - Add medical information fields if applicable
  - Add emergency contact information

- **StudentCard**:
  - Create a concise information display
  - Show student name, class and current status
  - Include a photo if available
  - Show quick access to bus tracking if applicable
  - Add color coding for different statuses

- **State Management**:
  - Use Bloc, Provider, or Riverpod for student management state
  - Handle loading, success, and error states
  - Implement form states for create/update operations
  - Manage role-based access controls

#### 4. Location Services Integration
- Integrate with Google Maps or other mapping service
- Implement location picker with pin drop functionality
- Add geocoding to convert addresses to coordinates
- Validate coordinate accuracy and precision
- Handle location permissions appropriately

#### 5. Business Logic
- Implement validation for required student information
- Add business rules for student-class assignments
- Handle parent-child relationship management
- Validate address coordinates and location accuracy
- Implement data privacy controls for student information

#### 6. UI/UX Considerations
- Design age-appropriate interface for student information
- Ensure data privacy and security in UI design
- Implement responsive layout for different screen sizes
- Add accessibility features (screen reader support)
- Use appropriate icons and colors for different student statuses


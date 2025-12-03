**Microservice:** Groupement d'Élèves

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

### 📋 Detailed Implementation Steps

#### 1. Data Layer (`data/`)
- **GroupingApi**:
  - Create methods matching the API endpoints (`generateGroups`, `getGroups`, `updateGroup`)
  - Implement query parameters for group filtering and configuration
  - Handle different HTTP status codes with appropriate error messages
  - Add methods for group configuration parameters
  - Implement proper error handling for complex grouping operations
  - Add methods for batch operations (move multiple students at once)

- **GroupingRepository**:
  - Create a repository class that uses GroupingApi
  - Implement caching mechanism for group data
  - Handle offline group data storage
  - Add methods for client-side group validation
  - Implement synchronization between group operations and student data

#### 2. Models (`models/`)
- **Group**:
  - Implement `fromJson` and `toJson` methods
  - Add validation methods for group capacity and constraints
  - Create computed properties for group statistics (avg location, etc.)
  - Add methods to calculate group metrics (density, coverage area)
  - Include group status (active, pending, archived)

- **GroupConfig**:
  - Implement `fromJson` and `toJson` methods
  - Add validation methods for configuration parameters
  - Create computed properties for derived constraints
  - Add methods to validate configuration consistency
  - Include optimization algorithm selection

- **GroupFilter**:
  - Create a model for filtering groups (by date, bus, etc.)
  - Add methods to serialize filter parameters

#### 3. Presentation Layer (`presentation/`)
- **GroupingConfigScreen**:
  - Implement interactive controls for all grouping parameters
  - Add real-time validation for configuration values
  - Include parameter explanations and tooltips
  - Add preset configuration templates
  - Implement preview functionality for expected results
  - Add scheduling options for automatic group generation
  - Include validation of configuration constraints before generation
  - Add export/import functionality for group configurations

- **GroupResultList**:
  - Implement expandable/collapsible group sections
  - Add drag-and-drop functionality for student movement between groups
  - Include search functionality within groups
  - Add bulk selection and operations for students
  - Implement visual indicators for group metrics
  - Add export functionality for group data (CSV, PDF)
  - Include undo functionality for manual changes
  - Implement visual mapping of group locations
  - Add statistics and analytics for each group
  - Include sharing functionality for group assignments

- **State Management**:
  - Use Bloc, Provider, or Riverpod for grouping state
  - Handle loading, success, and error states for generation operations
  - Manage intermediate states during drag-and-drop operations
  - Track manual changes and provide save/cancel functionality

#### 4. Algorithm Implementation Considerations
- Understand and potentially implement client-side preview of grouping algorithm
- Add visualization of grouping constraints (distance, capacity)
- Implement validation of grouping results
- Add options for algorithm configuration
- Handle edge cases where constraints cannot be satisfied

#### 5. Visual Components
- Implement map visualization of student locations and groups
- Add color coding for different groups
- Create interactive charts for group statistics
- Implement visual indicators for group optimization metrics
- Add comparison tools between different grouping scenarios

#### 6. Performance Considerations
- Optimize rendering for large numbers of students and groups
- Implement efficient data structures for drag-and-drop operations
- Add pagination or virtual scrolling for large result sets
- Optimize API calls to avoid overloading the server during manual adjustments

#### 7. Validation and Business Rules
- Implement validation for group capacity constraints
- Add business rules for student grouping (grade levels, special needs)
- Handle conflicts in student assignments
- Validate geographic constraints for group formation
- Ensure privacy and security of student data during grouping

#### 8. UI/UX Considerations
- Design intuitive drag-and-drop interface with clear visual feedback
- Implement responsive design for different screen sizes
- Add accessibility features for different user needs
- Provide clear visual indicators for group constraints
- Include undo/redo functionality for manual changes


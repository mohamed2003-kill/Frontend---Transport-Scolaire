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

### 📋 Detailed Implementation Steps

#### 1. Data Layer (`data/`)
- **AuthApi**:
  - Create methods matching the API endpoints (`login`, `register`, `getRoles`)
  - Implement error handling for different HTTP status codes (401, 403, 500)
  - Return appropriate data models

- **AuthRepository**:
  - Create a repository class that uses AuthApi
  - Implement caching of JWT tokens using flutter_secure_storage
  - Handle token refresh mechanism

#### 2. Models (`models/`)
- **User**:
  - Implement `fromJson` and `toJson` methods
  - Add validation methods for fields
  - Create different constructors for different user types (Admin, Driver, Parent)

- **AuthResponse**:
  - Implement `fromJson` and `toJson` methods
  - Add methods to check token validity
  - Add methods to parse expiration time

#### 3. Presentation Layer (`presentation/`)
- **LoginScreen**:
  - Implement form validation (email format, password strength)
  - Add loading state during API calls
  - Display appropriate error messages
  - Implement "Remember Me" functionality
  - Add forgot password option

- **RegisterScreen**:
  - Implement form validation for all fields
  - Add role selection dropdown/radio buttons
  - Confirm password field validation
  - Add terms and conditions agreement

- **State Management**:
  - Use Bloc, Provider, or Riverpod to manage authentication state
  - Create AuthState class to represent different states (unauthenticated, authenticating, authenticated)
  - Provide methods to login, logout, and check authentication status

#### 4. Utilities
- **Token Manager**:
  - Create a service to handle token storage and retrieval
  - Check token expiration
  - Provide methods to clear tokens on logout

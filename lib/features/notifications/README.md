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

### 📋 Detailed Implementation Steps

#### 1. Data Layer (`data/`)
- **NotificationApi**:
  - Create methods matching the API endpoints (`sendNotification`, `getNotificationHistory`)
  - Implement pagination for notification history
  - Add query parameters for filtering by type, date, or read status
  - Handle different HTTP status codes with appropriate error messages
  - Implement methods for marking notifications as read

- **NotificationRepository**:
  - Create a repository class that uses NotificationApi
  - Implement caching mechanism for notification data
  - Handle offline notification data storage
  - Manage FCM token registration and updates
  - Implement synchronization between local and remote notifications
  - Add methods for local notification management

#### 2. Models (`models/`)
- **NotificationItem**:
  - Implement `fromJson` and `toJson` methods
  - Add validation methods for notification content
  - Create computed properties for formatted timestamps
  - Add methods to categorize notification types
  - Include notification priority levels
  - Add methods to determine notification actions

- **NotificationFilter**:
  - Create a model for filtering notifications (by type, date range, etc.)
  - Add methods to serialize filter parameters

#### 3. Presentation Layer (`presentation/`)
- **NotificationBell**:
  - Implement badge counter with live updates
  - Add animations for new notifications
  - Handle touch interactions and navigation
  - Show preview of recent notifications on long press

- **NotificationHistoryScreen**:
  - Implement infinite scrolling for large notification lists
  - Add filtering and sorting options
  - Include search functionality for notification history
  - Add swipe actions to mark as read/delete
  - Implement batch operations for multiple notifications
  - Add visual categorization by notification type
  - Include timestamp formatting and grouping

- **State Management**:
  - Use Bloc, Provider, or Riverpod for notification state
  - Handle loading, success, and error states
  - Manage real-time updates for new notifications
  - Track notification read/unread status

#### 4. Push Notifications Integration
- Integrate with Firebase Cloud Messaging (FCM)
  - Implement FCM token registration and management
  - Handle token refresh and updates
  - Register for topics based on user roles and subscriptions
- Implement local notifications
  - Handle notifications when app is in foreground
  - Create rich notification content (images, actions)
  - Schedule notifications for specific times if needed
- Handle notification actions
  - Deep linking to specific screens based on notification content
  - Handle notification tap actions appropriately
  - Implement custom notification actions

#### 5. Notification Categories & Types
- Define different notification types (bus delay, arrival, emergency, general)
- Implement different handling for each notification category
- Add different visual styles for different notification types
- Create notification preference settings for users to customize

#### 6. Privacy and Permissions
- Handle notification permissions appropriately
- Implement opt-in/opt-out mechanisms for different notification types
- Respect Do Not Disturb settings
- Add notification scheduling preferences (no notifications during night hours)

#### 7. Performance Considerations
- Optimize database queries for large notification histories
- Implement efficient notification display and scrolling
- Manage memory usage for notification caching
- Handle large notification payloads appropriately

#### 8. Platform-Specific Considerations
- Implement proper notification handling for Android and iOS
- Handle different notification settings and capabilities per platform
- Address platform-specific notification styling and features
- Handle notification channel management on Android


# Specification: User-Generated Officer Profiles

## 1. Overview

This feature allows users to create and maintain profiles of law enforcement officers based on their personal encounters. This will create a user-generated database of officers that can be accessed by other users of the app.

## 2. User Stories

- As a user, I want to be able to create a new officer profile if I can't find the officer in the existing database.
- As a user, I want to be able to add details about an encounter with an officer to their profile.
- As a user, I want to be able to view the encounter history of an officer, as reported by other users.
- As a user, I want to be able to distinguish between official data and user-generated data.

## 3. Data Models

### 3.1. `OfficerProfile` Model (Updated)

```dart
class OfficerProfile {
  final String id;
  final String name;
  final String badgeNumber;
  final String department;
  final List<ComplaintRecord> complaintRecords;
  final List<DisciplinaryAction> disciplinaryActions;
  final List<Commendation> commendations;
  final CareerTimeline careerTimeline;
  final CommunityRating communityRating;
  final bool isUserGenerated; // New field
  final String? createdBy; // New field
  final List<Encounter> encounters; // New field

  // ... existing constructor and methods
}
```

### 3.2. `Encounter` Model (New)

```dart
class Encounter {
  final String id;
  final DateTime date;
  final String? location;
  final String description;
  final List<String> evidence; // List of URLs to photos, videos, etc.
  final String reportedBy; // User ID of the user who reported the encounter

  Encounter({
    required this.id,
    required this.date,
    this.location,
    required this.description,
    required this.evidence,
    required this.reportedBy,
  });
}
```

## 4. UI/UX

### 4.1. "Add Officer" Screen

- A new screen with a form to create a new officer profile.
- The form will include fields for:
  - Name
  - Badge Number
  - Department
  - Other relevant details

### 4.2. "Add Encounter" Screen

- A new screen with a form to add details about an encounter.
- This screen will be similar to the existing `submitCommunityIncidentReport` functionality.
- The form will include fields for:
  - Date and time of the encounter
  - Location of the encounter
  - A description of what happened
  - The ability to upload evidence (photos, videos, etc.)

### 4.3. `OfficerProfileWidget` (Updated)

- The `OfficerProfileWidget` will be updated to display user-generated content, including a list of encounters.
- Each encounter in the list will be tappable, taking the user to a screen with more details about the encounter.

### 4.4. `OfficerSearchScreen` (Updated)

- If a user searches for an officer and no results are found, a "Create New Officer Profile" button will be displayed.
- Tapping this button will take the user to the "Add Officer" screen.

## 5. Backend API

### 5.1. `POST /officers`

- Creates a new officer profile.
- **Request Body**:
  ```json
  {
    "name": "John Doe",
    "badgeNumber": "12345",
    "department": "NYPD"
  }
  ```
- **Response**:
  ```json
  {
    "id": "new-officer-id",
    "name": "John Doe",
    "badgeNumber": "12345",
    "department": "NYPD",
    "isUserGenerated": true,
    "createdBy": "user-id"
  }
  ```

### 5.2. `POST /officers/{officerId}/encounters`

- Adds a new encounter to an officer's profile.
- **Request Body**:
  ```json
  {
    "date": "2025-09-07T12:00:00.000Z",
    "location": "New York, NY",
    "description": "The officer was very helpful.",
    "evidence": [
      "https://example.com/photo.jpg"
    ]
  }
  ```
- **Response**:
  ```json
  {
    "id": "new-encounter-id",
    "date": "2025-09-07T12:00:00.000Z",
    "location": "New York, NY",
    "description": "The officer was very helpful.",
    "evidence": [
      "https://example.com/photo.jpg"
    ],
    "reportedBy": "user-id"
  }
  ```

## 6. Implementation Details

1.  **Data Models**:
    - Create the `Encounter` model in a new file: `lib/src/collaborative_monitoring/models/encounter.dart`.
    - Update the `OfficerProfile` model in `lib/src/collaborative_monitoring/models/officer_profile.dart`.
2.  **Backend**:
    - Implement the new API endpoints on the backend.
    - Update the database schema to include the new fields.
3.  **UI/UX**:
    - Create the "Add Officer" screen.
    - Create the "Add Encounter" screen.
    - Update the `OfficerProfileWidget`.
    - Update the `OfficerSearchScreen`.
4.  **Service Layer**:
    - Create a new method in `OfficerRecordsService` to create a new officer profile.
    - Create a new method in `OfficerRecordsService` to add an encounter to an officer's profile.

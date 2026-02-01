# Cop Stopper Mobile Application

## Overview
Cop Stopper is a mobile application designed to assist users during police interactions by providing real-time recording, legal guidance, and access to relevant information.

## Key Features

### 1. Real-Time Audio/Video Recording with Transcription

**Design:**
This feature is central to the application's purpose. The implementation likely involves:
*   **`mobile/lib/src/services/recording_service.dart`**: Handles the core logic for starting, stopping, and managing audio/video recording. This service would interact with native device APIs for media capture.
*   **`mobile/lib/src/services/transcription_service.dart`**: Orchestrates the transcription process, potentially sending recorded audio to a backend service or utilizing on-device models.
*   **`mobile/lib/src/services/whisper_transcription_service.dart`**: Specifically integrates with OpenAI's Whisper model for high-quality speech-to-text conversion.
*   **`mobile/lib/src/services/whisper_model_manager.dart`**: Manages the loading and lifecycle of the Whisper model, especially if on-device transcription is supported.
*   **`mobile/lib/src/blocs/recording`**: Manages the state related to recording, such as recording status (idle, recording, paused), file paths, and transcription progress.
*   **`mobile/lib/src/ui/screens` and `mobile/lib/src/ui/components`**: Provide the user interface for initiating and controlling recordings, displaying transcription results, and managing recorded sessions.

**Ways to Improve:**
*   **Offline Transcription:** Implement robust offline transcription capabilities using on-device Whisper models to ensure functionality even without an internet connection. This would require efficient model loading and resource management.
*   **Enhanced Error Handling:** Implement more granular error handling for recording failures (e.g., storage full, microphone access denied) and transcription errors (e.g., API limits, network issues), providing clear feedback to the user.
*   **User Control over Quality/Speed:** Offer user settings to balance transcription quality/accuracy with processing speed and battery consumption, allowing for a personalized experience.
*   **Visual Feedback:** Provide clear and intuitive visual feedback during recording (e.g., waveform visualization, recording duration) and transcription (e.g., progress indicators, real-time text display).
*   **Background Recording Indicators:** Ensure clear system-level indicators (e.g., persistent notification) when recording in the background to comply with privacy best practices and platform guidelines.

### 2. AI-Powered Chatbot for Legal Guidance

**Design:**
This feature provides users with on-demand legal information. The design likely includes:
*   **`mobile/lib/src/models/legal_advice_model.dart`**: Defines the structure for legal advice responses from the AI, including the advice text, relevant statutes, and confidence scores.
*   **`mobile/lib/src/services/api_service.dart`**: Acts as a general API client, which might be used to communicate with the backend for AI chatbot interactions. A dedicated `chatbot_service.dart` might also be present or beneficial.
*   **`mobile/lib/src/blocs/chatbot` (anticipated)**: A dedicated BLoC would manage the state of the chatbot conversation, including user inputs, AI responses, and loading states.
*   **`mobile/lib/src/ui/screens` and `mobile/lib/src/ui/components`**: Implement the chat interface, allowing users to input queries and view AI-generated legal guidance.

**Ways to Improve:**
*   **Diverse Legal Databases:** Integrate with a wider array of legal databases and resources (beyond Caselaw Access Project and Free Law Project) to provide more comprehensive and nuanced legal advice.
*   **AI Confidence Levels:** Clearly indicate the AI's confidence level for each piece of advice, encouraging users to consult human legal professionals for critical situations.
*   **User Feedback Mechanism:** Implement a feedback system for users to rate the quality and helpfulness of the AI's advice, which can be used to improve the model over time.
*   **Multi-language Support:** Extend the chatbot to support multiple languages, making legal guidance accessible to a broader user base.
*   **Contextual Memory:** Enhance the chatbot's ability to maintain context across a conversation, providing more relevant follow-up advice.

### 3. Officer Public Records Retrieval

**Design:**
This feature allows users to access public information about officers. The design likely involves:
*   **`mobile/lib/src/models/officer_record_model.dart`**: Defines the data structure for an officer's public record, including name, badge number, department, and any publicly available disciplinary actions or commendations.
*   **`mobile/lib/src/services/public_records_api_client.dart`**: A client for interacting with external public records APIs.
*   **`mobile/lib/src/services/real_police_api_service.dart`**: Potentially a service that aggregates data from various police-related APIs.
*   **`mobile/lib/src/services/production_officer_records_service.dart`**: A service specifically designed for fetching and processing officer records in a production environment.
*   **`mobile/lib/src/blocs/officer_records` (anticipated)**: Manages the state for searching, retrieving, and displaying officer records.
*   **`mobile/lib/src/ui/screens` and `mobile/lib/src/ui/components`**: Provide the user interface for searching for officers and viewing their public records.

**Ways to Improve:**
*   **Comprehensive Data Sources:** Continuously expand and update the integration with various public records databases to ensure the most comprehensive and up-to-date information is available.
*   **Clear Privacy Implications:** Clearly communicate to users the sources of the data and the privacy implications of accessing and using public officer records.
*   **Advanced Filtering and Search:** Implement advanced filtering and search capabilities (e.g., by department, date range, type of incident) to help users find specific information more efficiently.
*   **Data Verification:** Implement mechanisms to verify the accuracy and recency of public record data, potentially flagging outdated or unverified information.

### 4. Document Storage and Presentation

**Design:**
This feature enables secure storage and easy access to important documents. The design likely includes:
*   **`mobile/lib/src/models/document_model.dart`**: Defines the structure for stored documents, including metadata like document type, expiration date, and secure storage location.
*   **`mobile/lib/src/services/secure_document_service.dart`**: Handles the secure storage, retrieval, and encryption of user documents (e.g., insurance, registration, licenses). This service would interact with secure storage mechanisms on the device.
*   **`mobile/lib/src/blocs/documents` (anticipated)**: Manages the state of document management, including adding, viewing, and organizing documents.
*   **`mobile/lib/src/ui/screens` and `mobile/lib/src/ui/components`**: Provide the user interface for uploading, viewing, and presenting documents to an officer.

**Ways to Improve:**
*   **Support for More Document Types:** Expand support for a wider range of document types and formats, including the ability to annotate or highlight specific sections.
*   **Cloud Storage Integration:** Offer optional integration with secure cloud storage services (e.g., encrypted cloud backups) for document backup and synchronization across devices.
*   **Enhanced Security Features:** Implement additional security measures such as biometric authentication (fingerprint/face ID) for accessing sensitive documents.
*   **Document Expiry Reminders:** Provide notifications for expiring documents (e.g., driver's license, insurance) to prompt users to update them.

### 5. Location-Based Legal Guidance

**Design:**
This feature provides legal advice tailored to the user's current location. The design likely involves:
*   **`mobile/lib/src/models/jurisdiction_info.dart`**: Defines the data structure for legal information specific to a particular jurisdiction.
*   **`mobile/lib/src/services/gps_location_service.dart`**: Interacts with the device's GPS to obtain precise location data.
*   **`mobile/lib/src/services/jurisdiction_mapping_service.dart`**: Maps geographical coordinates to specific legal jurisdictions (e.g., city, county, state).
*   **`mobile/lib/src/services/jurisdiction_resolver.dart`**: Resolves the current legal jurisdiction based on the user's location.
*   **`mobile/lib/src/services/location_service.dart`**: A higher-level service that orchestrates location-related tasks.
*   **`mobile/lib/src/services/location_permission_service.dart`**: Manages and requests location permissions from the user.
*   **`mobile/lib/src/services/location_boundary_service.dart`**: Potentially defines and manages geographical boundaries for different jurisdictions.
*   **`mobile/lib/src/blocs/location` (anticipated)**: Manages the state of location data and the resolved legal jurisdiction.
*   **`mobile/lib/src/ui/screens` and `mobile/lib/src/ui/components`**: Display location-specific legal guidance and potentially a map interface showing the current jurisdiction.

**Ways to Improve:**
*   **Granular Location-Based Rules:** Implement more granular rules and advice based on specific locations within a jurisdiction (e.g., specific city ordinances, park rules).
*   **Offline Jurisdiction Data:** Allow for offline storage and access to jurisdiction data, ensuring legal guidance is available even without an internet connection.
*   **Visual Representation of Boundaries:** Provide a clear visual representation of jurisdictional boundaries on a map, helping users understand when legal rules might change.
*   **Proactive Alerts:** Offer proactive alerts when users are entering or leaving a jurisdiction with significantly different legal guidelines.

## Technical Stack
- **Frontend**: Flutter/Dart for cross-platform development
- **Backend**: Node.js with Express
- **Database**: PostgreSQL
- **Authentication**: OAuth 2.0
- **APIs**: Integration with third-party services for legal information, public records, and location services

## Design Principles
- Minimalist design with monochromatic color scheme
- Sans-serif typography for clarity
- Consistent grid system and ample whitespace
- Intuitive navigation with bottom bar and gesture support
- Micro-interactions and smooth transitions

## Privacy and Security
- Data encryption for all stored and transmitted information
- Explicit user consent for recording and data usage
- Compliance with relevant data protection laws (GDPR, CCPA)

## Identified Issues

### Code Issues:
*   **Lack of dedicated Chatbot BLoC/Service:** While `api_service.dart` exists, a dedicated BLoC and service for the AI chatbot (`mobile/lib/src/blocs/chatbot` and `mobile/lib/src/services/chatbot_service.dart`) would improve modularity, testability, and state management for the conversational flow.
*   **Lack of dedicated Officer Records BLoC:** Similar to the chatbot, a dedicated BLoC for officer records (`mobile/lib/src/blocs/officer_records`) would centralize state management for search, retrieval, and display of officer information.
*   **Lack of dedicated Documents BLoC:** A dedicated BLoC for document management (`mobile/lib/src/blocs/documents`) would streamline the handling of document-related states, such as loading, adding, and deleting documents.
*   **Lack of dedicated Location BLoC:** While there are many location services, a `mobile/lib/src/blocs/location` BLoC would centralize the state of the user's location and resolved jurisdiction, making it easier for UI components to react to location changes.
*   **Potential for tightly coupled services:** Without examining the code, there's a risk that some services might be tightly coupled, making them harder to test independently or reuse. Dependency injection (indicated by `service_locator.dart`) should mitigate this, but it's worth verifying.
*   **Web-specific service locators:** The presence of `service_locator_web.dart` suggests platform-specific implementations. While necessary, ensuring consistent behavior and minimal code duplication across platforms is crucial.
*   **Error handling in services:** The current file structure doesn't explicitly show a centralized error handling mechanism. Each service should have robust error handling, and these errors should be propagated and handled gracefully in the BLoCs and UI.
*   **Testing coverage:** The `GEMINI.md` mentions testing, but without looking at the actual test files, the extent of unit, widget, and integration test coverage is unknown. Comprehensive testing is vital for an application dealing with sensitive legal interactions.

### Design Issues:
*   **Monochromatic Color Scheme:** While minimalist, a purely monochromatic scheme might lack sufficient visual hierarchy or emotional cues for critical alerts or different states within the application. Subtle use of accent colors could enhance usability without sacrificing minimalism.
*   **Information Overload in Legal Guidance:** The AI chatbot and location-based legal guidance could potentially present a large amount of text. The design should prioritize readability and scannability, perhaps using summaries, expandable sections, or clear categorization.
*   **Privacy Concerns with Officer Records:** While accessing public records, the UI/UX design needs to carefully consider how this information is presented to avoid misuse or misinterpretation. Clear disclaimers and context are essential.
*   **Document Presentation Clarity:** When presenting documents to an officer, the UI needs to be extremely clear, quick, and easy to navigate, especially under stressful conditions. Large, legible text and minimal interaction steps are crucial.
*   **Accessibility:** The design principles mention clarity, but explicit consideration for accessibility (e.g., screen reader support, sufficient color contrast for visually impaired users, customizable text sizes) is not explicitly stated.

### Overall Flow Issues:
*   **Emergency Workflow Clarity:** The flow for initiating and managing emergency recordings and alerts needs to be extremely intuitive and rapid, especially in high-stress situations. Any friction in this flow could be critical.
*   **Seamless Transition between Features:** The application should provide a smooth and logical flow between features. For example, after a recording, how easily can the user access legal guidance related to the recorded event or retrieve officer records?
*   **User Onboarding for Sensitive Features:** For features like recording, legal guidance, and officer records, the onboarding process needs to clearly explain the purpose, privacy implications, and how to use them effectively and responsibly.
*   **Feedback Loop for AI Guidance:** The current flow doesn't explicitly mention how users can provide feedback on the AI's legal guidance, which is crucial for continuous improvement and trust-building.
*   **Offline Experience:** While some services might have web counterparts, the overall user flow for critical features (recording, basic legal guidance) should be robust even without an internet connection. The current design doesn't explicitly detail the offline user experience.
*   **Data Management and Retention:** The flow for managing recorded data, transcriptions, and documents, including deletion and retention policies, needs to be clear and user-friendly, aligning with privacy regulations.

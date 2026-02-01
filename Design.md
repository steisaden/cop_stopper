# Cop Stopper - Design Specification

## 1. Application Overview

### 1.1. Core Purpose

Cop Stopper is a personal safety and legal-assistance application designed to empower and protect citizens during interactions with law enforcement. Its primary function is to securely and discreetly record encounters, provide real-time assistance, and maintain an organized archive of evidence. The app is a tool for accountability, transparency, and peace of mind.

### 1.2. Target Audience

The app is for any individual who wants a secure way to document police encounters, particularly those who may be in vulnerable situations or are advocates for civil rights and accountability.

### 1.3. Design Philosophy & Aesthetics

The design must be **intuitive, calm, and trustworthy**. Users will be in high-stress situations, so the UI must be extremely easy to navigate with minimal cognitive load.

- **Clarity:** Use clear, unambiguous icons and labels.
- **Discretion:** The app should be functional without drawing unnecessary attention. A discreet UI is key.
- **Calmness:** Employ a soothing and professional color palette (e.g., blues, grays, pastels) to avoid escalating user anxiety. Reserve bright, alerting colors (like red or amber) for critical status indicators only (e.g., "Recording is LIVE").
- **Accessibility:** Ensure high contrast, legible fonts, and large tap targets for all interactive elements.

### 1.4. Branding & Visual Identity

- **Typography:** Use a clean, highly-legible sans-serif font like Inter, Roboto, or SF Pro.
- **Color Palette:**
  - **Primary:** A calming dark blue or slate gray for the base theme.
  - **Secondary:** Lighter shades of the primary color for cards and surfaces.
  - **Accent:** A professional, reassuring color like a soft blue or teal for buttons and interactive elements.
  - **Alert/Recording:** A distinct red or bright amber, used _exclusively_ to indicate that a recording is in progress.
- **Iconography:** Use solid, filled icons that are universally recognizable (e.g., a circle for record, a gear for settings, a list for sessions).

---

## 2. Screen-by-Screen Breakdown

This section details the primary screens of the application. The wireframes in the `/wireframes` directory provide a basic visual reference.

### 2.1. Home / Recording Screen (`home_record_screen.svg`)

This is the default screen when the app is opened, designed for immediate action.

- **Purpose:** To allow the user to start recording an encounter with a single tap.
- **Key UI Elements:**
  - **Primary Action Button:** A very large, centrally-located button with a "Record" icon and/or text. This should be the main focal point of the screen.
    - _State 1 (Idle):_ "Tap to Record".
    - _State 2 (Tapped/Activating):_ Shows a brief loading/activation indicator.
  - **Status Indicators:** Subtle icons or text at the top of the screen indicating:
    - GPS Signal Strength / Location Acquired.
    - Device Battery Level.
    - Cloud Sync Status.
  - **Navigation Bar:** A simple bottom navigation bar with icons for:
    - **Home/Record** (current screen)
    - **Sessions**
    - **Settings**

### 2.2. Live Assist / Active Recording Screen (`live_assist_screen.svg`)

This screen is displayed once a recording is active.

- **Purpose:** To provide the user with real-time information and assurance while a recording is in progress.
- **Key UI Elements:**
  - **Recording Status Header:** A prominent, persistent header or banner.
    - Text: "RECORDING LIVE"
    - A blinking red dot icon.
    - A running timer showing the duration of the recording (e.g., 00:01:32).
  - **Video Feed:** A small, non-intrusive view of what the camera is recording. This can be minimized or moved.
  - **Live Transcription Feed:** A real-time feed of the audio being transcribed by the Whisper service. This provides a silent, readable log of the conversation.
  - **Map View:** A simple map showing the user's current, real-time location via a pin.
  - **Stop Button:** A clear, accessible button to end the recording. Tapping it should prompt a confirmation (`"Are you sure you want to end the session?"`) to prevent accidental stops.
  - **(Optional) Alert Contacts Button:** A secondary "panic" button to notify pre-configured trusted contacts that a recording is in progress, sending them a link to a live stream or location.

### 2.3. Sessions List Screen (`sessions_list_screen.svg`)

This screen archives all past recordings.

- **Purpose:** To allow the user to browse, manage, and review their saved encounters.
- **Key UI Elements:**
  - **Screen Title:** "Sessions" or "My Recordings".
  - **Session List:** A vertically scrollable list of past sessions. Each item in the list should be a "card" containing:
    - Date and Time of the recording.
    - Duration of the recording.
    - Location (City, State or a small map thumbnail).
    - A video thumbnail if available.
  - **Search/Filter Bar:** A search bar at the top to filter sessions by date, location, or keywords from the transcript.
  - **Floating Action Button (FAB):** An optional FAB to manually add a new entry (e.g., upload a past video or add notes about an encounter that wasn't recorded).

### 2.4. Session Detail Screen (`session_detail_screen.svg`)

This screen provides a comprehensive view of a single recorded session.

- **Purpose:** To review all data associated with a specific encounter.
- **Key UI Elements:**
  - **Screen Title:** The date and time of the session (e.g., "Aug 26, 2025 - 4:15 PM").
  - **Media Player:** A video/audio player for the recording.
  - **Interactive Transcript:** The full, time-synced transcript of the recording. Tapping a sentence in the transcript should jump the media player to that point in time.
  - **Map View:** A map showing the full path of the device during the recording.
  - **Metadata Section:** A clearly organized section with key details:
    - Duration
    - Location (Address/Coordinates)
    - Device Info
  - **Action Bar/Menu:** Buttons or a menu with options to:
    - **Export/Share:** Securely share the session data (video, transcript, and metadata).
    - **Delete:** Permanently delete the session (with a strong confirmation dialog).
    - **Add Notes:** Add personal notes or details about the officers involved.

### 2.5. Settings Screen (`settings_screen.svg`)

- **Purpose:** To allow the user to configure the app and manage their account.
- **Key UI Elements:** A standard settings list with the following sections:
  - **Account:**
    - User Profile (Name, Email)
    - Change Password
    - Log Out
  - **Recording:**
    - Video Quality (Low, Medium, High)
    - Auto-start Recording (e.g., triggered by a voice command or hardware button shortcut).
  - **Trusted Contacts:**
    - A list of emergency contacts to notify.
    - Ability to add/remove contacts.
  - **Cloud Storage:**
    - Manage subscription or view storage usage.
    - Sync settings (Wi-Fi only, etc.).
  - **Legal & Privacy:**
    - Terms of Service
    - Privacy Policy
    - Disclaimers about local recording laws.
